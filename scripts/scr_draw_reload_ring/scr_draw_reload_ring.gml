// scr_draw_reload_ring.gml
/// @description 换弹进度圈（只在玩家远程武器 is_reloading 时显示）
function scr_draw_reload_ring(_weapon) {
    if (!instance_exists(_weapon)) return;
    if (!variable_instance_exists(_weapon, "is_reloading")) return;
    if (!_weapon.is_reloading) return;
    if (!instance_exists(_weapon.owner_id)) return;
    if (!object_is_ancestor(_weapon.owner_id.object_index, obj_player_base)) return;
    
    var _owner = _weapon.owner_id;
    var _cx = _owner.x;
    var _cy = _owner.y - 80;
    var _radius = 32;
    var _thickness = 5;
    
    var _progress = _weapon.reload_progress / max(_weapon.max_ammo, 1);
    
    // ===== 背景圈（半透明黑） =====
    draw_set_alpha(0.5);
    draw_circle_color(_cx, _cy, _radius, c_black, c_black, false);
    draw_set_alpha(1);
    
    // ===== 进度弧（手动画：顶部顺时针填充） =====
    if (_progress > 0) {
        var _segments = 32;
        var _total_angle = 360 * _progress;
        var _angle_per_seg = _total_angle / _segments;
        
        draw_set_color(make_color_rgb(100, 200, 255));
        draw_primitive_begin(pr_trianglelist);
        
        for (var i = 0; i < _segments; i++) {
            var _a1 = 90 - i * _angle_per_seg;
            var _a2 = 90 - (i + 1) * _angle_per_seg;
            
            var _x1o = _cx + lengthdir_x(_radius, _a1);
            var _y1o = _cy + lengthdir_y(_radius, _a1);
            var _x2o = _cx + lengthdir_x(_radius, _a2);
            var _y2o = _cy + lengthdir_y(_radius, _a2);
            
            var _x1i = _cx + lengthdir_x(_radius - _thickness, _a1);
            var _y1i = _cy + lengthdir_y(_radius - _thickness, _a1);
            var _x2i = _cx + lengthdir_x(_radius - _thickness, _a2);
            var _y2i = _cy + lengthdir_y(_radius - _thickness, _a2);
            
            // 两个三角形拼成一个扇形段
            draw_vertex(_x1o, _y1o);
            draw_vertex(_x1i, _y1i);
            draw_vertex(_x2i, _y2i);
            
            draw_vertex(_x1o, _y1o);
            draw_vertex(_x2i, _y2i);
            draw_vertex(_x2o, _y2o);
        }
        
        draw_primitive_end();
    }
    
    // ===== 数字 2/5 =====
    var _cur = _weapon.reload_progress;
    var _max = _weapon.max_ammo;
    var _ratio = _cur / max(_max, 1);
    
    var _left_color = c_white;
    if (_ratio < 0.3) {
        _left_color = c_red;
    } else if (_ratio <= 0.6) {
        _left_color = c_orange;
    }
    
    draw_set_font(font_chinese);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    
    var _left_str = string(_cur);
    var _right_str = "/" + string(_max);
    var _left_w = string_width(_left_str);
    var _right_w = string_width(_right_str);
    var _total_w = _left_w + _right_w;
    var _start_x = _cx - _total_w / 2;
    
    draw_set_color(_left_color);
    draw_text(_start_x, _cy, _left_str);
    
    draw_set_color(c_white);
    draw_text(_start_x + _left_w, _cy, _right_str);
    
    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}