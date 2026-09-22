// scr_player_revive.gml
// 玩家复活 - 重生到安全位置

function scr_player_revive(player_inst) {
    if (!player_inst.is_dead) return;
    
    // ===== 找安全位置 =====
    var _safe_x = player_inst.x;
    var _safe_y = player_inst.y;
    var _found = false;
    var _max_attempts = 50;
    var _min_distance = 1000;
    
    // 获取所有敌人
    var _enemies = [];
    with (obj_enemy_base) {
        if (is_alive) {
            array_push(_enemies, id);
        }
    }
    
    for (var i = 0; i < _max_attempts; i++) {
        var _test_x = random_range(0, room_width);
        var _test_y = random_range(0, room_height);
        var _safe = true;
        
        // 检查是否离所有敌人足够远
        for (var j = 0; j < array_length(_enemies); j++) {
            var _dist = point_distance(_test_x, _test_y, _enemies[j].x, _enemies[j].y);
            if (_dist < _min_distance) {
                _safe = false;
                break;
            }
        }
        
        // 检查是否在房间边界内（留边距）
        if (_safe && _test_x > 50 && _test_x < room_width - 50 && _test_y > 50 && _test_y < room_height - 50) {
            _safe_x = _test_x;
            _safe_y = _test_y;
            _found = true;
            break;
        }
    }
    
    // 如果找不到安全位置，用默认位置
    if (!_found) {
        _safe_x = 100;
        _safe_y = 100;
        show_debug_message("[REVIVE] 警告：未找到安全位置，使用默认位置");
    }
    
    // ===== 复活玩家 =====
    player_inst.is_dead = false;
    player_inst.is_alive = true;
    player_inst.hp = player_inst.max_hp;
    player_inst.image_alpha = 1;
    player_inst.image_xscale = 1;
    player_inst.image_yscale = 1;
    player_inst.x = _safe_x;
    player_inst.y = _safe_y;
    player_inst.death_timer = 0;
    player_inst.death_fade_progress = 0;
    
    // 重设武器（从武器槽恢复）
    var _slot_weapon = player_inst.weapon_slots[player_inst.active_weapon_slot];
    if (instance_exists(_slot_weapon)) {
        player_inst.current_weapon = _slot_weapon;
        _slot_weapon.owner_id = player_inst;
        _slot_weapon.is_on_ground = false;
    }
    
    // ===== 重置UI =====
    obj_game_controller.black_screen_alpha = 0;
    obj_game_controller.show_revive_hint = false;
    
    show_debug_message("[REVIVE] 玩家复活 at (" + string(_safe_x) + ", " + string(_safe_y) + ")");
}