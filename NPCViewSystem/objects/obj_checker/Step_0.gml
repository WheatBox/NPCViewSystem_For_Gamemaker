var l = -keyboard_check(ord("A"));
var r = keyboard_check(ord("D"));
var u = -keyboard_check(ord("W"));
var d = keyboard_check(ord("S"));

x += (l + r) * 4;
y += (u + d) * 4;

image_angle = point_direction(x,y,mouse_x,mouse_y);

MyViewSystem.viewSysSetPos(x,y);
MyViewSystem.viewSysSetDir(image_angle);
MyViewSystem.viewSysCheckLostTarget();

if(MyViewSystem.see_target == false) {
	MyViewSystem.targetReget();
}

