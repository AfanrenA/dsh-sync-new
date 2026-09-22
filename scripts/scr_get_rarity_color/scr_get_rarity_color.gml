/// @description 根据品质ID获取UI颜色
/// @param {string} rarity_id 品质ID
/// @returns {color} 品质对应的颜色

// ===== 使用全局变量作为缓存 =====
if (!variable_global_exists("__rarity_color_cache")) {
    global.__rarity_color_cache = {};
}

function scr_get_rarity_color(rarity_id) {
    // 检查缓存
    if (global.__rarity_color_cache[$ rarity_id] != undefined) {
        return global.__rarity_color_cache[$ rarity_id];
    }
    
    var _data = data_rarity_get(rarity_id);
    if (_data == undefined || _data.ui_color == undefined) {
        return c_white;
    }
    
    var _color = c_white;
    var _ui_color = _data.ui_color;
    
    // 如果是字符串（十六进制颜色），转换
    if (is_string(_ui_color)) {
        _color = hex_to_color(_ui_color);
    } else {
        _color = _ui_color;
    }
    
    // 存入缓存
    global.__rarity_color_cache[$ rarity_id] = _color;
    return _color;
}

/// @description 将十六进制颜色字符串转换为 GameMaker 颜色值
/// @param {string} hex_str 如 "#FFD700" 或 "#FFF"
/// @returns {color} GameMaker 颜色值

function hex_to_color(hex_str) {
    // 去掉 #
    var _hex = string_replace(hex_str, "#", "");
    
    // 如果是 3 位缩写，扩展为 6 位
    if (string_length(_hex) == 3) {
        _hex = string_copy(_hex, 1, 1) + string_copy(_hex, 1, 1) +
               string_copy(_hex, 2, 1) + string_copy(_hex, 2, 1) +
               string_copy(_hex, 3, 1) + string_copy(_hex, 3, 1);
    }
    
    var _r = hex_to_dec(string_copy(_hex, 1, 2));
    var _g = hex_to_dec(string_copy(_hex, 3, 2));
    var _b = hex_to_dec(string_copy(_hex, 5, 2));
    
    return make_color_rgb(_r, _g, _b);
}

/// @description 将十六进制字符串转换为十进制数字
/// @param {string} hex 两位十六进制字符串
/// @returns {real} 十进制数字 0-255

function hex_to_dec(hex) {
    var _digits = "0123456789ABCDEF";
    var _result = 0;
    for (var i = 0; i < string_length(hex); i++) {
        var _char = string_upper(string_copy(hex, i + 1, 1));
        var _pos = string_pos(_char, _digits) - 1;
        _result = _result * 16 + _pos;
    }
    return _result;
}