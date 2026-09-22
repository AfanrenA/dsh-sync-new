/// @description 护盾吸收伤害
/// @param {id} target_inst 受伤者
/// @param {real} damage 最终伤害
/// @param {id} attacker_inst 攻击者
/// @returns {real} 穿透护盾的溢出伤害
function scr_damage_shield(target_inst, damage, attacker_inst) {
    if (!variable_struct_exists(target_inst, "shield")) return damage;
    if (target_inst.shield <= 0) return damage;
    
    var _shield = target_inst.shield;
    
    // ===== 伤害 > 护盾：护盾破碎，溢出伤害穿透 =====
    if (damage > _shield) {
        var _overflow = damage - _shield;
        target_inst.shield = 0;
        
        // 重置恢复计时器
        if (variable_struct_exists(target_inst, "shield_regen_timer")) {
            target_inst.shield_regen_timer = target_inst.shield_regen_delay;
        }
        
        // 护盾破碎反馈（只做闪光，不做击退）
        if (attacker_inst != noone) {
            var _hit_dir = point_direction(attacker_inst.x, attacker_inst.y, target_inst.x, target_inst.y);
            scr_shield_feedback(target_inst, _hit_dir);
        }
        
        show_debug_message("[SHIELD] 护盾破碎！溢出 " + string(_overflow) + " 全部穿透");
        return _overflow;  // 溢出全部穿透
    }
    
    // ===== 伤害 <= 护盾：完全吸收 =====
    target_inst.shield -= damage;
    
    // 重置恢复计时器
    if (variable_struct_exists(target_inst, "shield_regen_timer")) {
        target_inst.shield_regen_timer = target_inst.shield_regen_delay;
    }
    
    // 护盾受击反馈（只做闪光，不做击退）
    if (attacker_inst != noone) {
        var _hit_dir = point_direction(attacker_inst.x, attacker_inst.y, target_inst.x, target_inst.y);
        scr_shield_feedback(target_inst, _hit_dir);
    }
    
    show_debug_message("[SHIELD] 吸收 " + string(damage) + "，剩余 " + string(target_inst.shield));
    return 0;
}