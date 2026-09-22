function scr_attack_thrown(_owner, _weapon, _tx, _ty) {
    if (!instance_exists(_weapon)) return false;
    if (_weapon.attack_cooldown > 0) return false;
    _weapon.attack_cooldown = _weapon.cooldown;

    // ---- ★★★ 飞刀：完全独立，不进入通用逻辑 ★★★ ----
    if (_weapon.weapon_id == "dagger") {
        var _proj = instance_create_layer(_owner.x, _owner.y, "Instances", obj_thrown_dagger);
        
        _proj.owner = _owner;
       // _proj.weapon = _weapon;
        _proj.direction = point_direction(_owner.x, _owner.y, _tx, _ty);
        _proj.image_angle = _proj.direction;
        _proj.speed = _weapon.throw_speed;
        _proj.damage = _weapon.damage;
        _proj.max_range = 600;
        _proj.bleed_damage = struct_exists(_weapon, "bleed_damage") ? _weapon.bleed_damage : 0;
        _proj.bleed_duration = struct_exists(_weapon, "bleed_duration") ? _weapon.bleed_duration : 0;
        _proj.bleed_interval = struct_exists(_weapon, "bleed_interval") ? _weapon.bleed_interval : 15;
        _proj.pierce = struct_exists(_weapon, "pierce") ? _weapon.pierce : false;
        _proj.element = struct_exists(_weapon, "element") ? _weapon.element : "none";
        _proj.element_damage = struct_exists(_weapon, "element_damage") ? _weapon.element_damage : 0;
        _proj.trail_color = struct_exists(_weapon, "trail_color") ? _weapon.trail_color : c_white;
        _proj.stick_duration = struct_exists(_weapon, "stick_duration") ? _weapon.stick_duration : 600;
        _proj.start_x = _owner.x;
        _proj.start_y = _owner.y;
        _proj.target_x = _tx;
        _proj.target_y = _ty;
        _proj.traveled = 0;
        if (variable_instance_exists(_weapon, "sprite") && _weapon.sprite != noone) {
            _proj.sprite_index = _weapon.sprite;
        }
        
        if (_weapon.visual_recoil > 0) {
            _weapon.recoil_timer = 6;
            _weapon.recoil_offset = -_weapon.visual_recoil;
        }
        
        show_debug_message("🗡️ 独立飞刀已发射");
		show_debug_message("🗡️ 独立飞刀已发射，ID: " + string(_proj));

        return true;
    }

    // ---- 通用投掷（炸弹等） ----
    var _proj_obj = _weapon.projectile_obj;
    if (_proj_obj == noone) return false;

    var _proj = instance_create_layer(_owner.x, _owner.y, "Instances", _proj_obj);
    
    _proj.weapon = _weapon;
    _proj.owner = _owner;
    _proj.target_x = _tx;
    _proj.target_y = _ty;
    _proj.start_x = _owner.x;
    _proj.start_y = _owner.y;
    _proj.speed = _weapon.throw_speed;
    _proj.max_range = 500;
    _proj.damage = _weapon.damage;
    
    if (variable_instance_exists(_weapon, "sprite") && _weapon.sprite != noone) {
        _proj.sprite_index = _weapon.sprite;
    }
    _proj.image_angle = point_direction(_owner.x, _owner.y, _tx, _ty);
    _proj.direction = point_direction(_owner.x, _owner.y, _tx, _ty);
    _proj.image_angle = _proj.direction;

    if (_weapon.is_explosive) {
        _proj.is_explosive = true;
        _proj.explosion_delay = _weapon.explosion_delay;
        _proj.explosion_radius = _weapon.explosion_radius;
        _proj.explosion_damage = _weapon.explosion_damage;
        _proj.gravity = _weapon.throw_gravity;
        _proj.life = _weapon.throw_life;
        _proj.element = _weapon.element ?? "";
        _proj.element_dot_damage = _weapon.element_dot_damage ?? 0;
        _proj.element_dot_duration = _weapon.element_dot_duration ?? 0;
        
        _proj.warning = instance_create_layer(_tx, _ty, "Effects", obj_explosion_warning);
        _proj.warning.radius = _weapon.warning_radius ?? 120;
        _proj.warning.max_radius = _weapon.warning_radius ?? 120;
        _proj.warning.duration = _weapon.warning_duration ?? 90;
        _proj.warning.base_alpha = _weapon.warning_alpha ?? 0.25;
        _proj.warning.scale = _weapon.warning_scale_start ?? 0.3;
        _proj.warning.timer = 0;
        _proj.warning.image_alpha = 0.25;
    }
    
    if (_weapon.visual_recoil > 0) {
        _weapon.recoil_timer = 6;
        _weapon.recoil_offset = -_weapon.visual_recoil;
    }
    
    return true;
}