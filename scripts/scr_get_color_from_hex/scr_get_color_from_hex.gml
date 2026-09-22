// scr_get_color_from_hex.gml
/// @function scr_get_color_from_hex(hex_string)
/// @param {string} hex_string 十六进制颜色，如 "#FF6644" 或 "FF6644"
/// @return {color} GameMaker 颜色值

function scr_get_color_from_hex(hex_string) {
    if (hex_string == undefined || hex_string == "") return c_white;
    
    // 去掉 # 号
    var _str = string_replace(hex_string, "#", "");
    
    // 提取 RGB
    var _r = hex_to_dec(string_copy(_str, 1, 2));
    var _g = hex_to_dec(string_copy(_str, 3, 2));
    var _b = hex_to_dec(string_copy(_str, 5, 2));
    
    return make_color_rgb(_r, _g, _b);
}