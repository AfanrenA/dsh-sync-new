function scr_weapon_slot_switch(player, slot) {
    if (!instance_exists(player)) return;
    if (slot < 0 || slot >= array_length(player.weapon_slots)) return;
    if (slot == player.active_weapon_slot) return;
    
    if (player.weapon_switch_timer > 0) return;
    
    var _old_weapon = player.current_weapon;
    var _new_weapon = player.weapon_slots[slot];
    
    // ★ 新增：新武器坐标同步到玩家（关键修复）
    if (instance_exists(_new_weapon)) {
        _new_weapon.x = player.x;
        _new_weapon.y = player.y;
    }
    
    // 旧武器快照 + 隐藏
    if (instance_exists(_old_weapon)) {
        player.weapon_switch_old_sprite = _old_weapon.sprite_index;
        player.weapon_switch_old_index = _old_weapon.image_index;
        player.weapon_switch_old_angle = _old_weapon.image_angle;
        player.weapon_switch_old_xscale = _old_weapon.image_xscale;
        player.weapon_switch_old_yscale = _old_weapon.image_yscale;
        _old_weapon.flash_timer = 0;
        _old_weapon.visible = false;
    } else {
        player.weapon_switch_old_sprite = -1;
    }
    
    // 切换
    player.active_weapon_slot = slot;
    player.current_weapon = _new_weapon;
    
    // 新武器隐藏
    if (instance_exists(_new_weapon)) {
        _new_weapon.visible = false;
    }
    
    // 启动过渡
    if (player.weapon_switch_old_sprite != -1) {
        player.weapon_switch_timer = 14;
    } else {
        if (instance_exists(_new_weapon)) {
            _new_weapon.visible = true;
        }
    }
    
    show_debug_message("[切换] 武器槽 " + string(slot));
}