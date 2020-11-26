/*
 * Box for WeAct-TC Mini-STM32H7xx openmv board
 * and gy-530 vl53l0x laser ranging sensor.
 */

connector = false; //hole for dupont connectors

eps1=0.001;
eps2=2*eps1;
infinity=100;
inch=25.4;

top_z=6.0;    // top components
bottom_z=6.2; // bottom components
pcb_z=1.6;    // pcb

w1=40.64;
h1=85.0;
w2=w1;
h2=66.88;
z1=top_z+pcb_z+bottom_z;
d1=5.2;
r1=d1/2; // distance screw center to pcb edge

/* camera */
cam_x=14.5;
cam_y=79.0;
cam_d=8.0;

/* buttons */
button_y = 62.0;
button_x1 = 11.9;
button_x2 = 16.1;
button_x3 = 20.2;
button_w = 3.0;
button_h = 3.0;
button_z = top_z-1.3;
button_l = 13.6;

led_z = top_z - 1.6;

distance_sensor_x = 32.0;
distance_sensor_y = 79.0;
distance_sensor_z = 1.2-eps1;

clearance_fit=0.4;

include <enclosure_snap.scad>

/* through hole */
module hole(){
    translate([0,0,-infinity/2])
    linear_extrude(infinity)
    offset(nozzle_size/2)
    projection()
    children();
}

/* convert 3d object to 3d-printable hole */

module contour() {
    rotate([-90,0,0])
    linear_extrude(9)
    offset(clearance_fit)
    hull()
    projection(cut = true)
    rotate([90,0,0])
    translate([0,-1,0])
    children();
}

/* pcb screw centers */
module screw_positions() {
    translate([r1, r1, 0])
    children();
    translate([r1, h2-r1, 0])
    children();
    translate([w2-r1, h2-r1, 0])
    children();
    translate([w2-r1, r1, 0])
    children();
}

/* engraving */
module small_text(txt) {
    text_h=nozzle_size; // one layer
    translate([0,0,-text_h+eps1])
    linear_extrude(2*text_h) text(txt, size = 6, halign = "center", valign = "center",font="Lato:style=Regular");
}

// --------------------------------------------------------------------------------
// Imports from cad

module led1_hole() {
    translate([0,0,-infinity/2])
    linear_extrude(infinity)
    translate([31.2, 10.3])
    offset(nozzle_size)
    square([0.8,1.6], center=true);
}

module led2_hole() {
    translate([0,0,-infinity/2])
    linear_extrude(infinity)
    translate([8.0, 62.1])
    offset(nozzle_size)
    translate([-0.8,-0.4,0])
    square([1.6,0.8]); // gives thin wall
}

module led1_body() {
    translate([0,0,-wall_thickness-led_z])
    linear_extrude(led_z)
    offset(3*nozzle_size)
    translate([31.2, 10.3])
    square([0.8,1.6], center=true);
}

module led2_body() {
    translate([0,0,-wall_thickness-led_z])
    linear_extrude(led_z)
    offset(3*nozzle_size)
    translate([8.0, 62.1])
    square([1.6,0.8], center=true);
}

module distance_sensor() {
    // 3d model of gy-530 module, center of vl53l0x at [0,0,0]
    translate([-3.2,64.6,-3.7])
    import("GY-530.stl");
}

module distance_sensor_hole() {
    translate([distance_sensor_x,distance_sensor_y,distance_sensor_z])
    rotate([0,0,180])
    {
        // vl53l0x sensor
        translate([0,0,-wall_thickness/2])
        linear_extrude(wall_thickness*2)
        offset(nozzle_size)
        square([2.4,4.4],center=true);

        // cone cutout
        translate([0,0,-wall_thickness])
        hull() {
            translate([0,0,wall_thickness])
            linear_extrude(eps1)
            offset(nozzle_size)
            square([2.4,4.4],center=true);
            translate([0,0,-eps2])
            linear_extrude(eps2)
            offset(nozzle_size+wall_thickness)
            square([2.4,4.4],center=true);
            }

        // small cap
        translate([0.9,3.3,0.6])
        linear_extrude(0.6+eps1)
        offset(nozzle_size)
        square([0.6,1.0],center=true);

        // pins
        translate([-3.1,-0.6,1.1+eps1])
        hull() {
            linear_extrude(eps1)
            offset(nozzle_size)
            square([1.2,0.15*inch],center=true);
            translate([0,0,-1.2])
            linear_extrude(eps1)
            offset(nozzle_size)
            square([eps1,0.1*inch],center=true);
        }

        translate([7.3,1.8,1.1+eps1])
        hull() {
            linear_extrude(eps1)
            offset(nozzle_size)
            square([1.2,0.35*inch],center=true);
            translate([0,0,-1.2])
            linear_extrude(eps1)
            offset(nozzle_size)
            square([eps1,0.3*inch],center=true);
        }
    }
    
