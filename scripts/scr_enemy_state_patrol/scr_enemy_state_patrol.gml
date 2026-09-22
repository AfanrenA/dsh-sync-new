/// @function scr_enemy_state_patrol(enemy)
/// @param {id} enemy - 敌人实例
/// @description 纯执行：巡逻行为（随机转向 + 移动）

function scr_enemy_state_patrol(enemy) {
    // ===== 随机转向 =====
    enemy._patrol_timer -= 1;
    if (enemy._patrol_timer <= 0) {
        enemy._patrol_dir = irandom(7) * 45;
        enemy._patrol_timer = 480 + irandom(420);
    }
    
    // ===== 巡逻移动 =====
    var _ai = enemy.entity_data.ai;
    var _speed = _ai.patrol_speed != undefined ? _ai.patrol_speed : 1;
    var _new_x = enemy.x + lengthdir_x(_speed, enemy._patrol_dir);
    var _new_y = enemy.y + lengthdir_y(_speed, enemy._patrol_dir);
    
    // 边界检测
    var _margin = 80;
    if (_new_x < _margin || _new_x > room_width - _margin ||
        _new_y < _margin || _new_y > room_height - _margin) {
        enemy._patrol_dir += 180;
        enemy._patrol_timer = 600;
        return;
    }
    
    // 碰撞体检测（预留）
    // if (place_meeting(_new_x, _new_y, obj_solid)) {
    //     enemy._patrol_dir += 90 + irandom(90);
    //     enemy._patrol_timer = 300;
    //     return;
    // }
    
    enemy.x = _new_x;
    enemy.y = _new_y;
    
    // ===== 朝向 =====
    enemy.facing_dir = sign(cos(degtorad(enemy._patrol_dir)));
    enemy.image_xscale = enemy.facing_dir;
}