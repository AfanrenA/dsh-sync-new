/// @function scr_hitbox_update_position(_hitbox)
/// @param {id} _hitbox Hitbox 实例
/// @description 跟随武器尖端更新位置

function scr_hitbox_update_position(_hitbox) {
    var _weapon = _hitbox.weapon_ref;
    if (!instance_exists(_weapon)) {
        instance_destroy(_hitbox);
        return;
    }
    
    var _sprite = _weapon.sprite_index;
    var _sprite_w = sprite_get_width(_sprite);
    var _origin_x = sprite_get_xoffset(_sprite);
    var _weapon_length = _sprite_w - _origin_x;
    var _fire_dist = _weapon_length + 5;
    var _angle = _weapon.image_angle;
    
    var _base_x = _weapon.x + lengthdir_x(_fire_dist, _angle);
    var _base_y = _weapon.y + lengthdir_y(_fire_dist, _angle);
    
    var _data = _weapon.entity_data;
    var _offset_x = (_data.hitbox_offset_x != undefined) ? _data.hitbox_offset_x : 0;
    var _offset_y = (_data.hitbox_offset_y != undefined) ? _data.hitbox_offset_y : 0;
    var _perp_angle = _angle + 90;
    
    _hitbox.x = _base_x + lengthdir_x(_offset_x, _angle) + lengthdir_x(_offset_y, _perp_angle);
    _hitbox.y = _base_y + lengthdir_y(_offset_x, _angle) + lengthdir_y(_offset_y, _perp_angle);
}