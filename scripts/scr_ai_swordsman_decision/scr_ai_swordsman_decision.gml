/// @description 剑士 AI 决策
/// @param {instance} _inst 敌人实例
function scr_ai_swordsman_decision(_inst) {
    
    // 找目标
    var _target = scr_ai_find_target(_inst, _inst.aggro_range);
    if (!instance_exists(_target)) {
        _inst.ai_state = "idle";
        scr_ai_execute_idle(_inst, _inst.move_speed * 0.3);
        return;
    }
    
    var _dist = point_distance(_inst.x, _inst.y, _target.x, _target.y);
    var _weapon = _inst.current_weapon;
    
    // ★★★ 检查武器是否可用（增加防御）★★★
    var _can_attack = false;
    if (instance_exists(_weapon) && variable_instance_exists(_weapon, "can_fire")) {
        _can_attack = _weapon.can_fire();
    }
    
    // ============================================================
    // ★★★ 核心修复：攻击后立即切回 chase ★★★
    // ============================================================
    if (_dist <= _inst.attack_range) {
        // 在攻击范围内
        if (_can_attack) {
            // 武器可用 → 攻击
            _inst.ai_state = "attack";
            scr_ai_execute_attack(_inst, _target, _weapon);
            
            // ★★★ 攻击执行后立即切回 chase（让追击逻辑接管）★★★
            _inst.ai_state = "chase";
        } else {
            // 武器冷却中 → 保持在攻击范围内，但不移动（原地等待冷却结束）
            _inst.ai_state = "chase";
            // 不移动，原地等待
            // 可以加一个面向目标的小动作
            if (abs(_target.x - _inst.x) > 5) {
                _inst.image_xscale = sign(_target.x - _inst.x);
            }
        }
    } else if (_dist <= _inst.aggro_range) {
        // 在索敌范围内但不在攻击范围 → 追击
        _inst.ai_state = "chase";
        scr_ai_execute_chase(_inst, _target, _inst.move_speed, _inst.attack_range * 0.7);
    } else {
        // 超出索敌范围 → 待机
        _inst.ai_state = "idle";
        scr_ai_execute_idle(_inst, _inst.move_speed * 0.3);
    }
}