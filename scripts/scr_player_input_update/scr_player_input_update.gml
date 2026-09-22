// scr_player_input_update.gml
/// @function scr_player_input_update(player)
/// @param {id} player 玩家实例
/// @description 处理玩家键盘输入

function scr_player_input_update(player) {
    // ★ 背包 / UI 打开时 → 屏蔽移动输入（用户要求：操作界面时角色不响应）
    if (player.inventory_ui_open) {
        player.move_dir_x = 0;
        player.move_dir_y = 0;
        return;
    }

    // 键盘输入
    if (keyboard_check(vk_left) || keyboard_check(ord("A"))) {
        player.move_dir_x = -1;
    } else if (keyboard_check(vk_right) || keyboard_check(ord("D"))) {
        player.move_dir_x = 1;
    } else {
        player.move_dir_x = 0;
    }

    if (keyboard_check(vk_up) || keyboard_check(ord("W"))) {
        player.move_dir_y = -1;
    } else if (keyboard_check(vk_down) || keyboard_check(ord("S"))) {
        player.move_dir_y = 1;
    } else {
        player.move_dir_y = 0;
    }
}