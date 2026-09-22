// ============================================================
// scr_ai_axeman_decision - 斧哥AI决策
// 特点：稳重，靠近了才打，攻速慢但伤害高
// ============================================================

function scr_ai_axeman_decision(_inst) {
    if (!instance_exists(_inst)) return;
    
    var _data = _inst.enemy_data;
    if (_data == undefined) return;
    
    var _target = scr_ai_get_target(_inst, _data.aggro_range);
    _inst.ai_target = _target;
    
    if (!instance_exists(_target)) {
        _inst.ai_state = "idle";
        return;
    }
    
    _inst.ai_target_x = _target.x;
    _inst.ai_target_y = _target.y;
    
    var _dist = scr_ai_get_distance(_inst, _target);
    var _can_attack = scr_ai_can_attack(_inst, _target, _data.attack_range);
    
    // 稳重：只打接近的目标，不追击太远
    if (_can_attack) {
        _inst.ai_state = "attack";
    } else if (_dist < _data.attack_range * 2) {
        _inst.ai_state = "chase";        // 只追到攻击范围附近
    } else {
        _inst.ai_state = "idle";         // 太远就放弃
    }
}