    // hole for cable from sensor to processor 
    translate([distance_sensor_x-2.5,h2,wall_thickness+bottom_z+eps2])
    cube([0.2*inch,10.0,2*pcb_z],center=true);
}

module distance_sensor_body() {
    translate([distance_sensor_x,distance_sensor_y,distance_sensor_z])
    rotate([0,0,180])
    {
        translate([-1.6,4.6,1.1])
        rotate([0,0,180/8])
        cylinder(d=3.2, h=1.2, $fn=8);

        translate([2.1,1.9,1.1]) {
            translate([0,0,-1.1])
            linear_extrude(1.1+eps1)
            offset(wall_thickness + nozzle_size)
            square([13.0,10.6], center = true);
            linear_extrude(1.6+eps1)
            difference() {
                offset(wall_thickness + nozzle_size)
                square([13.0,10.6], center = true);
                offset(nozzle_size)
                square([13.0,10.6], center = true);
            }
        }
    }
}

module distance_sensor_support() {
    support_h=wall_thickness+top_z+pcb_z+bottom_z+pcb_z+wall_thickness-distance_sensor_z-4.3;
    translate([distance_sensor_x,distance_sensor_y,0])
    rotate([0,0,180])
    translate([-1.6,4.6,0])
    mirror([0,0,1]) {
        rotate([0,0,180/8])
        cylinder(d=5.2,h=support_h,$fn=8);
        buttress_h=support_h*3/4;
        hull() {
            translate([0,-wall_thickness/2,buttress_h])
            cube([wall_thickness,wall_thickness,eps1]);
            cube([buttress_h,wall_thickness,eps1]);
        }
        rotate([0,0,-90])
        hull() {
            translate([0,-wall_thickness/2,buttress_h])
            cube([wall_thickness,wall_thickness,eps1]);
            cube([buttress_h,wall_thickness,eps1]);
        }
    }
}

module lcd_hole() {
    hole()
    translate([6.5,44,0])
    cube([23.7,12.8,eps1]);
}

module lcd_body() {
    translate([6.5,44,0])
    mirror([0,0,1])
    linear_extrude(2*wall_thickness)
    offset(wall_thickness)
    square([23.7,12.8]);
}

module button_body() {
    translate([0,0,-button_z/2]) {
        translate([button_x3, button_y,0])
        cube([button_w, button_h, button_z], center=true);

        translate([button_x2, button_y,0])
        cube([button_w, button_h, button_z], center=true);

        translate([button_x1, button_y,0])
        cube([button_w, button_h, button_z], center=true);
    }
}

module button_holes() {
    d = (button_x2 - button_x1)/2;
    x1 = button_x1 - d; // first
    x2 = button_x1 + d;
    x3 = button_x2 + d;
    x4 = button_x3 + d; // last
    y0 = button_y-button_h/2+button_l/2-clearance_fit;
    z0 = 4*wall_thickness+eps1;

    translate([x1, y0, 0])
    cube([clearance_fit, button_l, z0], center=true);

    translate([x2, y0, 0])
    cube([clearance_fit, button_l, z0], center=true);

    translate([x3, y0, 0])
    cube([clearance_fit, button_l, z0], center=true);

    translate([x4, y0, 0])
    cube([clearance_fit, button_l, z0], center=true);

    translate([(x1+x4)/2, button_y-button_h/2-clearance_fit/2, 0])
    cube([x4-x1+clearance_fit, clearance_fit, z0], center=true);

    translate([x1-clearance_fit/2, button_y+button_h/2, -2*wall_thickness])
    cube([x4-x1+clearance_fit, button_l-button_h-clearance_fit, wall_thickness]);

    if (0)
    hole()
    import("buttons.stl");
}

module usb() {
    contour()
    translate([0,0,-0.1])
    import("usb.stl");
}

module microsd() {
    contour()
    translate([7.2,0,0])
    cube([14.1,15.2,1.9]);
}

module pcb_3d() {
    translate([0,0,pcb_z])
    import("MiniSTM32H7xx.stl");
    camera();
}

