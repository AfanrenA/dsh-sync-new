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

// ===== 拾取（★ 背包打开时不拾取，F 键归背包 UI 管）=====
if (!inventory_ui_open) {
    scr_player_pickup_update(self);
}

// ===== 玩家碰撞伤害 =====
scr_collision_damage(self);

// ===== 伤害/护盾 =====
scr_player_damage_update(self);

// ===== 被动遗物：每帧驱动（含脱战计时）=====
//   ★ 必须在 inventory_ui_open 的 exit 之前 —— 脱战计时/回血不该因为开背包就停
scr_relic_passive_update(self);

// ===== 背包 UI 开关 =====
if (keyboard_check_pressed(vk_tab)) {
    inventory_ui_open = !inventory_ui_open;    // Tab：开关
}
if (keyboard_check_pressed(vk_escape) && inventory_ui_open) {
    inventory_ui_open = false;                  // ESC：只在开着时关闭
}

// ★★★ 背包打开期间：屏蔽一切"会作用到角色"的操作 ★★★
//   用户要求：打开背包后不管按左键右键还是什么，角色都不要响应。
//   （移动/攻击已在 scr_player_input_update / scr_player_attack_input_update
//     里清零；武器单发模式在 obj_weapon_ranged_base/Step_0 里单独拦；
//     这里拦的是"动作类"按键：R 放遗物 / 1 2 切武器 / 空格闪避）
if (inventory_ui_open) {
    // 提示冷却照常递减（纯 UI 状态，不影响角色）
    if (skill_hint_cooldown > 0) skill_hint_cooldown -= 1;
    exit;
}

// ===== 本命遗物：按 R 激活 =====
if (keyboard_check_pressed(ord("R"))) {
    scr_relic_try_activate(self);
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
// ★ 已移除：原来这里递减 agility_instance.cooldown_timer，
//   与 scr_character_state_update 的第 3b 段重复 → 身法冷却以 2 倍速回。
//   冷却统一由 scr_character_state_update 递减（玩家/敌人共用）。
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

