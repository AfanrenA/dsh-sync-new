/// @description 绘制电池分格血条
function draw_ui_hpbar(_player) {
    // ===== 1. 参数配置 =====
    var _max_hp = _player.max_hp;
    var _hp = max(_player.hp, 0);
    var _hp_percent = _hp / _max_hp;
    
    // ---- 分格数量 ----
    var _segments = 10;  // 分10格（像手机电量）
    
    // ---- 位置和大小 ----
    var _x = ui_hp_x;
    var _y = ui_hp_y;
    var _w = ui_hp_width;
    var _h = ui_hp_height;
    var _gap = 3;        // 格子间隙
    var _seg_w = (_w - (_segments - 1) * _gap) / _segments;
    
    // ---- 颜色 ----
    var _color_high = c_aqua;
    var _color_mid = c_yellow;
    var _color_low = c_red;
    var _color_bg = c_black;
    var _color_empty = c_gray;

    // 根据血量百分比选择主色
    // 60% 以上绿色，30%-60% 黄色，30% 以下红色
    var _color_fg = _color_high;
    if (_hp_percent < 0.6) _color_fg = _color_mid;
    if (_hp_percent < 0.3) _color_fg = _color_low;
    
    // ===== 2. 绘制背景 =====
    draw_set_color(_color_bg);
    draw_set_alpha(0.5);
    draw_rectangle(_x - 4, _y - 4, _x + _w + 4, _y + _h + 4, false);
    draw_set_alpha(1);
    
    // ===== 3. 绘制每一格 =====
    var _full_segments = floor(_hp_percent * _segments);
    var _partial = (_hp_percent * _segments) - _full_segments;
    
    for (var i = 0; i < _segments; i++) {
        var _sx = _x + i * (_seg_w + _gap);
        var _sy = _y;
        
        // 决定这一格的颜色
        var _color = _color_empty;
        if (i < _full_segments) {
            _color = _color_fg;
        } else if (i == _full_segments && _partial > 0) {
            // 最后一格部分填充
            _color = _color_fg;
            // 绘制部分填充的格子
            var _seg_h = _h * _partial;
            draw_set_color(_color_fg);
            draw_rectangle(_sx, _sy + (_h - _seg_h), _sx + _seg_w, _sy + _h, false);
            draw_set_color(_color_empty);
            draw_rectangle(_sx, _sy, _sx + _seg_w, _sy + _h - _seg_h, false);
            continue;
        }
        
        // 绘制完整格子
        draw_set_color(_color);
        draw_rectangle(_sx, _sy, _sx + _seg_w, _sy + _h, false);
    }
    
    // ===== 4. 绘制边框 =====
    draw_set_color(c_white);
    draw_set_alpha(0.3);
    draw_rectangle(_x - 4, _y - 4, _x + _w + 4, _y + _h + 4, true);
    draw_set_alpha(1);
    
  /*  // ===== 5. 血量数字 =====
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var _text = string(_hp) + "/" + string(_max_hp);
    draw_text(_x + _w / 2, _y + _h / 2, _text);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);*/
    
    // ===== 6. 电池图标装饰 =====
    draw_set_color(c_white);
    draw_set_alpha(0.5);
    // 电池正极端子（小凸起）
    draw_rectangle(_x + _w + 4, _y + _h * 0.3, _x + _w + 10, _y + _h * 0.7, false);
    draw_set_alpha(1);
}