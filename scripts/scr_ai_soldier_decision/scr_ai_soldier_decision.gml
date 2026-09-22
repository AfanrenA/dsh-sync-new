// ============================================================
// scr_ai_soldier_decision - 机动士兵AI决策
// 特点：敌进我退，敌退我进
// ============================================================

function scr_ai_soldier_decision(_inst) {
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
    
    // 远程优先：保持距离，敌进我退
    if (_can_attack) {
        _inst.ai_state = "attack";
    } else if (_dist < _data.retreat_range) {
        _inst.ai_state = "retreat";      // 太近了撤退
    } else if (_dist > _data.attack_range * 1.5) {
        _inst.ai_state = "chase";        // 太远了追击
    } else {
        _inst.ai_state = "idle";         // 在合适距离待机
    }
}