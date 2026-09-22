/// @function scr_enemy_state_chase(enemy)
/// @param {id} enemy - 敌人实例
/// @description 纯执行：追击行为（向目标方向移动）

function scr_enemy_state_chase(enemy) {
    var p = enemy._perception;
    if (!p.has_target) {
        return;
    }
    
    var _ai = enemy.entity_data.ai;
    var _chase_speed = _ai.chase_speed != undefined ? _ai.chase_speed : 1.5;
    var _dir = p.dir_to_target;
    
    // ===== 处理背后转身延迟 =====
    if (enemy._need_turn) {
        enemy._turn_timer -= 1;
        
        var _target_angle = p.dir_to_target;
        var _current_angle = enemy.facing_dir * 90;
        var _angle_diff = angle_difference(_target_angle, _current_angle);
        
        var _turn_speed = 15;
        if (abs(_angle_diff) > _turn_speed) {
            _current_angle += sign(_angle_diff) * _turn_speed;
        } else {
            _current_angle = _target_angle;
        }
        
        enemy.facing_dir = sign(cos(degtorad(_current_angle)));
        enemy.image_xscale = enemy.facing_dir;
        
        if (enemy._turn_timer <= 0 || abs(_angle_diff) < 5) {
            enemy._need_turn = false;
            enemy.facing_dir = sign(cos(degtorad(p.dir_to_target)));
            enemy.image_xscale = enemy.facing_dir;
        }
        return;
    }
    
    // ===== 面向目标 =====
    enemy.facing_dir = sign(cos(degtorad(_dir)));
    enemy.image_xscale = enemy.facing_dir;
    
    // ===== 追击移动 =====
    enemy.x += lengthdir_x(_chase_speed, _dir);
    enemy.y += lengthdir_y(_chase_speed, _dir);
}