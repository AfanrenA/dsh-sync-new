// obj_screen_effect Draw GUI 事件
/// @description 绘制屏幕边缘效果
//show_debug_message("[GUI] GUI尺寸: " + string(display_get_gui_width()) + "x" + string(display_get_gui_height()) + " | 窗口: " + string(window_get_width()) + "x" + string(window_get_height()));
var _w = display_get_gui_width();
var _h = display_get_gui_height();

// ===== 1. 绘制边缘红圈（更明显） =====
if (edge_alpha > 0) {
    // 更宽的边缘
    var _radius = 60;  // 从 30 增加到 60
    
    // 多层叠加让颜色更饱和
    draw_set_color(edge_color);
    
    // 第一层：半透明
    draw_set_alpha(edge_alpha * 0.8);
    draw_rectangle(0, 0, _w, _radius, false);
    draw_rectangle(0, _h - _radius, _w, _h, false);
    draw_rectangle(0, 0, _radius, _h, false);
    draw_rectangle(_w - _radius, 0, _w, _h, false);
    
    // 第二层：内侧渐弱（内发光效果）
    draw_set_alpha(edge_alpha * 0.3);
    var _inner_radius = 20;
    draw_rectangle(0, 0, _w, _inner_radius, false);
    draw_rectangle(0, _h - _inner_radius, _w, _h, false);
    draw_rectangle(0, 0, _inner_radius, _h, false);
    draw_rectangle(_w - _inner_radius, 0, _w, _h, false);
    
    draw_set_alpha(1);
}
//show_debug_message("[SCREEN] Draw GUI: shield_edge_alpha=" + string(shield_edge_alpha));
// ===== 2. 绘制护盾白圈 =====
if (shield_edge_alpha > 0) {
    var _shield_radius = 40;  // 从 20 增加到 40
    
    draw_set_color(c_white);
    draw_set_alpha(shield_edge_alpha * 0.9);
    draw_rectangle(0, 0, _w, _shield_radius, false);
    draw_rectangle(0, _h - _shield_radius, _w, _h, false);
    draw_rectangle(0, 0, _shield_radius, _h, false);
    draw_rectangle(_w - _shield_radius, 0, _w, _h, false);
    
    draw_set_alpha(1);
}