/// @function scr_draw_item_tooltip(item, mouse_x, mouse_y)
function scr_draw_item_tooltip(item, mouse_x, mouse_y) {
    if (!instance_exists(item)) return;
    
    var _data = item.entity_data;
    if (_data == undefined) return;
    
    var _is_attachment = variable_struct_exists(_data, "type") && _data.type == "附件";
    
    // ===== 品质颜色 =====
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
    
    // ===== 布局参数 =====
    var _padding = 10;
    var _line_height = 30;
    var _desc_line_h = 20;
    var _header_h = 40;
    var _desc_margin = 10;
    
    // ===== 收集属性行文本 =====
    var _line_texts = [];
    
    if (object_is_ancestor(item.object_index, obj_weapon_base)) {
        array_push(_line_texts, "类型: " + scr_get_type_name_cn(_data.type));
        array_push(_line_texts, "伤害: " + string(_data.base_damage));
        array_push(_line_texts, "攻速: " + string(_data.attack_speed));
        
    } else if (object_is_ancestor(item.object_index, obj_skill_base)) {
        if (_is_attachment) {
            array_push(_line_texts, "类型: 附件");
            var _proj = data_projectile_get(_data.projectile_id);
            if (_proj != undefined) {
                array_push(_line_texts, "爆炸伤害: " + string(_proj.explosion_damage));
                array_push(_line_texts, "爆炸半径: " + string(_proj.explosion_radius));
            }
            array_push(_line_texts, "弹药: " + string(_data.ammo_max) + " 发");
            array_push(_line_texts, "装填: " + string(_data.base_cooldown) + " 秒");
        } else {
            array_push(_line_texts, "类型: " + scr_get_type_name_cn(_data.slot));
            if (variable_struct_exists(_data, "damage_multiplier")) {
                array_push(_line_texts, "伤害倍率: " + string(_data.damage_multiplier));
            }
        }
    }
    
    // ===== 描述 =====
    var _desc = "（暂无介绍）";
    if (variable_struct_exists(_data, "description")) {
        _desc = _data.description;
    }
    
        // ===== 算最大文本宽度 =====
    draw_set_font(font_chinese);
    var _max_w = string_width(_data.display_name);
    
    for (var i = 0; i < array_length(_line_texts); i++) {
        var _w = string_width(_line_texts[i]);
        if (_w > _max_w) _max_w = _w;
    }
    
    // ★ 描述宽度参与计算
    var _desc_w_raw = string_width(_desc);
    if (_desc_w_raw > _max_w) _max_w = _desc_w_raw;
    
    // ===== 框宽度（自适应）=====
    var _tooltip_w = _max_w + _padding * 2;
    if (_tooltip_w < 200) _tooltip_w = 200;
    if (_tooltip_w > 500) _tooltip_w = 500;
    
    // ===== 描述高度 =====
    var _desc_w = _tooltip_w - _padding * 2;
    var _desc_h = string_height_ext(_desc, _desc_line_h, _desc_w);
    
    // ===== 框高度 =====
    var _stats_h = array_length(_line_texts) * _line_height;
    var _tooltip_h = _header_h + _stats_h + _desc_margin + _desc_h + _padding;
    
    // ===== 位置 =====
    var _tooltip_x = mouse_x + 20;
    var _tooltip_y = mouse_y + 20;
    
    // ===== 背景 =====
    draw_set_alpha(0.95);
    draw_set_color(c_black);
    draw_rectangle(_tooltip_x, _tooltip_y, _tooltip_x + _tooltip_w, _tooltip_y + _tooltip_h, false);
    
    // ===== 边框 =====
    draw_set_alpha(1);
    draw_set_color(_rarity_color);
    for (var t = 0; t < 4; t++) {
        draw_rectangle(_tooltip_x - t, _tooltip_y - t, _tooltip_x + _tooltip_w + t, _tooltip_y + _tooltip_h + t, true);
    }
    
    // ===== 名字 =====
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(_rarity_color);
    draw_text(_tooltip_x + _padding, _tooltip_y + _padding, _data.display_name);
    
    // ===== 属性行 =====
    draw_set_color(c_white);
    var _text_x = _tooltip_x + _padding;
    var _y_offset = _header_h;
    
    for (var i = 0; i < array_length(_line_texts); i++) {
        draw_text(_text_x, _tooltip_y + _y_offset + _line_height * i, _line_texts[i]);
    }
    
    // ===== 描述 =====
    var _desc_y = _tooltip_y + _header_h + _stats_h + _desc_margin;
    draw_set_color(c_gray);
    draw_text_ext(_text_x, _desc_y, _desc, _desc_line_h, _desc_w);
    
    // ===== 重置 =====
    draw_set_color(c_white);
    draw_set_alpha(1);
}