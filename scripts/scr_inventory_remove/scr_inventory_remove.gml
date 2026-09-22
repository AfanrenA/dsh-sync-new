/// @description 从背包移除物品
/// @param {id} player 玩家实例
/// @param {id} item 物品实例
/// @returns {bool} 是否成功
function scr_inventory_remove(player, item) {
    if (!instance_exists(player)) return false;
    
    for (var i = 0; i < array_length(player.inventory); i++) {
        if (player.inventory[i] == item) {
            array_delete(player.inventory, i, 1);
            return true;
        }
    }
    return false;
}