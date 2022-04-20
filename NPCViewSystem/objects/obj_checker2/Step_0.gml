image_angle -= 2;

MyViewSystem.viewSysSetCheckMode(obj_checker.MyViewSystem.checkMode);

MyViewSystem.viewSysSetPos(x,y);
MyViewSystem.viewSysSetDir(image_angle);
MyViewSystem.viewSysCheckLostTarget();

if(MyViewSystem.see_target == false) {
	MyViewSystem.targetReget();
}

