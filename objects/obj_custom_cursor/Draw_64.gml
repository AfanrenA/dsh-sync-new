/// @description 自绘鼠标指针（GUI 层，跟 GM 鼠标坐标一致）
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

draw_set_alpha(1);
draw_set_color(c_white);

// 简单箭头：画两条线组成
// 顶点
var _p1x = _mx;       var _p1y = _my;
// 左下
var _p2x = _mx;       var _p2y = _my + 16;
// 中点（凹陷）
var _p3x = _mx + 5;   var _p3y = _my + 11;
// 右下
var _p4x = _mx + 10;  var _p4y = _my + 18;

// 白色填充（三角形 + 小三角）
draw_primitive_begin(pr_trianglelist);
draw_vertex(_p1x, _p1y);
draw_vertex(_p2x, _p2y);
draw_vertex(_p3x, _p3y);
draw_vertex(_p1x, _p1y);
draw_vertex(_p3x, _p3y);
draw_vertex(_p4x, _p4y);
draw_primitive_end();

// 黑色描边
draw_set_color(c_black);
draw_line(_p1x, _p1y, _p2x, _p2y);
draw_line(_p2x, _p2y, _p3x, _p3y);
draw_line(_p3x, _p3y, _p1x, _p1y);
draw_line(_p3x, _p3y, _p4x, _p4y);
draw_line(_p4x, _p4y, _p1x, _p1y);

draw_set_color(c_white);