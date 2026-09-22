// scr_draw_grenade_magazine.gml
/// @description 榴弹匣 UI（装了附件型武技时显示）
/// @param {id} _player 玩家实例
/// @param {real} _x 榴弹匣左上角 X（屏幕坐标）
/// @param {real} _y 榴弹匣左上角 Y（屏幕坐标）
function scr_draw_grenade_magazine(_player, _x, _y) {
    if (!instance_exists(_player)) return;
    if (!instance_exists(_player.skill_instance)) return;
    
    // ★ 检查当前武器是 ranged
    if (!instance_exists(_player.current_weapon)) return;
    var _weapon_data = data_weapon_get(_player.current_weapon.weapon_id);
    if (_weapon_data == undefined) return;
    if (!variable_struct_exists(_weapon_data, "type") || _weapon_data.type != "ranged") return;
    
    var _sk = _player.skill_instance;
    
    if (!variable_instance_exists(_sk, "type") || _sk.type != "附件") return;
    if (_sk.data == undefined) return;
    

    
    var _cur = _sk.ammo_current;
    var _max = _sk.ammo_max;
    if (_max <= 0) return;
    
    // ===== 布局参数（比子弹弹匣大）=====
    var _bullet_w = 64;
    var _bullet_h = 24;
    var _bullet_gap = 12;
    var _padding = 24;
    var _num_h = 64;
    var _frame_w = _bullet_w + _padding * 2;
    var _frame_h = _num_h + _max * (_bullet_h + _bullet_gap) + _padding;
    
    // ===== 背景 =====
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(_x, _y, _x + _frame_w, _y + _frame_h, false);
    draw_set_alpha(1);
    
    // ===== 边框 =====
    draw_set_color(c_white);
    draw_set_alpha(0.4);
    draw_rectangle(_x, _y, _x + _frame_w, _y + _frame_h, true);
    draw_set_alpha(1);
    
    // ===== 榴弹图标（从下往上）=====
    var _spr = spr_grenade_launcher;
    if (_spr != -1 && sprite_exists(_spr)) {
        
        var _spr_w = sprite_get_width(_spr);
        var _spr_h = sprite_get_height(_spr);
        var _sx = _bullet_w / _spr_w;
        var _sy = _bullet_h / _spr_h;
        
        for (var i = 0; i < _max; i++) {
            var _bx = _x + _padding;
            var _by = _y + _frame_h - _padding - (i + 1) * (_bullet_h + _bullet_gap) + _bullet_gap;
            
            if (i < _cur) {
                var _half_w = _bullet_w / 2;
var _half_h = _bullet_h / 2;
draw_sprite_ext(_spr, 0, _bx + _bullet_w / 2, _by + _bullet_h / 2, _sx, _sy, 0, c_white, 1);
            } else {
                draw_set_color(make_color_rgb(50, 50, 50));
                draw_rectangle(_bx, _by, _bx + _bullet_w, _by + _bullet_h, false);
            }
        }
    }
    
    // ===== 顶部数字 =====
    var _ratio = (_max > 0) ? (_cur / _max) : 0;
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
    
    draw_set_color(_num_color);
    draw_text(_num_x, _num_y, string(_cur) + "/" + string(_max));
    
    // ===== 恢复 =====
    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}