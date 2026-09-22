// ============================================================
// scr_character_apply_knockback
// 对角色施加击退效果（位移 + 减速）
// V3 原则：独立脚本，可被任何角色调用
// ============================================================

function scr_character_apply_knockback(inst, direction, power) {
    /// @param inst       角色实例
    /// @param direction  击退方向（角度）
    /// @param power      击退力度
    
    if (!instance_exists(inst)) exit;
    if (inst.hp <= 0) exit;
    
    // ========== 应用位移 ==========
    var _knock_x = lengthdir_x(power, direction);
    var _knock_y = lengthdir_y(power, direction);
    
    inst.x += _knock_x;
    inst.y += _knock_y;
    
    // ========== 速度归零（防止滑行） ==========
    if (variable_instance_exists(inst, "hspeed")) inst.hspeed = 0;
    if (variable_instance_exists(inst, "vspeed")) inst.vspeed = 0;
    if (variable_instance_exists(inst, "xspeed")) inst.xspeed = 0;
    if (variable_instance_exists(inst, "yspeed")) inst.yspeed = 0;
    
    /* ========== 小幅度屏幕震动（仅玩家） ==========
    if (inst.object_index == obj_player_base || inst.object_index == obj_player) {
        if (script_exists(scr_camera_shake)) {
            scr_camera_shake(power * 0.3, 4);
        }
    }*/
}