/// @description 绘制敌人头顶血条（自适应精灵宽度，居中）
/// @param {id} _enemy 敌人实例

function scr_draw_enemy_hpbar(_enemy) {
    if (_enemy.is_dead || !_enemy.is_alive) return;
    if (_enemy.max_hp <= 0) return;
    
    var _hp_percent = clamp(_enemy.hp / _enemy.max_hp, 0, 1);
    
    // ===== 自适应宽度（比精灵宽度小 10 像素，居中） =====
    var _sprite_w = sprite_get_width(_enemy.sprite_index);
    var _bar_w = max(_sprite_w - 10, 20);  // 最小 20px
    var _bar_h = 5;
    var _bar_x = _enemy.x - _bar_w / 2;
    var _bar_y = _enemy.y - sprite_get_height(_enemy.sprite_index) / 2 - 16;
    
    // 背景（黑色）
    draw_set_color(c_black);
    draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);
    
    // 血量颜色
    if (_hp_percent > 0.5) {
        draw_set_color(c_green);
    } else if (_hp_percent > 0.25) {
        draw_set_color(c_yellow);
    } else {
        draw_set_color(c_red);
    }
    
    // 血量填充（缩进 1px）
    draw_rectangle(
        _bar_x + 1,
        _bar_y + 1,
        _bar_x + 1 + (_bar_w - 2) * _hp_percent,
        _bar_y + _bar_h - 1,
        false
    );
}