/// @description 绘制预警圈（空心圆 + 外发光）

// ---- 外圈（细线） ----
draw_set_color(c_red);
draw_set_alpha(image_alpha * 0.4);
draw_circle(x, y, radius, false);

// ---- 内圈（更淡的填充） ----
draw_set_color(c_red);
draw_set_alpha(image_alpha * 0.1);
draw_circle(x, y, radius, false);

// ---- 从中心向外辐射的线条（蛤蟆怪风格） ----
draw_set_alpha(image_alpha * 0.15);
draw_set_color(c_red);

for (var i = 0; i < 8; i++) {
    var _angle = i * 45 + timer * 0.5;
    var _inner = radius * 0.2;
    var _outer = radius * (0.8 + 0.2 * sin(timer * 0.1 + i));
    
    draw_line(
        x + lengthdir_x(_inner, _angle),
        y + lengthdir_y(_inner, _angle),
        x + lengthdir_x(_outer, _angle),
        y + lengthdir_y(_outer, _angle)
    );
}

// ---- 中心红点 ----
draw_set_color(c_red);
draw_set_alpha(image_alpha * 0.6);
draw_circle(x, y, 4, false);

// 重置
draw_set_alpha(1);
draw_set_color(c_white);