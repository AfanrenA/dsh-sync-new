/// @description 绘制护盾层（格子大小固定，格数自适应）
function scr_draw_shield_layer(_player, _x, _y, _h, _seg_w = 16) {
    var _shield = 0;
    var _max_shield = 0;
    
    if (variable_struct_exists(_player, "shield")) {
        _shield = _player.shield;
    }
    if (variable_struct_exists(_player, "max_shield")) {
        _max_shield = _player.max_shield;
    }
    
    if (_max_shield <= 0) return;
    
    var _ratio = clamp(_shield / _max_shield, 0, 1);
    
    // ===== 格数计算 =====
    var _seg_width = _seg_w;
    var _gap = 2;
    var _segments = ceil(_max_shield / 10);
    if (_segments < 1) _segments = 1;
    
    var _total_w = _segments * (_seg_width + _gap) - _gap;
    
    // ===== 颜色定义 =====
    var _color_empty = c_black;        // 空格（未填充）：灰色
    var _color_filling = c_gray;      // 正在填充中：灰色
    var _color_full = c_silver;       // 已满：银色
    var _color_border = c_white;
    
    var _full_segments = floor(_ratio * _segments);
    var _partial = (_ratio * _segments) - _full_segments;
    
    // 绘制每一格
    for (var i = 0; i < _segments; i++) {
        var _sx = _x + i * (_seg_width + _gap);
        var _sy = _y;
        
        // 充电特效（闪电从左到右）
        var _is_charged = false;
        if (_player.shield_charge_effect) {
            var _progress = _player.shield_charge_progress;
            var _threshold = (i + 1) / _segments;
            if (_progress >= _threshold) {
                _is_charged = true;
            }
        }
        
        var _is_full = (i < _full_segments);
        var _is_partial = (i == _full_segments && _partial > 0);
        
        // ===== 颜色判断 =====
        if (_is_full) {
            // 已满 → 银色
            draw_set_color(_color_full);
            draw_rectangle(_sx, _sy, _sx + _seg_width, _sy + _h, false);
        } else if (_is_partial) {
            // 部分填充：已填部分银色，未填部分灰色
            var _seg_h = _h * _partial;
            draw_set_color(_color_filling);      // 下面已满部分 → 银色
            draw_rectangle(_sx, _sy + (_h - _seg_h), _sx + _seg_width, _sy + _h, false);
            draw_set_color(_color_empty);      // 上面未满部分 → 灰色
            draw_rectangle(_sx, _sy, _sx + _seg_width, _sy + _h - _seg_h, false);
        } else if (_is_charged) {
            // 充电特效中：填满的瞬间变成银色（闪烁）
            var _flash = 0.7 + 0.3 * sin(current_time / 100 + i * 0.5);
            draw_set_color(_color_full);
            draw_set_alpha(_flash);
            draw_rectangle(_sx, _sy, _sx + _seg_width, _sy + _h, false);
            draw_set_alpha(1);
        } else {
            // 空格 → 灰色
            draw_set_color(_color_empty);
            draw_rectangle(_sx, _sy, _sx + _seg_width, _sy + _h, false);
        }
        
        // 格子边框
        draw_set_color(_color_border);
        draw_set_alpha(0.15);
        draw_rectangle(_sx, _sy, _sx + _seg_width, _sy + _h, true);
        draw_set_alpha(1);
    }
    
    // ===== 充满闪烁特效 =====
    if (_player.shield_full_flash > 0) {
        var _flash_alpha = 0.3 + 0.3 * sin(_player.shield_full_flash * 2);
        draw_set_color(c_white);
        draw_set_alpha(_flash_alpha);
        draw_rectangle(_x - 2, _y - 2, _x + _total_w + 2, _y + _h + 2, false);
        draw_set_alpha(1);
    }
    
    // 外框
    draw_set_color(_color_border);
    draw_set_alpha(0.3);
    draw_rectangle(_x - 2, _y - 2, _x + _total_w + 2, _y + _h + 2, true);
    draw_set_alpha(1);
    
    /* 图标
    draw_set_color(c_blue);
    draw_set_alpha(0.7);
    draw_text(_x - 22, _y - 2, "🛡");
    draw_set_alpha(1);
    
    // 数值
    if (_shield > 0) {
        draw_set_color(c_white);
        draw_set_alpha(0.5);
        draw_set_halign(fa_right);
        draw_set_valign(fa_middle);
        draw_text(_x + _total_w + 10, _y + _h / 2, string(_shield) + "/" + string(_max_shield));
        draw_set_alpha(1);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }*/
}