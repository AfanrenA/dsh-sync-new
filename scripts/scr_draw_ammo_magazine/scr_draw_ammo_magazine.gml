// scr_draw_ammo_magazine.gml
/// @description 纵向弹匣 UI（仅当前武器为远程时显示）
/// @param {id} _player 玩家实例
/// @param {real} _x 弹匣左上角 X（屏幕坐标）
/// @param {real} _y 弹匣左上角 Y（屏幕坐标）
function scr_draw_ammo_magazine(_player, _x, _y) {
    if (!instance_exists(_player)) return;
    if (!instance_exists(_player.current_weapon)) return;
    
    var _weapon = _player.current_weapon;
    if (!variable_instance_exists(_weapon, "max_ammo")) return;
    
    var _cur = _weapon.current_ammo;
    var _max = _weapon.max_ammo;
    if (_max <= 0) return;
    
    var _is_reloading = variable_instance_exists(_weapon, "is_reloading") && _weapon.is_reloading;
    
    // ★ 显示数量：换弹中用 reload_progress（装了几颗亮几颗），平时用 current_ammo
    var _show_count = _is_reloading ? _weapon.reload_progress : _cur;
    
    // ===== 布局参数 =====
    var _bullet_w = 48;
    var _bullet_h = 18;
    var _bullet_gap = 9;
    var _padding = 18;
    var _num_h = 48;
    var _frame_w = _bullet_w + _padding * 2;
    var _frame_h = _num_h + _max * (_bullet_h + _bullet_gap) + _padding;
    
    // 弹匣背景
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(_x, _y, _x + _frame_w, _y + _frame_h, false);
    draw_set_alpha(1);
    
    // 弹匣边框
    draw_set_color(c_white);
    draw_set_alpha(0.4);
    draw_rectangle(_x, _y, _x + _frame_w, _y + _frame_h, true);
    draw_set_alpha(1);
    
    // 子弹（从下往上）
    for (var i = 0; i < _max; i++) {
        var _bx = _x + _padding;
        var _by = _y + _frame_h - _padding - (i + 1) * (_bullet_h + _bullet_gap) + _bullet_gap;
        
        if (i < _show_count) {
            draw_set_color(c_aqua);
        } else {
            draw_set_color(make_color_rgb(50, 50, 50));
        }
        draw_rectangle(_bx, _by, _bx + _bullet_w, _by + _bullet_h, false);
    }
    
    // 顶部数字
    var _ratio = _show_count / _max;
    var _num_color = c_white;
    if (_ratio < 0.3) {
        _num_color = c_red;
    } else if (_ratio <= 0.6) {
        _num_color = c_yellow;
    }
    
    draw_set_font(font_ammo);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var _num_x = _x + _frame_w / 2;
    var _num_y = _y + _num_h / 2;
    
    var _num_str;
    if (_is_reloading) {
        _num_str = string(_weapon.reload_progress) + "/" + string(_max);
    } else {
        _num_str = string(_cur);
    }
    
    draw_set_color(_num_color);
    draw_text(_num_x, _num_y, _num_str);
    
    // 恢复
    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}