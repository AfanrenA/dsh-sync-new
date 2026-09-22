/// @function scr_draw_item_in_slot(item, slot_x, slot_y, slot_size, is_selected)
/// @description 在格子内居中绘制物品（用精灵静态尺寸）
function scr_draw_item_in_slot(item, slot_x, slot_y, slot_size, is_selected = false) {
    if (!instance_exists(item)) return;
    
    // ===== 获取品质颜色 =====
    var _rarity = item.rarity;
    if (_rarity == undefined || _rarity == "") _rarity = "common";
    
    var _rarity_color = c_white;
    var _rarity_data = data_rarity_get(_rarity);
    if (_rarity_data != undefined) {
        if (variable_struct_exists(_rarity_data, "ui_color")) {
            var _color_str = _rarity_data.ui_color;
            if (is_string(_color_str)) {
                _rarity_color = scr_get_color_from_hex(_color_str);
            } else {
                _rarity_color = _color_str;
            }
        }
    }
    
    // ===== 用精灵的静态尺寸 =====
    var _sw = sprite_get_width(item.sprite_index);
    var _sh = sprite_get_height(item.sprite_index);
    var _sx_offset = sprite_get_xoffset(item.sprite_index);
    var _sy_offset = sprite_get_yoffset(item.sprite_index);
    
    var _offset_x = (_sw / 2) - _sx_offset;
    var _offset_y = (_sh / 2) - _sy_offset;
    
    var _scale = 1;
    var _max_size = slot_size * 0.8;
    if (_sw > _max_size) _scale = _max_size / _sw;
    if (_sh * _scale > _max_size) _scale = _max_size / _sh;
    
    // ===== ★ 绘制"整个格子"的品质光晕 =====
    // 选中 → 呼吸闪烁；未选中 → 固定低 alpha
    var _glow_alpha;
    if (is_selected) {
        _glow_alpha = 0.25 + 0.15 * sin(current_time / 200);   // 呼吸
    } else {
        _glow_alpha = 0.15;   // 固定
    }
    
    draw_set_alpha(_glow_alpha);
    draw_set_color(_rarity_color);
    draw_rectangle(
        slot_x + 2,
        slot_y + 2,
        slot_x + slot_size - 2,
        slot_y + slot_size - 2,
        false
    );
    draw_set_alpha(1);
    
    // ===== 绘制武器精灵 =====
    draw_sprite_ext(
        item.sprite_index, 0,
        slot_x + slot_size / 2 - _offset_x * _scale,
        slot_y + slot_size / 2 - _offset_y * _scale,
        _scale, _scale,
        0,
        c_white, 1
    );
}