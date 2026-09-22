/// @description 装备身法到槽（交换：旧身法放回背包）
/// @param {id} player 玩家实例
/// @param {id} agility_inst 身法实例
function scr_agility_equip(player, agility_inst) {
    if (!instance_exists(player)) return;
    if (!instance_exists(agility_inst)) return;
    
    // ★ 先从背包移除新身法（腾格子）
    scr_inventory_remove(player, agility_inst);
    
    // 旧身法放回背包
    if (instance_exists(player.agility_instance)) {
        // ★ 背包满 → 中止
        if (array_length(player.inventory) >= player.inventory_size) {
            scr_show_hint(player, "背包已满");
            scr_inventory_add(player, agility_inst);   // 新身法放回去
            return;
        }
        
        scr_inventory_add(player, player.agility_instance);
        player.agility_instance.visible = false;
    }
    
    // 装备
    player.agility_slot = agility_inst.agility_id;
    player.agility_instance = agility_inst;
    if (instance_exists(agility_inst)) agility_inst.cooldown_timer = 0;
    agility_inst.visible = false;
    
    show_debug_message("[装备] 身法 " + string(agility_inst.agility_id));
}