/// @description 画落地预警圈

if (!is_active) exit;

// 半透明红色填充
draw_set_alpha(0.2);
draw_set_color(c_red);
draw_circle(x, y, radius, false);

// 红色边框（加粗）
draw_set_alpha(0.8);
draw_set_color(c_red);
for (var i = 0; i < 3; i++) {
    draw_circle(x, y, radius - i, true);
}

// 中心十字
draw_set_alpha(0.9);
draw_line(x - 10, y, x + 10, y);
draw_line(x, y - 10, x, y + 10);

// 恢复
draw_set_alpha(1);
draw_set_color(c_white);