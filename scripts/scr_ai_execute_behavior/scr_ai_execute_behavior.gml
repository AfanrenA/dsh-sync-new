// ============================================================
// scr_ai_execute_behavior - AI 行为执行入口
// 根据 ai_state 调用对应的执行函数
// ============================================================

function scr_ai_execute_behavior(_inst) {
    if (!instance_exists(_inst)) exit;
    
    var _target = _inst.ai_target;
    var _weapon = _inst.current_weapon;
    var _speed = _inst.move_speed;
    
    switch (_inst.ai_state) {
        case "chase":
            if (instance_exists(_target)) {
                scr_ai_execute_chase(_inst, _target, _speed);
            }
            break;
            
        case "retreat":
            if (instance_exists(_target)) {
                scr_ai_execute_retreat(_inst, _target, _speed);
            }
            break;
            
        case "attack":
    show_debug_message("⚔️ 执行攻击行为");
    if (instance_exists(_target) && instance_exists(_weapon)) {
        scr_ai_execute_attack(_inst, _target, _weapon);
    } else {
        show_debug_message("❌ 攻击条件不满足: target=" + string(instance_exists(_target)) + " weapon=" + string(instance_exists(_weapon)));
    }
    break;
            
        case "idle":
            scr_ai_execute_idle(_inst, _speed * 0.4);
            break;
            
        case "skill":
            // 技能执行（后续实现）
            break;
    }
}