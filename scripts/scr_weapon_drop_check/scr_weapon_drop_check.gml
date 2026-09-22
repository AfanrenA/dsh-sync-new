// scr_weapon_drop_check.gml
// 武器丢弃检测 - 纯函数
// 调用方式：scr_weapon_drop_check(player_inst)

/// @function scr_weapon_drop_check(player_inst)
/// @param {id} player_inst 玩家实例
/// @description 检测丢弃输入并丢弃武器
function scr_weapon_drop_check(player_inst) {
    if (player_inst.inventory_ui_open) return;   // ★ 背包打开时不处理
    if (keyboard_check_pressed(ord("Q"))) {
        scr_weapon_drop(player_inst);
    }
}