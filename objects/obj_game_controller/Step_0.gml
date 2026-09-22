// obj_game_controller Step 事件
/// @description 更新玩家引用
// ===== 顿帧计时器递减 =====
if (global.hit_pause_timer > 0) {
    global.hit_pause_timer -= 1;
}
// ===== 获取玩家引用 =====
if (player_ref == noone || !instance_exists(player_ref)) {
    player_ref = instance_find(obj_player_base, 0);
}

// ===== 获取屏幕效果引用 =====
if (screen_effect == noone || !instance_exists(screen_effect)) {
    screen_effect = instance_find(obj_screen_effect, 0);
}

