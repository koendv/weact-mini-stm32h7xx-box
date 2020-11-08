/*
 * Box for WeAct-TC Mini-STM32H7xx.
 */


eps1=0.001;
eps2=2*eps1;
infinity=100;
inch=25.4;

top_z=6.0;    // top components
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
    intersection() {    
        rotate([-90,0,0])
        linear_extrude(infinity)
        offset(clearance_fit)
        hull()
        projection()
        rotate([90,0,0])
        children();
    
        linear_extrude(infinity)
        offset(clearance_fit)
        hull()
        projection()
        children();
    }
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

module led1() {
    hole()
    import("led1.stl");
}

module led2() {
    hole()
    import("led2.stl");
}

module lcd() {
    translate([6.5,44,0]) {
        hole()
        cube([23.7,12.8,1]);
    }
}

module buttons() {
    hole()
    hull()
    import("buttons.stl");
}

module usb() {
    contour()
    import("usb.stl");
}

module microsd() {
    contour()
    translate([0,0,pcb_z/2])
    import("microsd.stl");
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
    top_cover();
    camera_support();
    top_pcb_support();
}

module top_holes() {
    led1();
    led2();
    buttons();
    lcd();
}

module camera_support() {
    translate([cam_x,cam_y,0])
    translate([-cam_d/2,-cam_d/2,-(top_z+pcb_z+wall_thickness)])
    cube([cam_d, cam_d, top_z+pcb_z]);
}

module top_pcb_support() {
    module top_buttress() {
       hull() { 
        translate([0,0,-support_z])
        cube([support_x, support_x, eps1]);
        cube([support_z, support_x, eps1]);
        }
    }
    support_x=0.1*inch;
    support_y=22*0.1*inch;
    support_z=wall_thickness+top_z;
    translate([w2-r1,h2/2,-support_z/2])
    cube([support_x,support_y,support_z], center=true);
    translate([r1,h2/2,-support_z/2])
    cube([support_x,support_y,support_z], center=true);
    translate([r1/2,h2/2+0.2*inch,0])
    top_buttress();
    translate([w2-r1/2,h2/2+0.2*inch,0])
    mirror([1,0,0])
    top_buttress();
    translate([r1/2,h2/2-0.6*inch,0])
    top_buttress();
    translate([w2-r1/2,h2/2-0.6*inch,0])
    mirror([1,0,0])
    top_buttress();
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
    bidi();
}

module bottom_holes() {
    translate([0,-5.0,wall_thickness+bottom_z+pcb_z]){
        usb();
        microsd();
    }
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
        %translate([0,0,wall_thickness+bottom_z+pcb_z+top_z+wall_thickness])
        render()
        top();
        
        if (1)
        %render()
        bottom();
        
        if (1)
        translate([0,0,wall_thickness+bottom_z])
        color("Green")
        pcb_3d();
    }
}

//bottom();
//rotate([0,180,0]) top();
printer_ready();
//assembly();

// not truncated 