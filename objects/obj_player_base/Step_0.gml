// ======================================================================
// obj_player_base - Step 事件（V3 标准）
// ======================================================================

// ============================================================
// 1. ★ 先执行父对象（地面检测 + 受击反馈更新）★
// ============================================================
event_inherited();
// 调试：检查 current_weapon 类型
if (instance_exists(current_weapon)) {
    show_debug_message("🔍 current_weapon: " + string(object_get_name(current_weapon.object_index)));
}
// ============================================================
// 2. 玩家移动（WASD + 八方向归一化）
// ============================================================
// 检查是否处于硬直状态
if (is_in_hit_stun) {
    // 硬直中不能移动，跳过移动逻辑
} else {
    var _spd = move_speed;
    var _dx = 0;
    var _dy = 0;

    if (keyboard_check(ord("A"))) _dx -= 1;
    if (keyboard_check(ord("D"))) _dx += 1;
    if (keyboard_check(ord("W"))) _dy -= 1;
    if (keyboard_check(ord("S"))) _dy += 1;

    // 八方向归一化
    if (_dx != 0 && _dy != 0) {
        _dx *= 0.707;
        _dy *= 0.707;
    }

    // 应用移动
    x += _dx * _spd;
    y += _dy * _spd;
    
    // ★ 更新朝向（根据移动方向）★
    if (_dx != 0) {
        facing = sign(_dx);
        image_xscale = facing;
    }
}

scr_character_resolve_collision(id);
// ============================================================
// 3. ★ 攻击逻辑 ★
// ============================================================
if (mouse_check_button(mb_left)) {
    if (!instance_exists(current_weapon)) return;
    
    if (instance_exists(current_weapon) && variable_instance_exists(current_weapon, "can_fire")) {
    if (current_weapon.can_fire()) {
            // ★ 获取鼠标目标位置 ★
            var _tx = mouse_x;
            var _ty = mouse_y;
            
            // ★ 传递完整参数：owner, weapon, target_x, target_y ★
            script_execute(current_weapon.attack_behavior, id, current_weapon, _tx, _ty);
        }
        current_weapon.attack_cooldown = current_weapon.cooldown;
        current_weapon.cooldown_max = current_weapon.cooldown;
        show_debug_message("🔫 射击！冷却: " + string(current_weapon.attack_cooldown));
    } else if (current_weapon.needs_reload()) {
        current_weapon.start_reload();
        show_debug_message("🔄 触发换弹");
    }
}

scr_character_resolve_collision(id);