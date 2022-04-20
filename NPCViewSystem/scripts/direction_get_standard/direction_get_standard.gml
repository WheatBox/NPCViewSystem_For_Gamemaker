function direction_get_standard(_dir) { // 使得方向区间控制在-180~180之间
	while(_dir < -180) {
		_dir += 360;
	}
	while(_dir > 180) {
		_dir -= 360;
	}
	return _dir;
}


