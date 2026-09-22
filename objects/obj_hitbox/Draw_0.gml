// 画 Hitbox 实际生效范围（圆形）
draw_set_alpha(0.3);
draw_set_color(c_yellow);
draw_circle(x, y, hit_radius, false);  // 黄色半透明填充

draw_set_alpha(0.8);
draw_set_color(c_yellow);
draw_circle(x, y, hit_radius, true);   // 黄色边框

draw_set_alpha(1);