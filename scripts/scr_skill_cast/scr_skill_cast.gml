// scr_skill_cast.gml
function scr_skill_cast(owner, skill_id, charge_time, skip_compat_check = false) {
    var _data = data_skill_get(skill_id);
    if (_data == undefined) {
        show_debug_message("[SKILL] 武技数据不存在: " + skill_id);
        return;
    }
    
    // ★ 兼容性检查（可选跳过）
    if (!skip_compat_check) {
        if (!scr_skill_is_compatible(skill_id, owner.current_weapon)) {
            show_debug_message("[SKILL] 武器不兼容: " + skill_id);
            return;
        }
    }
    
    // ===== 检查冷却 =====
    if (_data.slot == "skill") {
        if (object_is_ancestor(owner.object_index, obj_player_base)) {
            if (instance_exists(owner.skill_instance) && owner.skill_instance.cooldown_timer > 0) {
                show_debug_message("[SKILL] 武技冷却中");
                return;
            }
        } else {
            if (variable_instance_exists(owner, "enemy_skill_cooldown") && owner.enemy_skill_cooldown > 0) {
                show_debug_message("[SKILL] 武技冷却中");
                return;
            }
        }
    } else if (_data.slot == "agility") {
        if (instance_exists(owner.agility_instance) && owner.agility_instance.cooldown_timer > 0) {
            show_debug_message("[SKILL] 身法冷却中");
            return;
        }
    }
    
    // ===== 计算品质索引 =====
    var _quality_index = 0;
    if (_data.slot == "skill" && instance_exists(owner.skill_instance)) {
        _quality_index = owner.skill_instance.quality_index;
    } else if (_data.slot == "agility" && instance_exists(owner.agility_instance)) {
        _quality_index = owner.agility_instance.quality_index;
    }
    
    // ===== 蓄力百分比 =====
    var _charge_progress = charge_time / _data.max_charge;
    _charge_progress = clamp(_charge_progress, 0, 1);
    
    // ===== 计算距离（含品质加成） =====
    var _min_dist = _data.min_distance != undefined ? _data.min_distance : 0;
    var _max_dist = _data.base_distance;
    var _distance = _min_dist + (_max_dist - _min_dist) * _charge_progress;
    var _range_mult = data_skill_get_quality_mult(skill_id, _quality_index, "quality_range_mult");
    _distance *= _range_mult;
    
    // ===== 计算伤害（含品质加成） =====
    var _damage_mult = data_skill_get_quality_mult(skill_id, _quality_index, "quality_damage_mult");
    
    // ===== 执行技能脚本（传入伤害倍率） =====
    var _script = asset_get_index(_data.cast_script);
    if (_script != -1) {
        script_execute(_script, owner, _distance, charge_time, _quality_index, _damage_mult);
    }
    
    // ===== 计算冷却（含品质加成） =====
    var _cooldown_mult = data_skill_get_quality_mult(skill_id, _quality_index, "quality_cooldown_mult");
        // ★ 遗物：武技冷却倍率（避免影响身法那一条，只对 skill 生效可选）
    var _relic_cd = 1.0;
    if (variable_instance_exists(owner, "relic_agility_cd_mult") && _data.slot == "agility") {
        _relic_cd = owner.relic_agility_cd_mult;
    }
    var _cooldown_seconds = _data.base_cooldown * _cooldown_mult * _relic_cd;
    _cooldown_seconds = max(_cooldown_seconds, 0.5);
    var _cooldown_frames = _cooldown_seconds * 60;
    
    // ===== 写冷却 =====
    if (_data.slot == "skill") {
        if (object_is_ancestor(owner.object_index, obj_player_base)) {
            if (instance_exists(owner.skill_instance)) {
                owner.skill_instance.cooldown_timer = _cooldown_frames;
            }
        }
        // ★ 敌人冷却由 scr_enemy_state_charging 管，这里不写
    } else if (_data.slot == "agility") {
        if (instance_exists(owner.agility_instance)) {
            owner.agility_instance.cooldown_timer = _cooldown_frames;
        }
    }
    
    show_debug_message("[SKILL] " + _data.display_name + " 释放 | 蓄力: " + string(charge_time) + "s | 距离: " + string(_distance) + " | 冷却: " + string(_cooldown_seconds) + "s");
}