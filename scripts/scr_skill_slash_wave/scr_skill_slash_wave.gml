// scr_skill_slash_wave.gml
function scr_skill_slash_wave(owner, distance, charge_time, quality_index) {
    var _weapon = owner.current_weapon;
    if (!instance_exists(_weapon)) return;
    
    // ===== 获取技能数据 =====
    var _skill_id = "";
    var _is_player = false;
    
    if (object_is_ancestor(owner.object_index, obj_player_base)) {
        _skill_id = owner.skill_slot;
        _is_player = true;
    } else if (object_is_ancestor(owner.object_index, obj_enemy_base)) {
        _skill_id = owner.enemy_skill_id;
        _is_player = false;
    }
    
    var _data = data_skill_get(_skill_id);
    if (_data == undefined) {
        show_debug_message("[SKILL] 技能数据不存在: " + _skill_id);
        return;
    }
    
    var _charge_progress = charge_time / _data.max_charge;
    _charge_progress = clamp(_charge_progress, 0, 1);
    
    // ===== 方向 =====
    var _base_dir = scr_get_aim_direction(owner);
    
    // 触发挥砍动画
    _weapon.is_swinging = true;
    _weapon.swing_timer = 15;
    _weapon.swing_total_frames = 15;
    _weapon._swing_base_angle = _weapon.image_angle;
    _weapon.swing_angle_range = 90;
    
    // ===== ★ 从武器读基础伤害 =====
    var _weapon_data = _weapon.entity_data;
    if (_weapon_data == undefined || _weapon_data.base_damage == undefined) {
        show_debug_message("[SKILL] 武器数据不存在: " + _weapon.weapon_id);
        return;
    }
    
    var _weapon_base_damage = _weapon_data.base_damage;
    var _skill_mult = _data.damage_multiplier != undefined ? _data.damage_multiplier : 1.0;
    
    // ===== 蓄力倍率 + 品质倍率 =====
    var _charge_damage_mult = 1 + _charge_progress * 1.5;
    var _quality_mult = 1 + (quality_index * 0.15);
    
    // ===== ★ 从数据表读取AI配置（敌人专用） =====
var _ai_config = _data.ai;
var _spread_count = 1;
var _spread_angle = 0;
var _damage_percent = 1.0;
var _speed_mult = 1 + _charge_progress * 0.5;

if (!_is_player && _ai_config != undefined) {
    _spread_count = _ai_config.spread_count != undefined ? _ai_config.spread_count : 1;
    _spread_angle = _ai_config.spread_angle != undefined ? _ai_config.spread_angle : 0;
    _damage_percent = _ai_config.damage_percent != undefined ? _ai_config.damage_percent : 1.0;
    _speed_mult = 1 + _charge_progress * 0.8;
}

// ★ 统一计算最终飞行距离
var _final_distance = scr_skill_get_final_distance(owner, _skill_id, charge_time);
    
    // ===== 计算散射角度数组 =====
    var _angles = [];
    if (_spread_count == 1) {
        _angles[0] = 0;
    } else {
        var _half = (_spread_count - 1) * _spread_angle / 2;
        for (var i = 0; i < _spread_count; i++) {
            _angles[i] = -_half + i * _spread_angle;
        }
    }
    
    // ============================================================
    // 创建投射物
    // ============================================================
    for (var i = 0; i < array_length(_angles); i++) {
        var _dir = _base_dir + _angles[i];
        
        var _slash = scr_factory_projectile_create("slash", owner.x, owner.y, _dir, owner, noone);
        if (!instance_exists(_slash)) continue;
        
        // ★ 伤害 = 武器 base_damage × 武技倍率 × 蓄力 × 品质 × 散射衰减
        var _final_damage = _weapon_base_damage * _skill_mult * _charge_damage_mult * _quality_mult * _damage_percent;
        var _final_knockback = 10 * _charge_damage_mult * _quality_mult * _damage_percent;
        var _final_stun = 0.3 * _charge_damage_mult * _quality_mult * _damage_percent;
        
        _slash.damage = _final_damage;
         _slash.move_speed *= _speed_mult;
        
                _slash.knockback_power = _final_knockback;
        _slash.stun_duration = _final_stun;
        _slash.max_distance = _final_distance;
		        _slash.max_distance = _final_distance;
				show_debug_message("[剑气] owner=" + object_get_name(owner.object_index) + " | final_distance=" + string(_final_distance) + " | move_speed=" + string(_slash.move_speed) + " | 出生x=" + string(_slash.x) + " y=" + string(_slash.y));
        _slash.traveled_distance = 0;
        
        // ★★★ 诊断：刻下"发射瞬间"的真实起点/方向/目标距离 ★★★
        _slash.dbg_spawn_x   = owner.x;
        _slash.dbg_spawn_y   = owner.y;
        _slash.dbg_spawn_dir = _dir;
        _slash.dbg_target_dist = _final_distance;
        _slash.dbg_owner_obj = owner.object_index;
        
        /*show_debug_message("[剑气发射] owner.x=" + string(owner.x) + " owner.y=" + string(owner.y)
            + " | owner对象=" + object_get_name(owner.object_index)
            + " | 方向=" + string(_dir)
            + " | 目标距离=" + string(_final_distance)
            + " | 实例创建后 x=" + string(_slash.x) + " y=" + string(_slash.y));
        */
        // ★ 把武技的暴击数据存到投射物上
        _slash.skill_crit_chance = _data.crit_chance != undefined ? _data.crit_chance : 0.1;
        _slash.skill_crit_multiplier = _data.crit_multiplier != undefined ? _data.crit_multiplier : 1.5;
        _slash.is_skill_damage = true;
    }
    
    show_debug_message("[SKILL] 剑气斩 | 武器伤害: " + string(_weapon_base_damage) + " | 武技倍率: " + string(_skill_mult) + " | 最终伤害: " + string(_weapon_base_damage * _skill_mult * _charge_damage_mult * _quality_mult));
}