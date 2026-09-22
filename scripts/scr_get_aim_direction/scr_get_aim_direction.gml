/// @function scr_get_aim_direction(owner)
/// @param {id} owner - 发射者实例
/// @return {real} 瞄准方向角度（度）
/// @description 玩家统一读 aim_target（obj_aim_indicator 每帧写），不再用 mouse_x

function scr_get_aim_direction(owner) {
    // ===== 玩家：读统一瞄准目标 =====
    if (object_is_ancestor(owner.object_index, obj_player_base)) {
        if (variable_instance_exists(owner, "aim_valid") && owner.aim_valid) {
            return point_direction(owner.x, owner.y, owner.aim_target_x, owner.aim_target_y);
        }
        // 兜底：准心还没跑过（游戏第一帧等），退回 mouse_x
        return point_direction(owner.x, owner.y, mouse_x, mouse_y);
    }
    
    // ===== 敌人：指向目标 =====
    if (object_is_ancestor(owner.object_index, obj_enemy_base)) {
        if (instance_exists(owner.target)) {
            return point_direction(owner.x, owner.y, owner.target.x, owner.target.y);
        }
        if (owner._ai_dir != undefined) {
            return owner._ai_dir;
        }
        return owner.facing_dir * 90;
    }
    
    return 0;
}