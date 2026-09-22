// ======================================================================
// scr_weapon_aim.gml
// 计算武器朝向角度（玩家朝鼠标，敌人朝玩家）
// 数据驱动：从 data_weapon 读取参数
// ======================================================================

/// @description 计算武器的基础朝向角度
/// @param {instance} _owner 持有者（玩家或敌人实例）
/// @param {instance} _target 目标（可选，敌人攻击时传入玩家实例）
/// @returns {real} 基础角度（0-360）
function scr_weapon_aim(_owner, _target) {
    // 玩家：朝鼠标方向
    if (_owner.object_index == obj_player || _owner.object_index == obj_player_base) {
        return point_direction(_owner.x, _owner.y, mouse_x, mouse_y);
    }
    
    // 敌人：朝目标方向（如果没有目标，保持当前方向）
    if (instance_exists(_target)) {
        return point_direction(_owner.x, _owner.y, _target.x, _target.y);
    }
    
    // 默认：朝右
    return 0;
}