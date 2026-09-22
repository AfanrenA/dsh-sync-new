// obj_player_base Step 事件

event_inherited();

if (is_dead) {
    scr_player_death(self);
    scr_player_death_update(self);
    exit;
}

// ===== 输入收集 =====
scr_player_input_update(self);          // 移动输入
scr_player_attack_input_update(self);   // 攻击输入

// ===== 移动 =====
scr_player_move_update(self);

// ===== 拾取 =====
scr_player_pickup_update(self);

// ===== 玩家碰撞伤害 =====
scr_collision_damage(self);

// ===== 伤害/护盾 =====
scr_player_damage_update(self);

// ===== 本命遗物：按 R 激活 =====
if (keyboard_check_pressed(ord("R"))) {
    scr_relic_try_activate(self);
}
// ===== 背包 UI =====
if (keyboard_check_pressed(vk_tab)) {
    inventory_ui_open = !inventory_ui_open;    // Tab：开关
}
if (keyboard_check_pressed(vk_escape) && inventory_ui_open) {
    inventory_ui_open = false;                  // ESC：只在开着时关闭
}
// ===== 提示冷却递减 =====
if (skill_hint_cooldown > 0) {
    skill_hint_cooldown -= 1;
}
// ===== 武器切换 =====
if (keyboard_check_pressed(ord("1"))) {
    scr_weapon_slot_switch(self, 0);
}
if (keyboard_check_pressed(ord("2"))) {
    scr_weapon_slot_switch(self, 1);
}
// ===== 武器切换过渡更新 =====
if (weapon_switch_timer > 0) {
    weapon_switch_timer -= 1;
    
    if (weapon_switch_timer <= 0) {
        weapon_switch_timer = 0;
        if (instance_exists(current_weapon)) {
            // ★ 先拉位置（visible=false 期间武器 Step 跳过了 follow_owner）
            scr_weapon_follow_owner(current_weapon);
            
            // ★ 关键：先设角度，再设 visible
            current_weapon.image_angle = weapon_switch_old_angle;
            current_weapon.visible = true;
            
            // 平滑转回鼠标方向
            current_weapon._aim_state = "smoothing";
            current_weapon._aim_timer = 25;
            current_weapon._aim_start_angle = weapon_switch_old_angle;
            
            current_weapon.flash_timer = 10;
        }
    }
}

// ★★★ 临时排序测试（测完删除）★★★
if (keyboard_check_pressed(vk_f1)) {
    scr_inventory_sort(self);
    show_debug_message("[SORT TEST] 排序完成，背包长度: " + string(array_length(inventory)));
}

if (keyboard_check_pressed(vk_space)) {
    show_debug_message("[DASH] 空格 | is_dashing=" + string(is_dashing) + " | agility_instance=" + string(agility_instance) + " | exists=" + string(instance_exists(agility_instance)));
    if (!is_dashing && agility_instance != noone && instance_exists(agility_instance)) {
        show_debug_message("[DASH] cooldown=" + string(agility_instance.cooldown_timer));
        if (agility_instance.cooldown_timer <= 0) {
            scr_agility_dash(id, data_agility_get("dash"));
        }
    }
}

// 冷却递减
if (agility_instance != noone && instance_exists(agility_instance)) {
    if (agility_instance.cooldown_timer > 0) agility_instance.cooldown_timer--;
}
if (dash_lockout_timer > 0) dash_lockout_timer--;
// 闪避计时
if (is_dashing) {
    dash_timer--;
    if (dash_timer <= 0) is_dashing = false;
}

// ===== 本命遗物：生效计时（冷却递减已移到 obj_relic_base 的 Step）=====
if (instance_exists(relic_slot)) {
    if (relic_slot.is_active) {
        relic_slot.active_timer -= 1;
        if (relic_slot.active_timer <= 0) {
            relic_slot.active_timer = 0;
            scr_relic_deactivate(self, relic_slot);
        }
    }
}

