life -= 1;
current_radius += grow_speed;
alpha = life / 15;

draw_set_alpha(alpha);
draw_set_colour(color);

// 外圈
draw_circle(x, y, current_radius, false);

// 内圈
draw_set_alpha(alpha * 0.4);
draw_circle(x, y, current_radius * 0.6, false);

// 中心亮点
draw_set_alpha(alpha * 0.8);
draw_circle(x, y, 4, false);

draw_set_alpha(1);
draw_set_colour(c_white);

if (life <= 0) instance_destroy();