module camera() {
    translate([cam_x,cam_y,0])
    rotate([0,180,0]) {
        translate([-4,-4,0])
        cube([8.0,8.0,4.6]);
        cylinder(d=8.0,h=6.0);
        translate([-3.0,-20.0,0])
        cube([6.0,20.0,0.35]);
    }
}

// hole for DuPont connectors
module connector_hole() {
    conn_h = wall_thickness+bottom_z+eps2;
    translate([0,0,-conn_h])
    linear_extrude(2*conn_h)
    offset(nozzle_size) {
        translate([r1,h2/2,0])
        square([0.2*inch,2.2*inch],center=true);
        translate([w1-r1,h2/2,0])
        square([0.2*inch,2.2*inch],center=true);
    };
}

module connector_body() {
    linear_extrude(2*wall_thickness)
    offset(wall_thickness+nozzle_size) {
        translate([r1,h2/2,wall_thickness/2])
        square([0.2*inch,2.2*inch],center=true);
        translate([w1-r1,h2/2,wall_thickness/2])
        square([0.2*inch,2.2*inch],center=true);
    }
}

// --------------------------------------------------------------------------------
// box top cover

module top() {
    difference() {
        top_body();
        top_holes();
    }
}

module top_body() {
    translate([w1/2, h1/2, 0])
    rotate([0,180,0])
    top_cover();
    top_pcb_support();
    camera_support();
    distance_sensor_support();
    led1_body();
    led2_body();
    button_body();
    lcd_body();
}

module top_holes() {
    led1_hole();
    led2_hole();
    button_holes();
    lcd_hole();
}

module camera_support() {
    translate([cam_x,cam_y,0])
    translate([-cam_d/2,-cam_d/2,-(top_z+pcb_z+wall_thickness)])
    cube([cam_d, cam_d, top_z+pcb_z]);
}

module bottom_pcb_support() {
    difference() {
        linear_extrude(wall_thickness+bottom_z+pcb_z)
        offset(wall_thickness)
        pcb();
        translate([0,0,wall_thickness+bottom_z])
        linear_extrude(infinity)
        offset(tolerance)
        pcb();
        translate([0,0,wall_thickness])
        linear_extrude(infinity)
        offset(-wall_thickness)
        pcb();
    }
}

module pcb() {
    hull()
    screw_positions()
    circle(d=d1);
}

// --------------------------------------------------------------------------------
// box bottom

module bottom() {
    difference() {
        bottom_body();
        bottom_holes();
    }
}

module bottom_body() {
    translate([w1/2, h1/2, 0])
    bottom_box();
    bottom_pcb_support();
    bottom_camera_support();
    distance_sensor_body();
    bidi();
    if (connector) connector_body();
}

module bottom_holes() {
    camera_hole();
    camera_cable();
    distance_sensor_hole();
    text_label();
    translate([0,-5.0,wall_thickness+bottom_z+pcb_z])
    {
        usb();
        microsd();
    }
    if (connector) connector_hole();
}

module camera_hole() {
    w=cam_d+clearance_fit;
    translate([cam_x,cam_y,-infinity/2])
    cylinder(d=w, h=infinity);
}

module camera_cable() {
    th=0.4;
    cable_y=cam_y-h2;
    translate([cam_x-cam_d/2,cam_y-cam_d/2-cable_y,wall_thickness+bottom_z-th])
    cube([cam_d, cable_y, pcb_z+th+eps2]);
}

module bottom_camera_support() {
    translate([cam_x, cam_y, wall_thickness])
    linear_extrude(bottom_z-nozzle_size)
    difference() {
        offset(wall_thickness)
        offset(tolerance)
        square(cam_d, center = true);
        offset(tolerance)
        square(cam_d, center=true);
    }
}

module top_pcb_support() {
    cyl_z = wall_thickness+top_z;
    mirror([0,0,1])
    difference() {
        screw_positions()
        cylinder(d=d1,h=cyl_z);
        translate([w1/2, h1/2, 0]) {
            right_groove();
            rotate([180,180,0]) right_groove();
            front_groove();
            rotate([180,180,0])  front_groove();
        }
    }
}

module text_label() {
    translate([w1/2,h1/2,0])
    rotate([0,0,180])
    mirror([0,1,0])
    small_text("Mini H7");
}
// --------------------------------------------------------------------------------

