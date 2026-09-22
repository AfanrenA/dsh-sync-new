// ======================================================================
// scr_entity_interact.gml
// 实体交互（拾取/丢弃武器）- 玩家和敌人共用
// ======================================================================
/// @description 处理实体的武器拾取/丢弃交互
/// @param {instance} _entity 实体实例（玩家或敌人）
/// @param {bool} _is_player 是否玩家（玩家用键盘输入，敌人用AI决策）

function scr_entity_interact(_entity, _is_player = true) {
    
    // ============================================================
    // 1. 丢弃逻辑（Q键 或 敌人AI决定丢弃）
    // ============================================================
    var _drop_key = _is_player ? keyboard_check_pressed(ord("Q")) : false;
    
    if (_drop_key || (_is_player == false && _entity._ai_wants_drop)) {
        if (instance_exists(_entity.current_weapon)) {
            var _old_weapon = _entity.current_weapon;
            var _drop_x = _entity.x + lengthdir_x(random_range(50, 100), random(360));
            var _drop_y = _entity.y + lengthdir_y(random_range(50, 100), random(360));
            scr_weapon_drop(_old_weapon, _drop_x, _drop_y);
            _entity.current_weapon = noone;
            show_debug_message("🗑️ " + string(object_get_name(_entity.object_index)) + " 丢弃了武器");
        }
        if (_is_player == false) {
            _entity._ai_wants_drop = false;  // 重置AI标志
        }
    }
    
    // ============================================================
    // 2. 拾取逻辑（F键 或 敌人AI决定拾取）
    // ============================================================
    var _pickup_key = _is_player ? keyboard_check_pressed(ord("F")) : false;
    
    if (_pickup_key || (_is_player == false && _entity._ai_wants_pickup)) {
        // 查找最近的掉落武器
        var _nearest = noone;
        var _nearest_dist = 120;
        
        with (obj_weapon_base) {
            if (is_dropped && instance_exists(id)) {
                var _d = point_distance(other.x, other.y, x, y);
                if (_d < _nearest_dist) {
                    _nearest_dist = _d;
                    _nearest = id;
                }
            }
        }
        
        if (_nearest != noone) {
            // 如果已有武器，先丢弃
            if (instance_exists(_entity.current_weapon)) {
                var _old_weapon = _entity.current_weapon;
                var _drop_x = _entity.x + lengthdir_x(random_range(80, 130), random(360));
                var _drop_y = _entity.y + lengthdir_y(random_range(80, 130), random(360));
                scr_weapon_drop(_old_weapon, _drop_x, _drop_y);
                _entity.current_weapon = noone;
                show_debug_message("🔄 " + string(object_get_name(_entity.object_index)) + " 丢弃旧武器");
            }
            
            // ---- 转移所有权 ----
            _nearest.owner = _entity;
            _nearest.is_dropped = false;
            _nearest.pickup_cooldown = 0;
            _nearest.visible = true;
            _nearest.collision_comp = noone;
            _nearest.collision_mask = COLLISION_LAYER.NONE;
            
            // ---- 保留换弹进度 ----
            if (_nearest.is_reloading) {
                show_debug_message("🔄 拾取时正在换弹: " + string(_nearest.magazine_loading) + "/" + string(_nearest.magazine_max));
            } else {
                if (_nearest.weapon_type == "ranged" && 
                    _nearest.magazine_max > 0 && 
                    _nearest.magazine_current <= 0) {
                    _nearest.start_reload();
                    show_debug_message("🔄 弹匣为空，自动换弹");
                }
            }
            
            _entity.current_weapon = _nearest;
            
            // ---- 调试日志 ----
            show_debug_message("✅ " + string(object_get_name(_entity.object_index)) + " 拾取了武器: " + string(_nearest.weapon_name));
        }
        
        if (_is_player == false) {
            _entity._ai_wants_pickup = false;  // 重置AI标志
        }
    }
}