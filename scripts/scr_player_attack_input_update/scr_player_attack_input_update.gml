/// @function scr_player_attack_input_update(player)
/// @param {id} player 玩家实例
/// @description 收集玩家攻击输入（只收集，不处理）
function scr_player_attack_input_update(player) {
    player.input_left = mouse_check_button(mb_left);
    player.input_right = mouse_check_button(mb_right);
}