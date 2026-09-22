// ===== 画发光椭圆环（多层叠加模拟发光） =====
var _w = 32;
var _h = 12;

// 外发光（低 alpha，大）
draw_set_alpha(0.25 * image_alpha);
draw_set_color(halo_color);
draw_ellipse(x - _w * 1.4, y - _h * 1.4, x + _w * 1.4, y + _h * 1.4, true);

// 中层
draw_set_alpha(0.5 * image_alpha);
draw_ellipse(x - _w * 1.15, y - _h * 1.15, x + _w * 1.15, y + _h * 1.15, true);

// 主体（亮）
draw_set_alpha(0.9 * image_alpha);
draw_set_color(c_white);
draw_ellipse(x - _w, y - _h, x + _w, y + _h, true);

draw_set_alpha(1);
draw_set_color(c_white);