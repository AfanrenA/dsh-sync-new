/// @description 附件发射（枪口抬高 + 插值轨迹 + 生成飞行物 + 后坐力）
/// @param {id} owner 持有者
/// @param {id} skill 附件实例
/// @param {id} weapon 武器实例
function scr_attachment_fire(owner, skill, weapon) {
    if (!instance_exists(owner)) return;
    if (!instance_exists(skill)) return;
    if (!instance_exists(weapon)) return;
    
    var _skill_data = skill.data;
    if (_skill_data == undefined) return;
    
    // ===== 1. 读飞行物数据 =====
    var _proj_data = data_projectile_get(_skill_data.projectile_id);
    if (_proj_data == undefined) return;
    
    // ===== 2. 枪口位置 =====
    var _fire_angle = weapon.image_angle;
    var _weapon_data = data_weapon_get(weapon.weapon_id);
    var _fp_x = 0;
    var _fp_y = 0;
    if (_weapon_data != undefined) {
        if (variable_struct_exists(_weapon_data, "fire_point_x")) _fp_x = _weapon_data.fire_point_x;
        if (variable_struct_exists(_weapon_data, "fire_point_y")) _fp_y = _weapon_data.fire_point_y;
    }
    
    var _fire_x = weapon.x + lengthdir_x(_fp_x, _fire_angle) + lengthdir_x(_fp_y, _fire_angle + 90);
    var _fire_y = weapon.y + lengthdir_y(_fp_x, _fire_angle) + lengthdir_y(_fp_y, _fire_angle + 90);
    
    // ===== 3. 目标点 =====
var _target_x = skill.aim_target_x;
var _target_y = skill.aim_target_y;
    // ===== 4. 算发射角度（多抬一点）=====
var _base_angle = point_direction(_fire_x, _fire_y, _target_x, _target_y);
var _facing_left = (mouse_x < weapon.x);
// 瞄准抬起 10 度 + 发射后座 15 度 = 总共 25 度
var _fire_pitch = 25;
var _launch_angle = _facing_left ? (_base_angle - _fire_pitch) : (_base_angle + _fire_pitch);

// ===== 5. 进后坐力状态（多抬 → 回落）=====
weapon._aim_state = "recoil";
weapon._aim_timer = 8;              // 快速抬起的帧数
weapon._aim_hold = 6;               // 停在最高点的帧数
weapon._aim_pitch_target = _fire_pitch;
weapon._aim_start_angle = weapon.image_angle;   // 从当前角度开始
weapon._aim_fire_angle = _launch_angle;         // 目标抬到角度
    
    // ===== 6. 生成飞行物 =====
    var _grenade = instance_create_layer(_fire_x, _fire_y, "Instances", _proj_data.object);
    if (instance_exists(_grenade)) {
		//show_debug_message("[发射] 目标=(" + string(_target_x) + "," + string(_target_y) + ") | 枪口=(" + string(_fire_x) + "," + string(_fire_y) + ")");
        // 起点：枪口位置（Y 抬 40，视觉上从高处飞出）
		_grenade.is_player_grenade = true;
        _grenade.start_x = _fire_x;
        _grenade.start_y = _fire_y - 40;
            // ===== 枪口烟雾 =====
    scr_muzzle_smoke(_fire_x, _fire_y, _launch_angle);
        // 终点：鼠标
        _grenade.end_x = _target_x;
        _grenade.end_y = _target_y;
        
        // 飞行参数
        var _dist = point_distance(_fire_x, _fire_y, _target_x, _target_y);
        _grenade.duration = max(20, _dist / _proj_data.speed);
        _grenade.arc_height = 60;   // 弧线高度
        _grenade.progress = 0;
        
        _grenade.owner_id = owner;
        _grenade.element_type = _proj_data.element_type;
        
        _grenade.explosion_damage = _proj_data.explosion_damage;
        _grenade.explosion_radius = _proj_data.explosion_radius;
        _grenade.explosion_knockback = _proj_data.explosion_knockback;
        _grenade.explosion_stun_duration = _proj_data.explosion_stun_duration;
        _grenade.explosion_falloff_min = _proj_data.explosion_falloff_min;
        
        //show_debug_message("[附件] 生成榴弹 | 起点: (" + string(_grenade.start_x) + ", " + string(_grenade.start_y) + ") | 终点: (" + string(_grenade.end_x) + ", " + string(_grenade.end_y) + ")");
    }
    
    // ===== 7. 武器后坐力特效 =====
    weapon.recoil_timer = 15;
    weapon.recoil_offset = 8;
    
    // ===== 8. 玩家后退 =====
    var _recoil_dist = _skill_data.fire_recoil_distance;
    var _recoil_dur = _skill_data.fire_recoil_duration;
    
    var _back_dir = _fire_angle + 180;
    var _per_frame = _recoil_dist / _recoil_dur;
    
    owner.fire_recoil_vx = lengthdir_x(_per_frame, _back_dir);
    owner.fire_recoil_vy = lengthdir_y(_per_frame, _back_dir);
    owner.fire_recoil_timer = _recoil_dur;
}