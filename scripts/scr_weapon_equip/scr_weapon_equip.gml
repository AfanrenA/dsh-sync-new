function scr_weapon_equip(player, weapon, slot) {
    if (!instance_exists(player)) return false;
    if (!instance_exists(weapon)) return false;
    if (slot < 0 || slot >= array_length(player.weapon_slots)) return false;
    
    // ★ 先从背包移除新武器（腾出空间）
    scr_inventory_remove(player, weapon);
    
    // 旧武器放回背包
    var _old = player.weapon_slots[slot];
    if (instance_exists(_old)) {
        scr_inventory_add(player, _old);
        _old.visible = false;
        _old.owner_id = noone;
    }
    
    // 装备
    player.weapon_slots[slot] = weapon;
    weapon.owner_id = player;
    weapon.is_on_ground = false;
    weapon.depth = player.depth - 1;
    weapon.cooldown_timer = 0;
    weapon.image_alpha = 1;
    
    if (slot == player.active_weapon_slot) {
        player.current_weapon = weapon;
        weapon.visible = true;
    } else {
        weapon.visible = false;
    }
    
    show_debug_message("[装备] 武器 " + string(weapon.weapon_id) + " → 槽 " + string(slot));
    return true;
}