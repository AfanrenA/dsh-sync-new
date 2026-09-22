// obj_ui_manager Step 事件
// 获取玩家引用
if (player_ref == noone || !instance_exists(player_ref)) {
    player_ref = instance_find(obj_player_base, 0);
}