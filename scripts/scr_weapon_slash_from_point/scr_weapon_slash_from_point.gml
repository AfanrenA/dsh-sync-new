// ======================================================================
// scr_weapon_slash_from_point.gml
// 从指定点发射剑气
// ======================================================================

function scr_weapon_slash_from_point(_weapon, _x, _y) {
    var _data = data_weapon_get(_weapon.weapon_id);
    if (_data == undefined || _data.slash_sprite == noone) return;
    
    var _slash = instance_create_layer(_x, _y, "Effects", _data.slash_sprite);
    if (_slash != noone) {
        _slash.direction = _weapon.base_angle;
        _slash.speed = _data.slash_speed;
        _slash.life = _data.slash_life;
        _slash.damage = _weapon.damage;
        _slash.owner = _weapon.owner;
        _slash.image_angle = _weapon.base_angle;
        _slash.image_xscale = _data.slash_scale_start;
        _slash.image_yscale = _data.slash_scale_start;
    }
}