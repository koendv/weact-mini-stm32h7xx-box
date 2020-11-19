/*
 * Box for WeAct-TC Mini-STM32H7xx.
 */

eps1=0.001;
eps2=2*eps1;
infinity=100;
inch=25.4;

top_z=3.6;    // top components
bottom_z=6.2; // bottom components
pcb_z=1.6;    // pcb

w1=40.64;
h1=86.0;
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
button_w = 2.0;
button_h = 3.0;
button_z = 2.0;
button_l = 13.6;

led_z = top_z - 1.0;

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
    linear_extrude(2*text_h) text(txt, size = 6, halign = "center", valign = "center");
}

// --------------------------------------------------------------------------------
// Imports from cad

module led1_hole() {
    translate([0,0,-infinity/2])
    linear_extrude(infinity)
    translate([31.2, 10.3])
    square([0.8,1.6], center=true);
}

module led2_hole() {
    translate([0,0,-infinity/2])
    linear_extrude(infinity)
    translate([8.0, 62.1])
    square([1.6,0.8], center=true);
}

module led1_body() {
    translate([0,0,-wall_thickness-led_z])
    linear_extrude(led_z)
    offset(2*nozzle_size)
    translate([31.2, 10.3])
    square([0.8,1.6], center=true);
}

module led2_body() {
    translate([0,0,-wall_thickness-led_z])
    linear_extrude(led_z)
    offset(2*nozzle_size)
    translate([8.0, 62.1])
    square([1.6,0.8], center=true);
}

module lcd() {
    hole()
    translate([6.5,44,0])
    cube([23.7,12.8,eps1]);
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
    x1 = button_x1 - button_w/2 - clearance_fit; // first
    x4 = button_x3 + button_w/2 + clearance_fit; // last
    x2 = x1 + (x4-x1)/3;
    x3 = x4 - (x4-x1)/3;
    y0 = button_y-button_h/2+button_l/2-clearance_fit;
    z0 = 2*wall_thickness+eps1;
    
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
    bottom_box();
    top_pcb_support();
    camera_support();
    led1_body();
    led2_body();
    button_body();
}

module top_holes() {
    led1_hole();
    led2_hole();
    button_holes();
    lcd();
    translate([0,-5.0,-wall_thickness-top_z])
    {
        usb();
        microsd();
    }
}

module camera_support() {
    translate([cam_x,cam_y,0])
    translate([-cam_d/2,-cam_d/2,-(top_z+pcb_z+wall_thickness)])
    cube([cam_d, cam_d, top_z+pcb_z]);
}

module top_pcb_support() {
    mirror([0,0,1])
    difference() {
        linear_extrude(wall_thickness+top_z+pcb_z)
        offset(wall_thickness)
        pcb();
        translate([0,0,wall_thickness+top_z])
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
    top_cover();
    bottom_pcb_support();
    bottom_camera_support();
    bidi();
}

module bottom_holes() {
    camera_hole();
    camera_cable();
    text_label();
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

module bottom_pcb_support() {
    cyl_z = wall_thickness+bottom_z;

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
    translate([-10,0,0])
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
    }
}

//bottom();
//rotate([0,180,0]) top();
//printer_ready();
assembly();

// not truncated 