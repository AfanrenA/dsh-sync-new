/// @description 飞刀投掷物 - 创建
event_inherited();

// ---- 覆盖父类参数 ----
speed = 14;
max_range = 600;
damage = 15;

// ---- 飞刀专属 ----
bleed_damage = 3;
bleed_duration = 120;
bleed_interval = 15;
pierce = false;
element = "none";
element_damage = 0;
trail_color = c_lime;

// ---- 运行时 ----
trail_timer = 0;

// ---- ★★★ 覆盖父类回调：命中敌人 ★★★ ----
function on_hit_enemy(_enemy) {
    // ★ 使用统一伤害函数 ★
    scr_apply_damage(_enemy, damage, owner);
    
    // 元素伤害
    if (element != "none" && element_damage > 0) {
        scr_apply_damage(_enemy, element_damage, owner);
    }
    
    // ★ 流血效果（带防御检查）★
    if (bleed_duration > 0 && variable_instance_exists(_enemy, "apply_status")) {
        _enemy.apply_status("bleed", bleed_damage, bleed_duration, bleed_interval);
    }
    
    scr_spawn_spark(x, y, trail_color, 15);
    scr_spawn_spark(x, y, c_white, 8);
    
    instance_destroy();
}

show_debug_message("🗡️ 飞刀创建");