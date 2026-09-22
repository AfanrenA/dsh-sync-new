/// @description 混合两个颜色
/// @param {color} color1 起始颜色
/// @param {color} color2 目标颜色
/// @param {real} amount 混合量 0~1

function merge_color(color1, color2, amount) {
    var _r1 = color_get_red(color1);
    var _g1 = color_get_green(color1);
    var _b1 = color_get_blue(color1);
    
    var _r2 = color_get_red(color2);
    var _g2 = color_get_green(color2);
    var _b2 = color_get_blue(color2);
    
    var _r = _r1 + (_r2 - _r1) * amount;
    var _g = _g1 + (_g2 - _g1) * amount;
    var _b = _b1 + (_b2 - _b1) * amount;
    
    return make_color_rgb(_r, _g, _b);
}