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
    } else if (scr_is_item_type(item.object_index, obj_relic_base)) {
        // ===== ★ 本命遗物分支（之前完全缺失 → 预览框只有名字和描述，显得"没适配"）=====
        array_push(_line_texts, "类型: 本命遗物");
        if (variable_struct_exists(_data, "cooldown")) {
            array_push(_line_texts, "冷却: " + string(_data.cooldown) + " 秒");
        }
        if (variable_struct_exists(_data, "duration")) {
            array_push(_line_texts, "持续: " + string(_data.duration) + " 秒");
        }
        // 关键效果摘要（数据驱动，从 effect 里读，不写死具体遗物）
        if (variable_struct_exists(_data, "effect")) {
            var _eff = _data.effect;
            if (variable_struct_exists(_eff, "damage_mult") && _eff.damage_mult != 1.0) {
                array_push(_line_texts, "伤害: ×" + string(_eff.damage_mult));
            }
            if (variable_struct_exists(_eff, "shield_mult") && _eff.shield_mult != 1.0) {
                array_push(_line_texts, "护盾: ×" + string(_eff.shield_mult));
            }
            if (variable_struct_exists(_eff, "move_line_mult") && _eff.move_line_mult != 1.0) {
                array_push(_line_texts, "直线移速: ×" + string(_eff.move_line_mult));
            }
            if (variable_struct_exists(_eff, "move_diag_mult") && _eff.move_diag_mult != 1.0) {
                array_push(_line_texts, "斜向移速: ×" + string(_eff.move_diag_mult));
            }
            if (variable_struct_exists(_eff, "agility_cd_mult") && _eff.agility_cd_mult != 1.0) {
                array_push(_line_texts, "身法冷却: ×" + string(_eff.agility_cd_mult));
            }
        }
        // 触发键提示
        array_push(_line_texts, "按键: R 主动施放");
    } else if (scr_is_item_type(item.object_index, obj_agility_base)) {
        // ===== ★ 身法分支（之前也缺失）=====
        array_push(_line_texts, "类型: 身法");
        if (variable_struct_exists(_data, "distance")) {
            array_push(_line_texts, "距离: " + string(_data.distance));
        }
        // ★ 注意：data_agility.cooldown 单位是"帧"（见数据表表头注释，
        //   scr_agility_dash 直接把它当帧数用），不是秒 → 这里换算成秒显示
        if (variable_struct_exists(_data, "cooldown")) {
            array_push(_line_texts, "冷却: " + string(_data.cooldown / 60) + " 秒");
        }
    }
    
    // ===== 描述 =====
    var _desc = "（暂无介绍）";
    if (variable_struct_exists(_data, "description")) {
        _desc = _data.description;
    }
    
        // ===== 算最大文本宽度（只算 名字 + 属性行）=====
    draw_set_font(font_chinese);
    var _max_w = string_width(_data.display_name);
    
    for (var i = 0; i < array_length(_line_texts); i++) {
        var _w = string_width(_line_texts[i]);
        if (_w > _max_w) _max_w = _w;
    }
    
    // ===== 框宽度（自适应）=====
    // ★ 定案：框宽 **只看 名字 + 属性行**，描述一律在框内折行，绝不参与撑宽。
    //   理由：描述是"段落"不是"标签"，让它撑宽会导致同样是描述的一句话，
    //   短描述框窄、长描述框宽到 500，视觉上完全不稳定（正是用户反馈的"没适应"）。
    //
    //   宽度公式：max(名字, 最长属性行, 描述折行下限) + 内边距
    //   - 下限 _desc_min_w：给描述一个起码的折行宽度，避免短物品框太窄、描述挤成竖排
    var _desc_min_w = 240;          // 描述折行的最小可用宽度（不含内边距）
    var _content_w = max(_max_w, _desc_min_w);

    var _tooltip_w = _content_w + _padding * 2;
    if (_tooltip_w > 500) _tooltip_w = 500;      // 上限保护（极长名字/属性行才触发）
    
    // ===== 描述折行（★ 中文必须逐字折行）=====
    // ★ GameMaker 的 string_height_ext / draw_text_ext 只按**空格**断词，
    //   中文描述没有空格 → 一个字都不换 → 直接溢出框（用户反馈的现象）。
    //   所以这里用 scr_text_wrap_cjk 自己折行，高度也按"实际行数"算。
    var _desc_w = _tooltip_w - _padding * 2;     // 描述可用宽度（框宽 - 左右内边距）
    var _desc_lines = scr_text_wrap_cjk(_desc, _desc_w, false);
    var _desc_line_count = max(array_length(_desc_lines), 1);
    var _desc_h = _desc_line_count * _desc_line_h;
    
    // ===== 框高度 =====
    var _stats_h = array_length(_line_texts) * _line_height;
    var _tooltip_h = _header_h + _stats_h + _desc_margin + _desc_h + _padding;
    
    // ===== 位置 =====
    // ★ 修正：调用方传进来的 mouse_x/mouse_y 已经是 GUI 坐标，直接用，
    //   绝不混用内置 mouse_x（那是房间坐标，见 DEVLOG 关键坑）。
    var _tooltip_x = mouse_x + 20;
    var _tooltip_y = mouse_y + 20;
    
    // ★ 边缘翻转：靠右/靠下放不下时，翻到鼠标另一侧，避免被屏幕裁掉
    //   （被裁掉时用户会误以为"框没适配/宽度不对"）
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    
    if (_tooltip_x + _tooltip_w > _gui_w - 4) {
        _tooltip_x = mouse_x - 20 - _tooltip_w;
    }
    if (_tooltip_y + _tooltip_h > _gui_h - 4) {
        _tooltip_y = _gui_h - _tooltip_h - 4;
    }
    // 终极兜底：别跑到左上角外面
    if (_tooltip_x < 4) _tooltip_x = 4;
    if (_tooltip_y < 4) _tooltip_y = 4;
    
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
    
    // ===== 描述（★ 按 scr_text_wrap_cjk 折好的行逐行画，不再用 draw_text_ext）=====
    var _desc_y = _tooltip_y + _header_h + _stats_h + _desc_margin;
    draw_set_color(c_gray);
    for (var i = 0; i < array_length(_desc_lines); i++) {
        draw_text(_text_x, _desc_y + i * _desc_line_h, _desc_lines[i]);
    }
    
    // ===== 重置 =====
    draw_set_color(c_white);
    draw_set_alpha(1);
}