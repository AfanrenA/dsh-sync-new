event_inherited();
//show_debug_message("[DEATH] ★ obj_enemy_base Step 执行中 ★");
// ===== ★ 死亡检查（必须放在最前面） =====
// obj_enemy_base Step 事件 开头
// obj_enemy_base Step 事件 开头

if (is_dead) {
    death_timer += 1 / 60;
    var _total_duration = 1.5;
    var _progress = death_timer / _total_duration;
    
    // ★ 只做淡出，不生成粒子
    if (_progress < 0.1) {
        image_blend = c_white;
        image_alpha = 1;
    } else if (_progress < 1.0) {
        var _fade_progress = (_progress - 0.1) / 0.9;
        image_alpha = 1 - _fade_progress;
        image_blend = c_white;
        y -= 0.3;
    } else {
        image_alpha = 0;
        instance_destroy();
    }
    exit;
}

// ===== 预警计时器处理（已废弃，改用 charging 状态） =====
if (ai_state == "telegraph") {
    telegraph_timer -= 1;
    if (telegraph_timer <= 0) {
        ai_state = "attack";
        if (enemy_skill_id != "" && enemy_skill_id != undefined) {
            var _charge_time = 1 + random(2);
            scr_skill_cast(self, enemy_skill_id, _charge_time);
            enemy_skill_cooldown = enemy_skill_max_cooldown;
            show_debug_message("[AI] " + object_get_name(object_index) + " 释放技能: " + enemy_skill_id);
        }
    }
    exit;
}

// ============================================================
// ★ 核心 AI 更新
// ============================================================
scr_enemy_ai_update(self);

// ============================================================
// 武器更新
// ============================================================
if (instance_exists(current_weapon)) {
    scr_weapon_swing_update(current_weapon);
}

// ============================================================
// 护盾恢复
// ============================================================
scr_shield_update(self);

// ===== 血条计时器（受击后显示） =====
if (hpbar_timer > 0) {
    hpbar_timer -= 1;
    hpbar_alpha = 1;
    hpbar_visible = true;
} else {
    if (hpbar_alpha > 0) {
        hpbar_alpha -= 0.02;
        if (hpbar_alpha < 0) hpbar_alpha = 0;
    }
    if (hpbar_alpha <= 0) {
        hpbar_visible = false;
    }
}