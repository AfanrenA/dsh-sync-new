function scr_draw_charge_indicator(player) {
    // ★ 从当前武器读蓄力状态
    if (!instance_exists(player.current_weapon)) return;
    if (!player.current_weapon.skill_charging) return;
    if (player.skill_charge_progress <= 0) return;
    
    // ===== 获取技能数据 =====
    var _data = data_skill_get(player.skill_slot);
    if (_data == undefined) return;
    
    // ===== 蓄力条 =====
    var _bar_width = 60;
    var _bar_height = 6;
    var _bar_x = player.x - _bar_width / 2;
    var _bar_y = player.y + 50;
    
    draw_set_alpha(0.5);
    draw_set_color(c_black);
    draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width, _bar_y + _bar_height, false);
    
    draw_set_alpha(1);
    draw_set_color(c_orange);
    var _progress = clamp(player.skill_charge_progress, 0, 1);
    draw_rectangle(_bar_x + 2, _bar_y + 1, _bar_x + 2 + (_bar_width - 4) * _progress, _bar_y + _bar_height - 1, false);
    
    draw_set_alpha(1);
    draw_set_color(c_white);
    
    // ===== 路径预测（方向与剑气同源）=====
    var _dir = scr_get_aim_direction(player);
    var _dist = player.skill_charge_distance;
    
    var _end_x = player.x + lengthdir_x(_dist, _dir);
    var _end_y = player.y + lengthdir_y(_dist, _dir);
    
    var _preview_color = c_red;
    if (_data.preview_color != undefined) {
        _preview_color = scr_get_color_from_hex(_data.preview_color);
    }
    
    // ---- 引导线 ----
    draw_set_alpha(0.4 + 0.3 * sin(current_time / 200));
    draw_set_color(_preview_color);
    draw_line_width(player.x, player.y, _end_x, _end_y, 10);
    
    // ---- 终点标记（X） ----
    draw_set_alpha(0.8);
    var _size = 16;
    draw_line_width(_end_x - _size, _end_y - _size, _end_x + _size, _end_y + _size, 4);
    draw_line_width(_end_x + _size, _end_y - _size, _end_x - _size, _end_y + _size, 4);
    
    draw_set_alpha(1);
    draw_set_color(c_white);
}