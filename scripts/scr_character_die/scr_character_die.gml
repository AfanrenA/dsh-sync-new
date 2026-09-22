// ============================================================
// scr_character_die - 角色死亡处理（V3 模块化）
// ============================================================

/// @description 处理角色死亡
/// @param {instance} _inst 角色实例
function scr_character_die(_inst) {
    if (!instance_exists(_inst)) exit;
    if (_inst.is_dead) exit;
    
    // ---- 标记死亡 ----
    _inst.is_dead = true;
    show_debug_message("💀 " + string(object_get_name(_inst.object_index)) + " 死亡");
    
    // ---- ★ 生成死亡特效 ★ ----
    spawn_death_effect(_inst);
    
    // ---- 掉落武器（如果有） ----
    if (variable_instance_exists(_inst, "current_weapon") && 
        instance_exists(_inst.current_weapon)) {
        var _drop_x = _inst.x + random_range(-30, 30);
        var _drop_y = _inst.y + random_range(-30, 30);
        if (script_exists(scr_weapon_drop)) {
            scr_weapon_drop(_inst.current_weapon, _drop_x, _drop_y);
        }
        _inst.current_weapon = noone;
    }
    
    // ---- 销毁自身 ----
    instance_destroy(_inst);
}