/// @description 死亡检查 + 触发死亡脚本
/// @param {id} target_inst 受伤者
/// @param {id} attacker_inst 攻击者

function scr_damage_apply_death(target_inst, attacker_inst) {
    if (target_inst.hp > 0) return;
    
    target_inst.hp = 0;
    target_inst.is_alive = false;
    
    if (target_inst.character_type == "player") {
        scr_player_death(target_inst);
    }else if (target_inst.character_type == "enemy") {
    //show_debug_message("[DEATH] ★ 准备调用 scr_enemy_death ★");
    scr_enemy_death(target_inst, attacker_inst);
    //show_debug_message("[DEATH] ★ scr_enemy_death 调用完成 ★");
}
    
    //show_debug_message("[DAMAGE] " + target_inst.character_id + " 死亡");
}