/// @description 加物品到背包
/// @param {id} player 玩家实例
/// @param {id} item 物品实例
/// @returns {bool} 是否成功
function scr_inventory_add(player, item) {
    if (!instance_exists(player)) return false;
    if (!instance_exists(item)) return false;
    
    if (array_length(player.inventory) >= player.inventory_size) {
        return false;
    }
    
    array_push(player.inventory, item);
	// ★ 首次拾取提示
    scr_check_first_pickup(player, item);
    return true;
}