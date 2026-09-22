/// @function scr_player_attack_input_update(player)
/// @param {id} player 玩家实例
/// @description 收集玩家攻击输入（只收集，不处理）
function scr_player_attack_input_update(player) {
    // ★ 背包 / 任何 UI 打开时 → 屏蔽攻击输入（用户要求：操作界面时角色不响应）
    //   在这里清零最省事：所有消费者都读 input_left / input_right，
    //   而且武器 Step 里的 mouse_check_button_pressed 也能被 input_left 拦住（见下）
    if (player.inventory_ui_open) {
        player.input_left  = false;
        player.input_right = false;
        return;
    }

    player.input_left = mouse_check_button(mb_left);
    player.input_right = mouse_check_button(mb_right);
}