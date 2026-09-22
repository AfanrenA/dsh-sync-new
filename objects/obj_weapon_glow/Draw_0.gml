// obj_weapon_glow Draw 事件
depth = 110;

if (!instance_exists(parent_weapon)) {
    instance_destroy();
    exit;
}

// ===== 使用 bbox 计算实际中心和尺寸 =====
var _cx = (parent_weapon.bbox_left + parent_weapon.bbox_right) / 2;
var _cy = (parent_weapon.bbox_top + parent_weapon.bbox_bottom) / 2;
var _half_w = (parent_weapon.bbox_right - parent_weapon.bbox_left) / 2;
var _half_h = (parent_weapon.bbox_bottom - parent_weapon.bbox_top) / 2;

// 考虑武器缩放
var _scale_x = parent_weapon.image_xscale;
var _scale_y = parent_weapon.image_yscale;

// 基础椭圆半径
var _base_rx = _half_w * abs(_scale_x);
var _base_ry = _half_h * abs(_scale_y);

// 光晕放大系数（比精灵大 30%）
var _glow_scale = 1.3;
var _rx = _base_rx * _glow_scale;
var _ry = _base_ry * _glow_scale;

// 限制最小尺寸
var _min_radius = 20;
if (_rx < _min_radius) _rx = _min_radius;
if (_ry < _min_radius) _ry = _min_radius;

// ===== 获取颜色 =====
var _color = parent_weapon.rarity_color;
if (is_undefined(_color) || _color == noone) {
    _color = scr_get_rarity_color(parent_weapon.rarity);
}
if (_color == noone || _color == undefined) {
    _color = c_white;
}

// 呼吸脉冲
pulse_timer += 0.03;
var _alpha = 0.15 + 0.10 * sin(pulse_timer);
var _pulse_scale = 1.0 + 0.06 * sin(pulse_timer * 0.7);

var _current_rx = _rx * _pulse_scale;
var _current_ry = _ry * _pulse_scale;

// ===== 绘制椭圆光晕 =====
gpu_set_blendmode(bm_add);

var _layers = 10;
for (var i = 0; i < _layers; i++) {
    var _t = i / _layers;
    var _layer_rx = _current_rx * (1 - _t * 0.85);
    var _layer_ry = _current_ry * (1 - _t * 0.85);
    var _a = _alpha * (1 - _t) * 0.8;
    
    draw_set_color(_color);
    draw_set_alpha(_a);
    
    draw_ellipse(_cx - _layer_rx, _cy - _layer_ry, 
                 _cx + _layer_rx, _cy + _layer_ry, 
                 false);
}

// 中心高光（小椭圆）
draw_set_color(c_white);
draw_set_alpha(_alpha * 0.2);
draw_ellipse(_cx - _current_rx * 0.15, _cy - _current_ry * 0.15,
             _cx + _current_rx * 0.15, _cy + _current_ry * 0.15,
             false);

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);