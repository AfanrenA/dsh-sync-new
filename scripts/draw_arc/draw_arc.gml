// ======================================================================
// draw_arc.gml - 绘制圆弧
// ======================================================================

/// @description 绘制圆弧
/// @param {real} _x 中心X
/// @param {real} _y 中心Y
/// @param {real} _w 宽度
/// @param {real} _h 高度
/// @param {real} _start_angle 起始角度（度）
/// @param {real} _end_angle 结束角度（度）
/// @param {real} _segments 分段数
function draw_arc(_x, _y, _w, _h, _start_angle, _end_angle, _segments) {
    var _seg = max(_segments, 4);
    var _step = (_end_angle - _start_angle) / _seg;
    var _line_width = 3;
    
    for (var i = 0; i < _seg; i++) {
        var _a1 = _start_angle + i * _step;
        var _a2 = _start_angle + (i + 1) * _step;
        
        var _x1 = _x + lengthdir_x(_w, _a1);
        var _y1 = _y + lengthdir_y(_h, _a1);
        var _x2 = _x + lengthdir_x(_w, _a2);
        var _y2 = _y + lengthdir_y(_h, _a2);
        
        draw_line_width(_x1, _y1, _x2, _y2, _line_width);
    }
}