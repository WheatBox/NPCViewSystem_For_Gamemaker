// 该脚本由B站小UP @小麦盒子 编写
// https://space.bilibili.com/317062050

function getDistanceFromPos(_x1, _y1, _x2, _y2) { // 获取两个点之间的直线距离
	return sqrt(power(abs(_x1 - _x2), 2) + power(abs(_y1 - _y2), 2));
}

enum ViewSysPlatformDir {
	Left = 180,
	Right = 0,
}

enum ViewSysCheckMode {
	Fast = 0, // 根据目标的 中心点 进行检测（默认模式）
	Quality = 1, // 根据目标的 中心点、左上、右上、左下、右下 进行检测
}

function ViewSystem() constructor {
	x = 0;
	y = 0;
	// 此处的 x 和 y 是 该数据结构定义的对象 里的 x 和 y
	// 而不是所属的 instance 的 x 和 y
	
	target_hateDistance = 360; // 仇恨距离，只要发现了目标，那么在目标离开自身该距离之前一直处于仇恨状态
	absoluteDistance = 80; // 绝对距离，即从背后也能察觉到目标的存在
	viewDistance = 260; // 视野距离
	myfov = 90; // 视野角度
	eyexadd = 0; // 调整眼睛的x坐标
	eyeyadd = 0; // 调整眼睛的y坐标
	
	nearest_ins = noone; // 请忽略我，我为targetReget()函数诞生
	nearest_distance = 999999; // 请忽略我，我为targetReget()函数诞生
	
	target = noone; // 追击目标，noone为无目标
	see_target = false; // 是否看到目标
	
	targetParent = noone; // 目标类别，建议设为目标obj的父对象obj
	wallObj = noone; // 视线遮挡的墙体obj
	
	checkMode = ViewSysCheckMode.Fast; // 对于目标的检测模式
	viewDir = ViewSysPlatformDir.Right; // 当前面向的方向(Direction)
	
	
	function viewSysVarInit(_targetParent,_wallObj,_x,_y,_target_hateDistance = 360, _absoluteDistance = 80, _viewDistance = 260, _myfov = 90, _eyexadd = 0, _eyeyadd = 0) {
		targetParent = _targetParent;
		wallObj = _wallObj;
		viewSysSetPos(_x,_y);
		target_hateDistance = _target_hateDistance;
		absoluteDistance = _absoluteDistance;
		viewDistance = _viewDistance;
		myfov = _myfov;
		eyexadd = _eyexadd;
		eyeyadd = _eyeyadd;
		
		target = noone;
		see_target = false;
	}
	
	function viewSysSetCheckMode(_ViewSysCheckMode) {
		checkMode = _ViewSysCheckMode;
	}
	
	function viewSysSetPos(_x, _y) { // 设置视野系统的x和y坐标
		// 你可以直接设置为眼睛的x和y
		// 不过我推荐一般情况下设为obj的x和y
		// 然后通过 eyexadd 和 eyeyadd 这两个变量来进一步确定眼睛的x和y坐标
		// 为何这么推荐？因为考虑到假设你做了一条巨蛇
		// 然后这条巨蛇头总是游来游去，那么你可能需要一种更方便的管理模式来管理这些参数
		// 当然，具体请按照你自己的喜好来
		x = _x;
		y = _y;
	}
	
	function viewSysSetEyeadd(_eyexadd, _eyeyadd) { // 设置视野系统中眼睛的坐标的调整值
		eyexadd = _eyexadd;
		eyeyadd = _eyeyadd;
	} 
	
	function viewSysSetTargetParent(_obj_targetParent) { // 设置目标类别，建议设为目标obj的父对象obj
		targetParent = _obj_targetParent;
	}
	
	function viewSysSetWallObj(_wallObj) { // 设置视线遮挡的墙体obj
		wallObj = _wallObj;
	}
	
	function viewSysXscaleToPlatformDir(_image_xscale) { // 根据_image_xscale设置横板视角下的方向(Direction)
		// 当然，这里主要是通过 >= 0 来表示朝右，< 0 表示朝左
		// 所以此处的_image_xscale不一定一定非得填image_xscale
		viewDir = _image_xscale >= 0 ? ViewSysPlatformDir.Right : ViewSysPlatformDir.Left;
	}
	
	function viewSysSetDir(_dir) { // 直接设定方向
		viewDir = direction_get_standard(_dir);
	}
	
	function targetInit() { // 我不知道该怎么解释这个函数，总之，十有八九你用不到
		nearest_ins = noone;
		nearest_distance = 999999;
		
		target = noone;
		see_target = false;
	}
	
	
	function viewSysCheckLostTarget() { // 检查是否丢失目标（目标ins不存在 或 超出仇恨距离）
		if(target == noone) {
			see_target = false;
			return;
		}
		if(instance_exists(target)) {
			switch(checkMode) {
				case ViewSysCheckMode.Fast:
					if(
						getDistanceFromPos(x + eyexadd, y + eyeyadd, bbox_get_center_x(target), bbox_get_center_y(target)) > target_hateDistance
					) {
						targetInit();
					}
					break;
				case ViewSysCheckMode.Quality:
					if(
						getDistanceFromPos(x + eyexadd, y + eyeyadd, bbox_get_center_x(target), bbox_get_center_y(target)) > target_hateDistance
						&& getDistanceFromPos(x + eyexadd, y + eyeyadd, target.bbox_left, target.bbox_top) > target_hateDistance
						&& getDistanceFromPos(x + eyexadd, y + eyeyadd, target.bbox_right, target.bbox_top) > target_hateDistance
						&& getDistanceFromPos(x + eyexadd, y + eyeyadd, target.bbox_left, target.bbox_bottom) > target_hateDistance
						&& getDistanceFromPos(x + eyexadd, y + eyeyadd, target.bbox_right, target.bbox_bottom) > target_hateDistance
					) {
						targetInit();
					}
					break;
			}
		} else {
			targetInit();
		}
	}
	
	function isPosInMyView(_eyex,_eyey,_checkx,_checky,_mydir,_fov) { // 判断某一坐标是否在视野角度范围内
		var _dir = point_direction(_eyex,_eyey,_checkx,_checky);
		if((direction_get_standard(_dir) < direction_get_standard(_mydir + _fov / 2) && direction_get_standard(_dir) > direction_get_standard(_mydir - _fov / 2))
		|| (_dir < _mydir + _fov / 2 && _dir > _mydir - _fov / 2)) {
			return (collision_line(_eyex,_eyey,_checkx,_checky,wallObj,true,false) == noone); // 射线碰撞
		}
		else {
			return false;
		}
	}
	
	function isInsInMyView(_eyex,_eyey,_checkobj,_mydir,_fov) { // 判断目标是否在视野角度范围内
		switch(checkMode) {
			case ViewSysCheckMode.Fast:
				return (
					isPosInMyView(_eyex,_eyey,bbox_get_center_x(_checkobj),bbox_get_center_y(_checkobj),_mydir,_fov) // 中间点
				);
				break;
			case ViewSysCheckMode.Quality:
				return (
					isPosInMyView(_eyex,_eyey,bbox_get_center_x(_checkobj),bbox_get_center_y(_checkobj),_mydir,_fov) // 中间点
					|| isPosInMyView(_eyex,_eyey,_checkobj.bbox_left,_checkobj.bbox_top,_mydir,_fov) // 左上
					|| isPosInMyView(_eyex,_eyey,_checkobj.bbox_right,_checkobj.bbox_top,_mydir,_fov) // 右上
					|| isPosInMyView(_eyex,_eyey,_checkobj.bbox_left,_checkobj.bbox_bottom,_mydir,_fov) // 左下
					|| isPosInMyView(_eyex,_eyey,_checkobj.bbox_right,_checkobj.bbox_bottom,_mydir,_fov) // 右下
				);
				break;
		}
	}
	
	function doViewCheckInDistance(_eyex, _eyey, _checkobj, _distance) { // 判断目标是否在视野距离范围内
		switch(checkMode) {
			case ViewSysCheckMode.Fast:
				return (
					getDistanceFromPos(_eyex, _eyey, bbox_get_center_x(_checkobj), bbox_get_center_y(_checkobj)) <= _distance // 中间点
				);
				break;
			case ViewSysCheckMode.Quality:
				return (
					getDistanceFromPos(_eyex, _eyey, bbox_get_center_x(_checkobj), bbox_get_center_y(_checkobj)) <= _distance // 中间点
					|| getDistanceFromPos(_eyex, _eyey, _checkobj.bbox_left, _checkobj.bbox_top) <= _distance // 左上
					|| getDistanceFromPos(_eyex, _eyey, _checkobj.bbox_right, _checkobj.bbox_top) <= _distance // 右上
					|| getDistanceFromPos(_eyex, _eyey, _checkobj.bbox_left, _checkobj.bbox_bottom) <= _distance // 左下
					|| getDistanceFromPos(_eyex, _eyey, _checkobj.bbox_right, _checkobj.bbox_bottom) <= _distance // 右下
				);
				break;
		}
	}

	// 判断能否看到目标
	function doView(_x = x,_y = y,_viewDistance = viewDistance,_checkobj = targetParent,_mydir = viewDir,_fov = myfov,_eyexadd = eyexadd,_eyeyadd = eyeyadd,_absoluteDistance = absoluteDistance) {
		// x  y  视野距离  搜寻目标  我当前的朝向  我的视野范围角度  我的眼睛的X 和 Y 的调整值  只要到_absolute_distance距离之内就不管看没看到目标都一律视为看到
		
		if(instance_exists(_checkobj)) {
			if(doViewCheckInDistance(_x + _eyexadd, _y + _eyeyadd, _checkobj, _absoluteDistance)) { // 怪物即使背对玩家，到了一定距离内玩家依然会被发现
				see_target = true;
				return true;
			}
			if(doViewCheckInDistance(_x + _eyexadd, _y + _eyeyadd, _checkobj, _viewDistance)) { // 判断目标是否在距离内
				if(isInsInMyView(_x + _eyexadd,_y + _eyeyadd,_checkobj,_mydir,_fov)) { // 判断目标是否在视野范围内
					see_target = true;
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		} else {
			return false;
		}
	}
	
	function targetReget(_x = x,_y = y,_viewDistance = viewDistance,_checkobj = targetParent,_mydir = viewDir,_fov = myfov,_eyexadd = eyexadd,_eyeyadd = eyeyadd,_absoluteDistance = absoluteDistance) { // 重新设定目标
		_mydir = direction_get_standard(_mydir);
		targetInit();
		x = _x;
		y = _y;
		for(var i = 0; i < instance_number(_checkobj); i++) {
			var _ins = instance_find(_checkobj,i);
			if(_ins != noone) {
				if(doView(_x,_y,_viewDistance,_ins,_mydir,_fov,_eyexadd,_eyeyadd,_absoluteDistance)) {
					with(_ins) {
						var _dis = getDistanceFromPos(bbox_get_center_x(id), bbox_get_center_y(id), other.x + other.eyexadd, other.y + other.eyeyadd);
						if(_dis <= other.nearest_distance) {
							other.nearest_distance = _dis;
							other.nearest_ins = id;
						}
					}
				}
			}
		}
		
		target = nearest_ins;
		return target;
	}
	
	
	function viewSysDrawDebug() {
		var _col = draw_get_color();
		var _alpha = draw_get_alpha();
		
		draw_set_alpha(1);
		draw_set_color(c_blue);
		draw_circle(x + eyexadd, y + eyeyadd, target_hateDistance, true);
		draw_set_color(c_red);
		draw_circle(x + eyexadd, y + eyeyadd, absoluteDistance, true);
		if(see_target) {
			draw_set_color(c_red);
		} else {
			draw_set_color(c_white);
		}
		var _line1x = lengthdir_x(viewDistance, viewDir + myfov / 2);
		var _line1y = lengthdir_y(viewDistance, viewDir + myfov / 2);
		var _line2x = lengthdir_x(viewDistance, viewDir - myfov / 2);
		var _line2y = lengthdir_y(viewDistance, viewDir - myfov / 2);
		draw_line(x + eyexadd, y + eyeyadd, x + eyexadd + _line1x, y + eyeyadd + _line1y);
		draw_line(x + eyexadd, y + eyeyadd, x + eyexadd + _line2x, y + eyeyadd + _line2y);
		
		var _pos1x = 0;
		var _pos1y = 0;
		var _pos2x = 0;
		var _pos2y = 0;
		var _precision = 10;
		for(var i = 0; i < _precision; i++) {
			_pos1x = x + eyexadd + lengthdir_x(viewDistance, viewDir + myfov / 2 - myfov / _precision * i);
			_pos1y = y + eyeyadd + lengthdir_y(viewDistance, viewDir + myfov / 2 - myfov / _precision * i);
			_pos2x = x + eyexadd + lengthdir_x(viewDistance, viewDir + myfov / 2 - myfov / _precision * (i + 1));
			_pos2y = y + eyeyadd + lengthdir_y(viewDistance, viewDir + myfov / 2 - myfov / _precision * (i + 1));
			draw_line(_pos1x, _pos1y, _pos2x, _pos2y);
		}
		
		draw_set_color(c_green);
		draw_text(x,y,target);
		
		draw_set_alpha(_alpha);
		draw_set_color(_col);
	}
}


