// ======================================================================
// obj_weapon_glow - Draw 事件（V3 标准）
// ======================================================================

if (!instance_exists(parent_weapon)) {
    instance_destroy();
    exit;
}

// ★ 图层在武器下方（depth 比武器大）★
depth = 50;

// 获取武器精灵中心位置
var _sprite = parent_weapon.sprite_index;
var _cx = parent_weapon.x;
var _cy = parent_weapon.y;

// ★ 修复：检查精灵是否有效
if (_sprite != noone && _sprite != -1 && sprite_exists(_sprite)) {
    var _sprite_w = sprite_get_width(_sprite);
    var _sprite_h = sprite_get_height(_sprite);
    var _xoffset = sprite_get_xoffset(_sprite);
    var _yoffset = sprite_get_yoffset(_sprite);
    
    var _center_x = (_sprite_w * 0.5) - _xoffset;
    var _center_y = (_sprite_h * 0.5) - _yoffset;
    
    var _scale_x = parent_weapon.image_xscale;
    var _scale_y = parent_weapon.image_yscale;
    var _angle = parent_weapon.image_angle;
    
    _cx = parent_weapon.x + lengthdir_x(_center_x * _scale_x, _angle) + lengthdir_y(_center_y * _scale_y, _angle + 90);
    _cy = parent_weapon.y + lengthdir_y(_center_x * _scale_x, _angle) + lengthdir_y(_center_y * _scale_y, _angle + 90);
}

// ★ 获取品质颜色
var _color = parent_weapon.rarity_color;
if (is_undefined(_color)) {
    var _cfg = data_rarity_get(parent_weapon.rarity);
    _color = _cfg.ui_color;
}

// ★ 呼吸脉冲
pulse_timer += 0.03;
var _alpha = 0.10 + 0.08 * sin(pulse_timer);
var _scale = 1.0 + 0.06 * sin(pulse_timer * 0.7);
var _radius = glow_radius * _scale;

// ★ 绘制光晕
gpu_set_blendmode(bm_add);

var _steps = 8;
for (var i = 0; i < _steps; i++) {
    var _t = i / _steps;
    var _r = _radius * (1 - _t * 0.80);
    var _a = _alpha * (1 - _t) * 0.8;
    draw_set_color(_color);
    draw_set_alpha(_a);
    draw_circle(_cx, _cy, _r, false);
}

// 中心高光
draw_set_color(c_white);
draw_set_alpha(_alpha * 0.15);
draw_circle(_cx, _cy, _radius * 0.2, false);

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);