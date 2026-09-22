// scr_skill_bull_rush.gml
function scr_skill_bull_rush(owner, distance, charge_time, quality_index) {
    // ===== 获取武器 =====
    var _weapon = owner.current_weapon;
    if (!instance_exists(_weapon)) return;
    
    var _weapon_data = _weapon.entity_data;
    if (_weapon_data == undefined || _weapon_data.base_damage == undefined) {
        show_debug_message("[SKILL] 武器数据不存在");
        return;
    }
    
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
    
    // ===== ★ 蓄力倍率（敌人两倍） =====
    var _damage_mult = 1 + _charge_progress * 1.5;
    if (!_is_player) {
        _damage_mult = 2 + _charge_progress * 3.0;
    }
    
    // ===== 方向 =====
    var _dir = scr_get_aim_direction(owner);
    var _speed = distance / 25;
    
    // ===== ★ 伤害 = 武器 base_damage × 武技倍率 × 蓄力 × 品质 =====
    var _weapon_base_damage = _weapon_data.base_damage;
    var _skill_mult = _data.damage_multiplier != undefined ? _data.damage_multiplier : 1.0;
    var _quality_mult = 1 + (quality_index * 0.15);
    var _damage = _weapon_base_damage * _skill_mult * _damage_mult * _quality_mult;
    var _knockback = 10 + _charge_progress * 10;
    
    owner.is_rushing = true;
    owner.is_invincible = true;
    owner.rush_dir = _dir;
    owner.rush_distance = distance;
    owner.rush_traveled = 0;
    owner.rush_speed = _speed;
    owner.rush_damage = _damage;
    owner.rush_knockback = _knockback;
    owner.rush_owner = owner;
    owner.rush_hit_list = [];
    owner.rush_charge_time = charge_time;
    
    // ★ 把武技的暴击数据存到 owner 上（冲撞伤害检测时用）
    owner.rush_crit_chance = _data.crit_chance != undefined ? _data.crit_chance : 0.1;
    owner.rush_crit_multiplier = _data.crit_multiplier != undefined ? _data.crit_multiplier : 1.5;
    owner.rush_is_skill_damage = true;
    
    show_debug_message("[SKILL] 蛮牛冲撞 | 武器伤害: " + string(_weapon_base_damage) + " | 武技倍率: " + string(_skill_mult) + " | 最终伤害: " + string(_damage));
}