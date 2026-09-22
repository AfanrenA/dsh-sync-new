// scr_hitbox_create.gml
function scr_hitbox_create(weapon_ref, owner_id, damage, life_frames, target_object, behavior = "damage_only") {
    var _data = data_weapon_get(weapon_ref.weapon_id);
    if (_data == undefined) return noone;
    
    // 精灵尺寸
    var _sprite = weapon_ref.sprite_index;
    var _sprite_w = sprite_get_width(_sprite);
    var _sprite_h = sprite_get_height(_sprite);
    var _origin_x = sprite_get_xoffset(_sprite);
    
    // 武器长度
    var _weapon_length = _sprite_w - _origin_x;
    var _fire_dist = _weapon_length + 5;
    
    // 角度
    var _angle = weapon_ref.image_angle;
    var _base_x = weapon_ref.x + lengthdir_x(_fire_dist, _angle);
    var _base_y = weapon_ref.y + lengthdir_y(_fire_dist, _angle);
    
    // 偏移
    var _offset_x = (_data.hitbox_offset_x != undefined) ? _data.hitbox_offset_x : 0;
    var _offset_y = (_data.hitbox_offset_y != undefined) ? _data.hitbox_offset_y : 0;
    var _perp_angle = _angle + 90;
    
    var _hx = _base_x + lengthdir_x(_offset_x, _angle) + lengthdir_x(_offset_y, _perp_angle);
    var _hy = _base_y + lengthdir_y(_offset_x, _angle) + lengthdir_y(_offset_y, _perp_angle);
    
    // 创建 Hitbox
    var hitbox = instance_create_layer(_hx, _hy, "Instances", obj_hitbox);
    
    hitbox.weapon_ref = weapon_ref;
    hitbox.owner_id = owner_id;
    hitbox.damage = damage;
    hitbox.life_frames = life_frames;
    hitbox.target_object = target_object;
    hitbox.weapon_length = _weapon_length;
    hitbox.hit_radius = max(_sprite_h * 0.6, 15);
    
    // ===== ★ 删除 can_deflect =====
    // hitbox.can_deflect = can_deflect;  ← 删除这行
    
    // ===== 行为模式 =====
    hitbox.behavior = behavior;
    hitbox.hitbox_behavior = behavior;
    
    // ===== 受击反馈参数 =====
    hitbox.knockback_power = (_data.knockback_power != undefined) ? _data.knockback_power : 5.0;
    hitbox.stun_duration = (_data.stun_duration != undefined) ? _data.stun_duration : 0.15;
    
    // ===== 已命中标记 =====
    hitbox.has_hit = false;
    
    return hitbox;
}