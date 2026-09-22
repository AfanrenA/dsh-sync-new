// scr_weapon_aim_update.gml
function scr_weapon_aim_update(weapon) {
    // ===== 挥砍期间跳过（仅近战有 is_swinging） =====
    if (variable_instance_exists(weapon, "is_swinging") && weapon.is_swinging) return;
    
    if (!instance_exists(weapon.owner_id)) return;
    
    var _owner = weapon.owner_id;
    
    // ===== 玩家 =====
    if (object_is_ancestor(_owner.object_index, obj_player_base)) {
        var _target_angle = point_direction(weapon.x, weapon.y, mouse_x, mouse_y);
        
        switch (weapon._aim_state) {
            case "pause":
                weapon._aim_timer -= 1;
                if (weapon._aim_timer <= 0) {
                    weapon._aim_state = "smoothing";
                    weapon._aim_timer = 25;
                    weapon._aim_start_angle = weapon.image_angle;
                }
                break;
                
            case "smoothing":
                weapon._aim_timer -= 1;
                var _progress = weapon._aim_timer / 25;
                _progress = _progress * _progress;
                
                var _angle_diff = angle_difference(_target_angle, weapon._aim_start_angle);
                weapon.image_angle = weapon._aim_start_angle + _angle_diff * (1 - _progress);
                
                if (weapon._aim_timer <= 0 || abs(_angle_diff) < 1) {
                    weapon.image_angle = _target_angle;
                    weapon._aim_state = "idle";
                    weapon._aim_start_angle = 0;
                }
                break;
                
            case "aiming":
                // 用鼠标世界坐标判断朝左朝右，和 image_yscale 翻转逻辑一致
                var _facing_left_aim = (mouse_x < weapon.x);
                var _aim_target = _facing_left_aim ? (_target_angle - weapon._aim_pitch) : (_target_angle + weapon._aim_pitch);
                
                var _diff = angle_difference(_aim_target, weapon.image_angle);
                if (abs(_diff) < 3) {
                    weapon.image_angle = _aim_target;
                } else {
                    weapon.image_angle += _diff * 0.3;
                }
                break;
                
            case "recoil":
                // 阶段 1：快速抬到 _aim_fire_angle
                weapon._aim_timer -= 1;
                var _t_recoil = 1 - (weapon._aim_timer / 8);
                var _diff_recoil = angle_difference(weapon._aim_fire_angle, weapon._aim_start_angle);
                weapon.image_angle = weapon._aim_start_angle + _diff_recoil * _t_recoil;
                
                if (weapon._aim_timer <= 0) {
                    weapon.image_angle = weapon._aim_fire_angle;
                    weapon._aim_state = "hold";
                    weapon._aim_timer = weapon._aim_hold;
                }
                break;
                
            case "hold":
                // 阶段 2：停在最高点
                weapon._aim_timer -= 1;
                if (weapon._aim_timer <= 0) {
                    weapon._aim_state = "recover";
                    weapon._aim_timer = 30;
                    weapon._aim_start_angle = weapon.image_angle;
                }
                break;
                
            case "recover":
                // 阶段 3：平滑回落到鼠标方向
                weapon._aim_timer -= 1;
                var _progress_r = 1 - (weapon._aim_timer / 30);
                _progress_r = _progress_r * _progress_r;
                var _diff_r = angle_difference(_target_angle, weapon._aim_start_angle);
                weapon.image_angle = weapon._aim_start_angle + _diff_r * _progress_r;
                
                if (weapon._aim_timer <= 0) {
                    weapon.image_angle = _target_angle;
                    // 如果还在瞄准，回 aiming；否则回 idle
                    var _owner_skill = weapon.owner_id.skill_instance;
                    if (instance_exists(_owner_skill) && _owner_skill.aiming) {
                        weapon._aim_state = "aiming";
                    } else {
                        weapon._aim_state = "idle";
                    }
                }
                break;
                
            case "idle":
            default:
                weapon.image_angle = _target_angle;
                break;
        }
        
        // ★ 朝左翻转（武器精灵默认朝右，朝左时垂直翻转，保持握把在下）
        if (abs(angle_difference(weapon.image_angle, 0)) > 90) {
            weapon.image_yscale = -abs(weapon.image_yscale);
        } else {
            weapon.image_yscale = abs(weapon.image_yscale);
        }
        
        return;
    }
    
    // ===== 敌人：根据AI状态 =====
    if (object_is_ancestor(_owner.object_index, obj_enemy_base)) {
        var _aim_states = ["chase", "attack", "observe", "curious", "counter", "charging"];
        var _should_aim = false;
        for (var i = 0; i < array_length(_aim_states); i++) {
            if (_owner.ai_state == _aim_states[i]) {
                _should_aim = true;
                break;
            }
        }
        
        if (_should_aim) {
            if (_owner.ai_state == "charging") {
                if (instance_exists(_owner._telegraph_ref)) {
                    var _end_x = _owner._telegraph_ref.x + lengthdir_x(_owner._telegraph_ref.range, _owner._telegraph_ref.dir);
                    var _end_y = _owner._telegraph_ref.y + lengthdir_y(_owner._telegraph_ref.range, _owner._telegraph_ref.dir);
                    weapon.image_angle = point_direction(weapon.x, weapon.y, _end_x, _end_y);
                } else {
                    var _player = instance_find(obj_player_base, 0);
                    if (instance_exists(_player)) {
                        weapon.image_angle = point_direction(weapon.x, weapon.y, _player.x, _player.y);
                    }
                }
            } else {
                var _player = instance_find(obj_player_base, 0);
                if (instance_exists(_player)) {
                    weapon.image_angle = point_direction(weapon.x, weapon.y, _player.x, _player.y);
                }
            }
        } else {
            weapon.image_angle = _owner.facing_dir < 0 ? 180 : 0;
        }
        
        // ★ 敌人也翻转
        if (abs(angle_difference(weapon.image_angle, 0)) > 90) {
            weapon.image_yscale = -abs(weapon.image_yscale);
        } else {
            weapon.image_yscale = abs(weapon.image_yscale);
        }
    }
}