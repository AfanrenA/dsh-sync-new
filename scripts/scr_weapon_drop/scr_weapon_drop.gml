function scr_weapon_drop(player_inst) {
    if (player_inst.current_weapon == noone) {
        return false;
    }
    
    var _weapon = player_inst.current_weapon;
    
    // 解绑
    _weapon.owner_id = noone;
    _weapon.is_on_ground = true;
    _weapon.x = player_inst.x + (30 * player_inst.facing_dir);
    _weapon.y = player_inst.y;
    _weapon.visible = true;
    _weapon.depth = 105;
    
    // 重置漂浮起始位置（防止瞬移）
    _weapon._bob_timer = 0;
    _weapon._start_y = _weapon.y;
    
    // 清空玩家武器槽
    player_inst.weapon_slots[player_inst.active_weapon_slot] = noone;
    player_inst.current_weapon = noone;
    
    // 挂光晕
    scr_glow_attach(_weapon);
    
    show_debug_message("[武器] 丢弃: " + string(_weapon.weapon_id));
    return true;
}