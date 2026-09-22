function scr_player_pickup_update(player) {
	//show_debug_message("[PICKUP] 拾取检测执行");  // ← 加这行调试
    // 统一拾取检测
    scr_item_pickup_check(player);
    // 丢弃检测（保留）
    scr_weapon_drop_check(player);
}