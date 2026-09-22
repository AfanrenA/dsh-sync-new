event_inherited();
if (is_reloading) {
    reload_timer -= 1;
    if (reload_timer <= 0) {
        reload_progress += 1;
        if (reload_progress > max_ammo) {
            // ★ 第 5 发装完 → 立刻结束，不显示 5/5
            current_ammo = max_ammo;
            is_reloading = false;
            reload_progress = 0;
        } else {
            reload_timer = reload_time_per_bullet;
        }
    }
}

// ===== 视觉后坐力递减 =====
if (recoil_timer > 0) recoil_timer -= 1;

// ===== 射击输入（仅玩家） =====
if (instance_exists(owner_id)) {
    if (object_is_ancestor(owner_id.object_index, obj_player_base)) {
        if (owner_id.current_weapon == id) {
            // ★ 背包打开时不开火（single 模式读的是鼠标直连，不走 input_left，得单独拦）
            if (!owner_id.inventory_ui_open) {
                if (!owner_id.is_dashing && owner_id.dash_lockout_timer <= 0) {
                    var _want_fire = false;
                    if (fire_mode == "auto") {
                        _want_fire = owner_id.input_left;
                    } else if (fire_mode == "single") {
                        _want_fire = mouse_check_button_pressed(mb_left);
                    }
                    
                    if (_want_fire && !is_reloading) {
                        scr_weapon_try_attack(id);
                    }
                }
            }
        }
    }
}