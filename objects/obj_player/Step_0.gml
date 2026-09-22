// ======================================================================
// obj_player - Step 事件（V3 标准）
// ======================================================================

event_inherited();
// obj_player_base - Step 事件

// ... 移动逻辑 ...

// ---- 交互（拾取/丢弃）- 玩家用键盘控制 ----
scr_entity_interact(id, true);  // true = 玩家
// 临时测试：按 H 键触发受击反馈
if (keyboard_check_pressed(ord("H"))) {
    scr_character_trigger_hit_response(id, 0);
}