// scr_attack_ranged.gml
// 远程攻击行为（生成子弹 + 扣弹 + 冷却 + 后坐力）
function scr_attack_ranged(_owner, _weapon = noone) {
    if (!_owner.is_alive || _owner.is_dead) return;
    
    if (!instance_exists(_weapon)) {
        _weapon = _owner.current_weapon;
    }
    if (!instance_exists(_weapon)) return;
    
    var _data = data_weapon_get(_weapon.weapon_id);
    if (_data == undefined) return;
    
    // ===== 弹匣检查 =====
    if (_weapon.is_reloading) return;
    
    if (_weapon.current_ammo <= 0) {
    _weapon.is_reloading = true;
    _weapon.reload_progress = 1;      // ★ 从 1 开始
    _weapon.reload_timer = _weapon.reload_time_per_bullet;
        show_debug_message("[RANGED] 弹匣空，开始换弹");
        return;
    }
    
    // ===== 扣一发 =====
    _weapon.current_ammo -= 1;
    
    // ===== 触发冷却 =====
       // ★ 遗物：攻击冷却倍率
    var _relic_cd = 1.0;
    if (variable_instance_exists(_owner, "relic_attack_cd_mult")) {
        _relic_cd = _owner.relic_attack_cd_mult;
    }
    _weapon.cooldown_timer = _data.attack_speed * 60 * _relic_cd;
    
            // ===== 枪口位置（沿武器朝向偏移，自动跟随左右） =====
    var _fire_angle = _weapon.image_angle;
    var _fp_x = variable_struct_exists(_data, "fire_point_x") ? _data.fire_point_x : 0;
    var _fp_y = variable_struct_exists(_data, "fire_point_y") ? _data.fire_point_y : 0;
    var _fire_x = _weapon.x + lengthdir_x(_fp_x, _fire_angle) + lengthdir_x(_fp_y, _fire_angle + 90);
    var _fire_y = _weapon.y + lengthdir_y(_fp_x, _fire_angle) + lengthdir_y(_fp_y, _fire_angle + 90);
    
    /*★ DEBUG：看武器状态和枪口位置
    show_debug_message("===== 枪口 Debug =====");
    show_debug_message("weapon.x = " + string(_weapon.x) + " | weapon.y = " + string(_weapon.y));
    show_debug_message("image_angle = " + string(_weapon.image_angle));
    show_debug_message("image_xscale = " + string(_weapon.image_xscale) + " | image_yscale = " + string(_weapon.image_yscale));
    show_debug_message("fire_point_x = " + string(_fp_x) + " | fire_point_y = " + string(_fp_y));
    show_debug_message("fire_x = " + string(_fire_x) + " | fire_y = " + string(_fire_y));
    show_debug_message("偏移量 dx = " + string(_fire_x - _weapon.x) + " | dy = " + string(_fire_y - _weapon.y));
    show_debug_message("=====================");*/
    
    // ===== 生成子弹 =====
    var _bullet = instance_create_layer(_fire_x, _fire_y, "Instances", _data.bullet_object);
    if (instance_exists(_bullet)) {
                _bullet.move_dir = _fire_angle;
        _bullet.move_speed = _data.bullet_speed;
        _bullet.life = _data.bullet_life;
                _bullet.damage = _weapon.final_stats.base_damage * scr_relic_get_damage_mult(_owner);
        _bullet.owner_id = _owner;
        _bullet.image_angle = _fire_angle;
        
        // ===== 子弹自带结算数据（脱离武器独立） =====
        _bullet.has_projectile_crit = variable_struct_exists(_data, "can_crit") && _data.can_crit;
        if (_bullet.has_projectile_crit) {
            _bullet.projectile_crit_chance = variable_struct_exists(_data, "crit_chance") ? _data.crit_chance : 0.1;
            _bullet.projectile_crit_multiplier = variable_struct_exists(_data, "crit_multiplier") ? _data.crit_multiplier : 1.5;
        }
        _bullet.knockback_power = variable_struct_exists(_data, "knockback_power") ? _data.knockback_power : 3.0;
        _bullet.stun_duration = variable_struct_exists(_data, "stun_duration") ? _data.stun_duration : 0.1;
    }
    
    // ===== 视觉后坐力 =====
    if (variable_struct_exists(_data, "visual_recoil") && _data.visual_recoil > 0) {
        _weapon.recoil_timer = 15;
        _weapon.recoil_offset = _data.visual_recoil;
        _weapon.recoil_angle = _fire_angle;
    }
    
    // ===== 枪口火花（从枪口出，不是武器中心） =====
    scr_muzzle_sparks(_fire_x, _fire_y, _fire_angle);
    
    show_debug_message("[RANGED] 射击 | 剩余弹药: " + string(_weapon.current_ammo) + "/" + string(_weapon.max_ammo));
}