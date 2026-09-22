/// @description 绘制血花
draw_set_color(color);
draw_set_alpha(image_alpha);

// ---- 主血花（大圆） ----
draw_circle(x, y, size, false);

// ---- 周围小血点（溅射效果） ----
for (var i = 0; i < 5; i++) {
    var _angle = i * 72 + angle;
    var _dist = size * (0.5 + 0.5 * (1 - image_alpha));
    var _px = x + lengthdir_x(_dist, _angle);
    var _py = y + lengthdir_y(_dist, _angle);
    var _ps = size * (0.2 + 0.3 * (1 - image_alpha));
    draw_circle(_px, _py, _ps, false);
}

draw_set_alpha(1);
draw_set_color(c_red);