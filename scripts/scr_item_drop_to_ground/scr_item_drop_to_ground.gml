/// @function scr_item_drop_to_ground(player, item)
/// @description 把任意物品丢到地面（武器/武技/身法通用）
/// @param {id} player 玩家实例
/// @param {id} item 物品实例
/// @returns {bool} 是否成功
function scr_item_drop_to_ground(player, item) {
    if (!instance_exists(player)) return false;
    if (!instance_exists(item)) return false;
    
    // 从背包移除
    scr_inventory_remove(player, item);
    
    // ★ 计算落点（螺旋偏移，避免重叠）
    var _base_x = player.x + (100 * player.facing_dir);
    var _base_y = player.y;
    var _drop_x = _base_x;
    var _drop_y = _base_y;
    
    var _attempts = 0;
    var _max_attempts = 20;
    var _radius = 40;
    
    while (_attempts < _max_attempts) {
        var _collision = false;
        with (obj_item_base) {
            if (id != other.id && is_on_ground && point_distance(x, y, _drop_x, _drop_y) < _radius) {
                _collision = true;
            }
        }
        if (!_collision) break;
        
        _attempts += 1;
        var _angle = _attempts * 137.5;
        var _dist = _radius * sqrt(_attempts);
        _drop_x = _base_x + lengthdir_x(_dist, _angle);
        _drop_y = _base_y + lengthdir_y(_dist, _angle);
    }
    
    // 解绑
    item.owner_id = noone;
    item.is_on_ground = true;
    item.x = _drop_x;
    item.y = _drop_y;
    item.visible = true;
    item.depth = 105;
    
    // 重置漂浮起始位置
    item._bob_timer = 0;
    item._start_y = item.y;
    
    // 挂光晕
    scr_glow_attach(item);
    
    // debug
    var _log_name = "";
    if (variable_instance_exists(item, "display_name")) _log_name = item.display_name;
    else if (variable_instance_exists(item, "skill_name")) _log_name = item.skill_name;
    show_debug_message("[丢弃] " + _log_name);
    
    return true;
}