/// @description 摄像机跟随 + 震动

// 获取目标
if (target == noone || !instance_exists(target)) {
    target = instance_find(obj_player_base, 0);
    if (!instance_exists(target)) return;
}

// ===== 获取震动值 =====
var _effect = instance_find(obj_screen_effect, 0);
if (instance_exists(_effect)) {
    shake_x = _effect.shake_x;
    shake_y = _effect.shake_y;
} else {
    shake_x = 0;
    shake_y = 0;
}

// ===== 计算目标位置（含震动） =====
var _target_x = target.x + shake_x;
var _target_y = target.y + shake_y;

// ===== 获取当前视图位置 =====
var _view = view_camera[0];
var _current_x = camera_get_view_x(_view);
var _current_y = camera_get_view_y(_view);

// 后坐力期间：相机锁定当前位置
var _is_recoiling = variable_instance_exists(target, "fire_recoil_timer") 
                    && target.fire_recoil_timer > 0;

if (_is_recoiling) {
    // 相机不动
    _new_x = _current_x;
    _new_y = _current_y;
} else {
    _new_x = lerp(_current_x, _target_x - display_get_gui_width() / 2, 0.1);
    _new_y = lerp(_current_y, _target_y - display_get_gui_height() / 2, 0.1);
}

// ===== 应用摄像机位置 =====
camera_set_view_pos(_view, _new_x, _new_y);

//show_debug_message("[相机] recoil=" + string(_is_recoiling) + " | cam=(" + string(_current_x) + "," + string(_current_y) + ")");