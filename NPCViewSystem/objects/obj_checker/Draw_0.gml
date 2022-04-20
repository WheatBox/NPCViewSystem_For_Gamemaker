draw_self();
MyViewSystem.viewSysDrawDebug();

draw_text(0,40,fps);
draw_text(0,60,"Check Mode = " + (MyViewSystem.checkMode == ViewSysCheckMode.Fast ? "Fast" : "Quality"));
draw_text(0,80,"Press Space key to change the Check Mode.");

if(keyboard_check_pressed(vk_space)) {
	if(MyViewSystem.checkMode == ViewSysCheckMode.Fast) {
		MyViewSystem.viewSysSetCheckMode(ViewSysCheckMode.Quality);
	} else
	if(MyViewSystem.checkMode == ViewSysCheckMode.Quality) {
		MyViewSystem.viewSysSetCheckMode(ViewSysCheckMode.Fast);
	}
}

