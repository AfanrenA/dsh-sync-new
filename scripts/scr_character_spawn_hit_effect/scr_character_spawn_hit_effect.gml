// ============================================================
// scr_character_spawn_hit_effect - 受击特效入口
// 由角色调用，根据角色类型选择颜色
// ============================================================

function scr_character_spawn_hit_effect(inst, hit_direction = 0) {
    if (!instance_exists(inst)) exit;
    
    var _color = c_white;
    
    if (object_is_ancestor(inst.object_index, obj_player_base)) {
        _color = c_blue;
    } else if (object_is_ancestor(inst.object_index, obj_enemy_base)) {
        _color = c_red;
    }
    
    spawn_hit_effect(inst.x, inst.y, hit_direction, _color);
}