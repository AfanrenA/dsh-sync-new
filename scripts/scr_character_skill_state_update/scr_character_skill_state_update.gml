// scr_character_skill_state_update.gml
function scr_character_skill_state_update(character) {
    if (character.skill_slot == noone || character.skill_slot == "") {
        character.skill_charge_progress = 0;
        character.skill_charge_distance = 0;
        return;
    }
    
    // ===== ★ 区分玩家和敌人 =====
    var _is_charging = false;
    var _charge_value = 0;
    
    if (object_is_ancestor(character.object_index, obj_player_base)) {
        // 玩家：从"当前武器"读蓄力状态
        if (instance_exists(character.current_weapon)) {
            _is_charging = character.current_weapon.skill_charging;
            _charge_value = character.current_weapon.skill_charge;
        }
    } else if (object_is_ancestor(character.object_index, obj_enemy_base)) {
        // 敌人：从"_charge_timer"读蓄力状态
        _is_charging = (character.ai_state == "charging");
        _charge_value = character._charge_timer;
    }
    
    if (!_is_charging) {
        character.skill_charge_progress = 0;
        character.skill_charge_distance = 0;
        return;
    }
    
    var _data = data_skill_get(character.skill_slot);
    if (_data == undefined) {
        character.skill_charge_progress = 0;
        character.skill_charge_distance = 0;
        return;
    }
    
    var _progress = _charge_value / _data.max_charge;
    _progress = clamp(_progress, 0, 1);
    
    // ===== 预警线距离 =====
    var _min_dist = _data.min_distance != undefined ? _data.min_distance : 0;
    var _max_dist = _data.base_distance;
    var _distance = _min_dist + (_max_dist - _min_dist) * _progress;
    
    // ===== 品质加成 =====
    var _quality_index = 0;
    if (instance_exists(character.skill_instance)) {
        _quality_index = character.skill_instance.quality_index;
    }
    var _range_mult = data_skill_get_quality_mult(character.skill_slot, _quality_index, "quality_range_mult");
    _distance *= _range_mult;
    
    character.skill_charge_progress = _progress;
    character.skill_charge_distance = _distance;
    character.skill_charge_max_distance = _max_dist;
}