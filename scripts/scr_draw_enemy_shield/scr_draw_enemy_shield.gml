/// @description 绘制敌人头顶护盾条（自适应精灵宽度，居中）
/// @param {id} _enemy 敌人实例

function scr_draw_enemy_shield(_enemy) {
    // ===== 1. 基础检查 =====
    if (_enemy.is_dead || !_enemy.is_alive) return;
    if (!variable_struct_exists(_enemy, "max_shield")) return;
    if (_enemy.max_shield <= 0) return;
    
    // ===== 2. 判断是否显示护盾 =====
    // 条件：护盾值 > 0，或者护盾满展示中
    var _show = false;
    var _is_full = (_enemy.shield >= _enemy.max_shield && _enemy.max_shield > 0);
    var _is_showing_full = (_enemy.shield_full_show_timer > 0 && _enemy.shield_full_show_alpha > 0);
    
    // 护盾值 > 0 时显示，或者护盾满展示中
    if (_enemy.shield > 0) {
        _show = true;
    } else if (_is_showing_full && _is_full) {
        _show = true;  // 满护盾展示期间显示
    }
    
    if (!_show) return;
    
    var _shield_ratio = clamp(_enemy.shield / _enemy.max_shield, 0, 1);
    
    // ===== 3. 位置和尺寸 =====
    var _sprite_w = sprite_get_width(_enemy.sprite_index);
    var _bar_w = max(_sprite_w - 10, 20);
    var _bar_h = 3;
    var _bar_x = _enemy.x - _bar_w / 2;
    var _bar_y = _enemy.y - sprite_get_height(_enemy.sprite_index) / 2 - 16 - _bar_h - 3;
    
    // ===== 4. 颜色 =====
    var _color = c_dkgray;
    if (_shield_ratio > 0.5) {
        _color = merge_color(c_gray, c_silver, (_shield_ratio - 0.5) * 2);
    }
    
    // 满展示时使用更亮颜色
    if (_is_showing_full && _is_full) {
        _color = c_white;
        // 呼吸闪烁效果
        var _breath = 0.7 + 0.3 * sin(current_time / 300);
        draw_set_alpha(_breath * _enemy.shield_full_show_alpha);
    } else {
        draw_set_alpha(0.85);
    }
    
    // ===== 5. 绘制 =====
    // 背景
    draw_set_color(c_black);
    draw_set_alpha(0.5);
    draw_rectangle(_bar_x - 1, _bar_y - 1, _bar_x + _bar_w + 1, _bar_y + _bar_h + 1, false);
    draw_set_alpha(1);
    
    // 护盾填充
    draw_set_color(_color);
    draw_set_alpha(0.85);
    draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w * _shield_ratio, _bar_y + _bar_h, false);
    draw_set_alpha(1);
    
    // 边框
    draw_set_color(c_white);
    draw_set_alpha(0.2);
    draw_rectangle(_bar_x - 1, _bar_y - 1, _bar_x + _bar_w + 1, _bar_y + _bar_h + 1, true);
    draw_set_alpha(1);
    
    // 如果是满展示状态，绘制发光边框
    if (_is_showing_full && _is_full) {
        var _glow = 0.3 + 0.2 * sin(current_time / 200);
        draw_set_color(c_white);
        draw_set_alpha(_glow * _enemy.shield_full_show_alpha);
        draw_rectangle(_bar_x - 2, _bar_y - 2, _bar_x + _bar_w + 2, _bar_y + _bar_h + 2, true);
        draw_set_alpha(1);
    }
}