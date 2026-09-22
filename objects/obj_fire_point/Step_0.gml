/// @description 近战发射点 - 使用 image_angle（跟随挥砍弧线）

if (!instance_exists(weapon_ref)) {
    instance_destroy();
    exit;
}

var _sprite = weapon_ref.sprite_index;
if (_sprite == noone) {
    x = weapon_ref.x;
    y = weapon_ref.y;
    exit;
}

var _sprite_w = sprite_get_width(_sprite);
var _origin_x = sprite_get_xoffset(_sprite);
var _weapon_length = _sprite_w - _origin_x;

var _scale = abs(weapon_ref.image_xscale);
var _flip = sign(weapon_ref.image_xscale);
var _fire_dist = (_weapon_length * _scale * _flip) - 20;

// ★ 近战：使用 image_angle（跟随挥砍弧线）★
var _angle = weapon_ref.image_angle;

var _offset_x = 0;
var _offset_y = 0;
var _data = data_weapon_get(weapon_ref.weapon_id);
if (_data != undefined) {
    if (variable_struct_exists(_data, "fire_offset_x")) _offset_x = _data.fire_offset_x;
    if (variable_struct_exists(_data, "fire_offset_y")) _offset_y = _data.fire_offset_y;
}
if (_flip < 0) _offset_x = -_offset_x;

var _base_x = weapon_ref.x + lengthdir_x(_fire_dist, _angle);
var _base_y = weapon_ref.y + lengthdir_y(_fire_dist, _angle);
var _perp_angle = _angle + 90;
x = _base_x + lengthdir_x(_offset_x, _angle) + lengthdir_x(_offset_y, _perp_angle);
y = _base_y + lengthdir_y(_offset_x, _angle) + lengthdir_y(_offset_y, _perp_angle);