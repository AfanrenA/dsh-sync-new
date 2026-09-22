/// obj_telegraph Draw 事件

if (!instance_exists(follow_target)) {
    instance_destroy();
    exit;
}

// 闪烁效果（每4帧切换）
var _flash = (timer div 4) mod 2;
if (_flash == 1) {
    draw_set_alpha(0.7);
} else {
    draw_set_alpha(0.3);
}

var _end_x = x + lengthdir_x(range, dir);
var _end_y = y + lengthdir_y(range, dir);

// 红色方向线
draw_set_color(c_red);
draw_line_width(x, y, _end_x, _end_y, 4);

// 终点红圈（随范围变化大小）
var _circle_size = 10 + (range / 50);
draw_set_alpha(0.4);
draw_circle(_end_x, _end_y, _circle_size, false);
//show_debug_message("[预警线] range=" + string(range) + " | start=(" + string(x) + "," + string(y) + ") | end=(" + string(_end_x) + "," + string(_end_y) + ") | dist=" + string(point_distance(x, y, _end_x, _end_y)));
// 重置
draw_set_alpha(1);
draw_set_color(c_white);