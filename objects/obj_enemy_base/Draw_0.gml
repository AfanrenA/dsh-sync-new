// obj_enemy_base Draw 事件
event_inherited();

// ===== 血条和护盾条统一显示控制 =====
if (hpbar_visible && hpbar_alpha > 0) {
    draw_set_alpha(hpbar_alpha);
    
    // 1. 护盾条（如果有护盾且 > 0）
    if (max_shield > 0 && shield > 0) {
        scr_draw_enemy_shield(self);
    }
    
    // 2. 血条（始终显示）
    scr_draw_enemy_hpbar(self);
    
    draw_set_alpha(1);
}

// ===== 敌人蓄力条 =====
if (!is_dead && ai_state == "charging" && skill_charge_target > 0) {
    var _bar_width = 60;
    var _bar_height = 6;
    var _bar_x = x - _bar_width / 2;
    var _bar_y = y + 50;
    
    draw_set_alpha(0.5);
    draw_set_color(c_black);
    draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width, _bar_y + _bar_height, false);
    
    draw_set_alpha(1);
    draw_set_color(c_orange);
    var _progress = clamp(_charge_timer / skill_charge_target, 0, 1);
    draw_rectangle(_bar_x + 2, _bar_y + 1, _bar_x + 2 + (_bar_width - 4) * _progress, _bar_y + _bar_height - 1, false);
    
    draw_set_alpha(1);
    draw_set_color(c_white);
}
