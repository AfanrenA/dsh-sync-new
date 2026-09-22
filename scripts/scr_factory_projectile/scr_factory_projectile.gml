// scr_factory_projectile_create.gml
function scr_factory_projectile_create(projectile_id, spawn_x, spawn_y, fire_dir, owner_id, target_object) {
    var _data = data_projectile_get(projectile_id);
    if (_data == undefined) return noone;
    
    var _obj = _data.object != undefined ? _data.object : obj_slash_base;
    var inst = instance_create_layer(spawn_x, spawn_y, "Instances", _obj);
    
    // 投射物自身属性
    inst.projectile_id = projectile_id;
    inst.sprite_index = _data.sprite;
    // ★ 用 move_speed / move_dir，不碰内置 speed/direction
    inst.move_speed = _data.speed;
    inst.move_dir = fire_dir;
    inst.life = _data.life;
    inst.max_life = _data.life;
    inst.damage = _data.damage;
    inst.owner_id = owner_id;
    inst.target_object = target_object;
    inst.element_type = _data.element_type;
    
    // ===== 缩放相关 =====
    inst.scale_start = _data.scale_start != undefined ? _data.scale_start : 0.5;
    inst.scale_end = _data.scale_end != undefined ? _data.scale_end : 2.0;
    inst.scale_frames = _data.scale_frames != undefined ? _data.scale_frames : 15;
    inst.image_xscale = inst.scale_start;
    inst.image_yscale = inst.scale_start;
    inst.image_angle = fire_dir;
    
    inst.scale_speed = (inst.scale_end - inst.scale_start) / inst.scale_frames;
    
    // ===== 颜色 =====
    if (_data.color != undefined) {
        inst.color = _data.color;
    } else {
        inst.color = c_white;
    }
    
    // ===== 距离控制 =====
    inst.max_distance = _data.max_distance != undefined ? _data.max_distance : 500;
    inst.min_distance = _data.min_distance != undefined ? _data.min_distance : 50;
    inst.traveled_distance = 0;
    
    inst.knockback_power = 5.0;
    inst.stun_duration = 0.15;
    
    return inst;
}