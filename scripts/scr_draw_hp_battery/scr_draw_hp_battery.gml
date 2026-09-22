/// @description 绘制电池分格血条（格子大小固定，格数自适应）
/// @param {id} _player 玩家实例
/// @param {real} _x 起始X
/// @param {real} _y 起始Y
/// @param {real} _h 格子高度
/// @param {real} _seg_w 格子宽度（可选，默认16）

function scr_draw_hp_battery(_player, _x, _y, _h, _seg_w = 16) {
    var _max_hp = 100;
    var _hp = 100;
    
    if (variable_struct_exists(_player, "max_hp")) {
        _max_hp = _player.max_hp;
    }
    if (variable_struct_exists(_player, "hp")) {
        _hp = max(_player.hp, 0);
    }
    
    if (_max_hp <= 0) return;
    
    var _hp_percent = _hp / _max_hp;
    
    // ===== 固定格子大小 =====
    var _seg_width = _seg_w;   // ← 改用不同变量名
    var _gap = 2;
    var _segments = ceil(_max_hp / 10);
    if (_segments < 1) _segments = 1;
    
    var _total_w = _segments * (_seg_width + _gap) - _gap;
    
    // 颜色
    var _color_high = c_aqua;
    var _color_mid = c_yellow;
    var _color_low = c_red;
    var _color_empty = c_black;
    
    var _color_fg = _color_high;
    if (_hp_percent < 0.6) _color_fg = _color_mid;
    if (_hp_percent < 0.3) _color_fg = _color_low;
    
    // 背景
    draw_set_color(c_black);
    draw_set_alpha(0.5);
    draw_rectangle(_x - 4, _y - 4, _x + _total_w + 4, _y + _h + 4, false);
    draw_set_alpha(1);
    
    // 每一格
    var _full_segments = floor(_hp_percent * _segments);
    var _partial = (_hp_percent * _segments) - _full_segments;
    
    for (var i = 0; i < _segments; i++) {
        var _sx = _x + i * (_seg_width + _gap);
        var _sy = _y;
        
        if (i < _full_segments) {
            draw_set_color(_color_fg);
            draw_rectangle(_sx, _sy, _sx + _seg_width, _sy + _h, false);
        } else if (i == _full_segments && _partial > 0) {
            draw_set_color(_color_fg);
            var _seg_h = _h * _partial;
            draw_rectangle(_sx, _sy + (_h - _seg_h), _sx + _seg_width, _sy + _h, false);
        } else {
            draw_set_color(_color_empty);
            draw_rectangle(_sx, _sy, _sx + _seg_width, _sy + _h, false);
        }
    }
    
    // 边框
    draw_set_color(c_white);
    draw_set_alpha(0.3);
    draw_rectangle(_x - 4, _y - 4, _x + _total_w + 4, _y + _h + 4, true);
    draw_set_alpha(1);
    
    // 电池端子
    draw_set_color(c_white);
    draw_set_alpha(0.5);
    draw_rectangle(_x + _total_w + 4, _y + _h * 0.3, _x + _total_w + 10, _y + _h * 0.7, false);
    draw_set_alpha(1);
}