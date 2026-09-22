/// @description 提供统一瞄准目标 + 附件瞄准状态检查

var _player = instance_find(obj_player_base, 0);
if (!instance_exists(_player)) {
    is_active = false;
    exit;
}

// ===== ★ 第一步：不管装备什么，都每帧算 aim_target 写到玩家身上 =====
//   这是"全项目唯一的鼠标世界坐标来源"
var _cam = view_camera[0];
var _gx = device_mouse_x_to_gui(0);
var _gy = device_mouse_y_to_gui(0);
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _vw = camera_get_view_width(_cam);
var _vh = camera_get_view_height(_cam);

var _target_x = camera_get_view_x(_cam) + _gx * (_vw / _gw);
var _target_y = camera_get_view_y(_cam) + _gy * (_vh / _gh);

_player.aim_target_x = _target_x;
_player.aim_target_y = _target_y;
_player.aim_valid = true;

// ===== 第二步：附件专属逻辑（画爆炸半径圈） =====
if (!instance_exists(_player.skill_instance)) {
    is_active = false;
    exit;
}

var _sk = _player.skill_instance;
if (!variable_instance_exists(_sk, "type") || _sk.type != "附件") {
    is_active = false;
    exit;
}

// 更新半径
if (_sk.data != undefined) {
    var _proj = data_projectile_get(_sk.data.projectile_id);
    if (_proj != undefined) {
        radius = _proj.explosion_radius;
    }
}

if (_sk.aiming) {
    is_active = true;
    // ★ 附件自己的 aim_target 继续写（兼容 scr_attachment_fire）
    _sk.aim_target_x = _target_x;
    _sk.aim_target_y = _target_y;
    x = _target_x;
    y = _target_y;
} else {
    var _grenade = noone;
    with (obj_grenade_launcher) {
        if (is_player_grenade) {
            _grenade = id;
        }
    }
    if (instance_exists(_grenade)) {
        is_active = true;
        x = _grenade.end_x;
        y = _grenade.end_y;
    } else {
        is_active = false;
    }
}