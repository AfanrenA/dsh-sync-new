function scr_player_move_update(player) {
    // ★ 发射后坐力锁定时，跳过输入移动
    if (player.fire_recoil_timer > 0) {
        // 只处理后坐力位移，不处理输入
        scr_fire_recoil_execute(player);
    } else {
        scr_character_move_execute(player);
    }
    scr_character_flip(player, mouse_x);
}