// QR code data for "https://github.com/koendv/" (25 x 25)
// Generated by Altair's OpenSCAD QR Code Generator
// https://ridercz.github.io/OpenSCAD-QR/
qr_data = [[1,1,1,1,1,1,1,0,1,1,0,0,0,1,0,0,1,0,1,1,1,1,1,1,1],
           [1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,1],
           [1,0,1,1,1,0,1,0,1,0,0,1,1,1,1,1,0,0,1,0,1,1,1,0,1],
           [1,0,1,1,1,0,1,0,1,1,0,1,0,1,0,0,0,0,1,0,1,1,1,0,1],
           [1,0,1,1,1,0,1,0,1,1,1,1,0,1,1,1,1,0,1,0,1,1,1,0,1],
           [1,0,0,0,0,0,1,0,0,1,0,0,1,0,1,0,0,0,1,0,0,0,0,0,1],
           [1,1,1,1,1,1,1,0,1,0,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1],
           [0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0],
           [1,1,1,1,0,0,1,0,1,0,0,0,0,0,1,0,1,1,0,0,1,1,1,0,1],
           [1,0,1,1,1,0,0,0,0,1,0,0,0,1,0,0,1,0,0,1,0,0,0,1,0],
           [0,0,1,0,0,1,1,0,1,0,0,0,0,1,1,0,0,1,1,1,0,0,0,0,0],
           [0,0,0,1,1,0,0,1,0,0,0,1,1,1,1,1,0,1,0,0,0,1,1,0,0],
           [1,0,1,1,1,1,1,1,0,1,0,1,1,1,1,0,0,1,1,0,1,0,1,1,1],
           [0,1,0,0,0,1,0,0,1,0,1,1,0,1,1,1,0,0,1,1,1,0,0,0,1],
           [0,1,1,1,1,0,1,0,1,1,0,0,1,0,1,0,1,1,0,0,1,0,1,1,0],
           [1,0,0,0,0,1,0,1,0,0,1,1,0,0,1,0,0,0,1,1,1,0,0,0,1],
           [0,0,0,1,1,0,1,1,1,0,1,0,0,1,0,0,1,1,1,1,1,1,1,1,1],
           [0,0,0,0,0,0,0,0,1,0,0,1,0,1,0,0,1,0,0,0,1,0,1,0,1],
           [1,1,1,1,1,1,1,0,0,0,0,0,1,0,1,0,1,0,1,0,1,0,1,1,1],
           [1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,1,1,0,0,0,1,0,0,1,1],
           [1,0,1,1,1,0,1,0,0,1,1,0,1,0,1,0,1,1,1,1,1,1,0,0,1],
           [1,0,1,1,1,0,1,0,1,0,1,1,0,1,0,0,0,1,1,0,1,1,1,1,1],
           [1,0,1,1,1,0,1,0,1,0,0,1,0,1,0,1,0,1,1,0,1,0,1,1,0],
           [1,0,0,0,0,0,1,0,1,0,1,0,1,1,0,1,0,0,1,0,1,0,1,0,0],
           [1,1,1,1,1,1,1,0,1,0,0,0,1,1,1,0,0,0,1,1,1,1,1,1,1]];

// Render QR code with default settings (module 1x1x1)
module bidi() {
    siz=2*nozzle_size;
    m=len(qr_data)*siz;
    translate([w2/2-m/2,h2/2-m/2,wall_thickness-siz/2])
    qr_render(qr_data, module_size = siz, height = siz);
}
// QR code rendering method
module qr_render(data, module_size = 1, height = 1) {
    maxmod = len(data) - 1;
    union() {
        for(r = [0 : maxmod]) {
            for(c = [0 : maxmod]) {
                if(data[r][c] == 1){
                    xo = c * module_size;
                    yo = (maxmod - r) * module_size;
                    translate([xo-eps1, yo-eps1, 0]) cube([module_size+eps2, module_size+eps2, height]);
                }
            }
        }
    }
}

// --------------------------------------------------------------------------------
// output

module printer_ready() {
    translate([-20,0,0])
    rotate([0,180,0])
    top();
    	
    bottom();
}

module assembly() {
rotate([90,0,0]) {
        if (1)
        translate([0,0,wall_thickness+bottom_z+pcb_z+top_z+wall_thickness])
        %render()
        top();

        if (1)
        %render()
        bottom();

        if (1)
        color("Green")
        translate([0,0,wall_thickness+bottom_z]) {
            if (1) {
                pcb_3d();
            } else {
                linear_extrude(pcb_z)
                pcb();
            }
        }

        if (1)
        color("Purple")
        translate([distance_sensor_x,distance_sensor_y,distance_sensor_z])
        rotate([180,0,180])
        distance_sensor();
    }
}

//bottom();
//rotate([0,180,0]) top();
//printer_ready();
assembly();

// not truncated
