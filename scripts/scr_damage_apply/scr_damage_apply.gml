/// @description 伤害计算 - 唯一入口，读伤害包，不关心来源
/// @param {id} target_inst 受伤者
/// @param {struct} packet 伤害包（scr_damage_packet_create 产出）
/// @param {id} attacker_inst 攻击者（用于反馈方向/死亡归属，可为 noone）
/// @returns {array} [最终伤害值, 是否暴击]
function scr_damage_apply(target_inst, packet, attacker_inst = noone) {
    // ===== 1. 存活检查 =====
    if (!instance_exists(target_inst) || !target_inst.is_alive) return [0, false];
    if (packet == undefined) return [0, false];
    
    // ===== 2. 血条显示 =====
    if (object_is_ancestor(target_inst.object_index, obj_enemy_base)) {
        target_inst.hpbar_visible = true;
        target_inst.hpbar_alpha = 1;
        target_inst.hpbar_timer = 300;
    }
    
    // ===== 3. 目标无敌检查 =====
    if (target_inst.is_invincible) return [0, false];
    
    // ===== 4. 护甲减伤 =====
    var _armor = variable_instance_exists(target_inst, "armor") ? target_inst.armor : 0;
    var _final_damage = packet.damage * (1 - _armor / (_armor + 50));
    
    // ===== 5. 派系抗性 =====
    if (variable_instance_exists(target_inst, "faction_data") && target_inst.faction_data != undefined) {
        var _resist = target_inst.faction_data.damage_type_resist;
        if (_resist != undefined) {
            if (packet.element_type == "fire" && variable_struct_exists(_resist, "fire")) _final_damage *= (1 - _resist.fire);
            if (packet.element_type == "electrolyte" && variable_struct_exists(_resist, "lightning")) _final_damage *= (1 - _resist.lightning);
        }
    }
    
    // ===== 6. 暴击（读包，无分支） =====
    var _is_critical = false;
    if (!packet.ignore_crit && packet.can_crit && random(1) < packet.crit_chance) {
        _final_damage *= packet.crit_multiplier;
        _is_critical = true;
    }
    
    // ===== 7. 护盾吸收 =====
    var _had_shield = (variable_instance_exists(target_inst, "shield") && target_inst.shield > 0);
    var _remain = scr_damage_shield(target_inst, _final_damage, attacker_inst);
    
    // ===== 8. 扣血 =====
    if (_remain > 0) {
        target_inst.hp -= _remain;
    }
    
    // 顿帧（只对敌人）
    if (!object_is_ancestor(target_inst.object_index, obj_player_base)) {
        if (global.hit_pause_timer <= 0) {
            var _pause = 0;
            var _shield_broken = (_had_shield && target_inst.shield <= 0);
            var _shield_absorbed = (_had_shield && target_inst.shield > 0);
            
            if (_shield_absorbed) {
                _pause = 0;
            } else if (_shield_broken) {
                _pause = 9;
            } else {
                _pause = 4;
                if (_is_critical) _pause = 6;
            }
            
            if (target_inst.hp <= 0) _pause = 10;
            if (_pause > 0) global.hit_pause_timer = _pause;
        }
    }
    
    // ===== 9. 记录受击点 =====
    var _hit_x = target_inst.x;
    var _hit_y = target_inst.y;
    
    // ===== 10. 受击反馈 =====
    if (attacker_inst != noone && instance_exists(attacker_inst)) {
        var _hit_dir = point_direction(attacker_inst.x, attacker_inst.y, target_inst.x, target_inst.y);
        scr_damage_feedback(target_inst, _hit_dir, packet.knockback, packet.stun, _is_critical, _had_shield, attacker_inst);
    }
    
    // ===== 11. 死亡检查 =====
    if (target_inst.hp <= 0) {
        scr_damage_apply_death(target_inst, attacker_inst);
    }
    
    // ===== 12. 伤害数字 =====
    if (_is_critical && !_had_shield) {
        scr_spawn_damage_number(_hit_x, _hit_y, _final_damage, true);
    }
    
    return [_final_damage, _is_critical];
}