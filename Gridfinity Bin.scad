// --- Configuration ---
grid_x = 4;
grid_y = 2;
wall_height = 25;      // Height of the retaining walls
wall_thick = 2;        // Thickness of the walls
floor_height = 6;      // Floor must be thick enough to hold the socket depth (less than 5mm leaves holes)

// --- Gridfinity Constants ---
pitch = 42;
lug_base = 42.0;       // Base width of the cutout (slightly loose for fit)
lug_top = 37.0;        // Top width of the cutout (tapered)
socket_depth = 4.8;    // Depth of the hole
corner_r = 4.0;        // Corner radius
$fn = 64;

// --- Main Assembly ---
difference() {
    // 1. Create a solid block
    union() {
        // Chamfer the walls
        color("RoyalBlue")
        hull() {
            translate([-wall_thick, -wall_thick, wall_height])
            create_rounded_rectangle(grid_x * pitch + wall_thick*2, grid_y * pitch + wall_thick*2, corner_r, 0.1);

            translate([-wall_thick, -wall_thick, 1.2])
            create_rounded_rectangle(grid_x * pitch + wall_thick*2, grid_y * pitch + wall_thick*2, corner_r, 0.1);

            translate([-wall_thick + 1.2, -wall_thick + 1.2, 0])
            create_rounded_rectangle(grid_x * pitch + wall_thick*2 - 2.4, grid_y * pitch + wall_thick*2 - 2.4, corner_r, 0.1);
        }

        // The floor (before we cut into it)
        translate([0, 0, 0])
        cube([grid_x * pitch, grid_y * pitch, floor_height]);
    }

    // 2. Create the grid
    union() {
        // The Grid Cutout
        translate([0, 0, floor_height - socket_depth]) // Align top of cut with top of floor
        for (x = [0 : grid_x - 1]) {
            for (y = [0 : grid_y - 1]) {
                translate([x * pitch + (pitch - lug_base)/2, y * pitch + (pitch - lug_base)/2, 0])
                create_negative_socket();
            }
        }

        // Cut out the inner box
        translate([0, 0, floor_height])
        cube([grid_x * pitch, grid_y * pitch, wall_height]);
    }
}

// Shapes to subtract
module create_negative_socket() {
    hull() {
        // Top of socket (Wide)
        translate([0, 0, socket_depth])
        create_rounded_rectangle(lug_base, lug_base, corner_r, 0.1);

        // Bottom of socket (Narrow/Tapered)
        translate([(lug_base - lug_top)/2, (lug_base - lug_top)/2, 0])
        create_rounded_rectangle(lug_top, lug_top, corner_r, 0.1);
    }
}

// Create a rounded rectangle shape
module create_rounded_rectangle(w, d, r, h) {
    translate([r, r, 0])
    hull() {
        cylinder(r=r, h=h);
        translate([w - 2*r, 0, 0]) cylinder(r=r, h=h);
        translate([w - 2*r, d - 2*r, 0]) cylinder(r=r, h=h);
        translate([0, d - 2*r, 0]) cylinder(r=r, h=h);
    }
}