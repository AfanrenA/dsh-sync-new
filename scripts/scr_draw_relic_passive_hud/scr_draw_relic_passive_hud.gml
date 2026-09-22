// scr_draw_relic_passive_hud.gml
// ============================================================
// 右上角被动遗物 HUD（雨中冒险风格图标池）
// ============================================================

/// @function scr_relic_icon_draw(sprite, cx, cy, box_size, inset, alpha)
/// @description ★ 统一的遗物图标绘制（HUD / 背包栏共用，保证缩放策略一致）
/// @param {real} cx, cy   图标中心
/// @param {real} box_size 格子尺寸
/// @param {real} inset    格子内边距（可用 = box_size - inset）
/// @note ★ 缩放策略（重要）：
///       遗物精灵尺寸不统一（64~128px），**不能无脑用整数倍**——
///       128px 的图在 40px 格子里 fit=0.25，若强行整数倍只能取 1 → 溢出格子。
///       所以策略分两档：
///         能放大（fit >= 1） → 取**整数倍**，保证像素完美
///         只能缩小（fit < 1） → 用**精确 fit**，让它刚好铺满格子
///       缩小虽会重采样，但缩放比一致、边缘对齐，视觉上远比"溢出/大小不一"好。
function scr_relic_icon_draw(sprite, cx, cy, box_size, inset = 8, alpha = 1) {
    if (sprite == -1 || sprite == noone) return false;
    if (!sprite_exists(sprite)) return false;

    var _sw = sprite_get_width(sprite);
    var _sh = sprite_get_height(sprite);
    if (_sw <= 0 || _sh <= 0) return false;

    var _avail = box_size - inset;
    var _fit = min(_avail / _sw, _avail / _sh);

    var _scale;
    if (_fit >= 1) {
        _scale = max(floor(_fit), 1);       // 可放大 → 整数倍（像素完美）
    } else {
        _scale = _fit;                      // 只能缩小 → 精确贴合格子
    }

    draw_sprite_ext(sprite, 0, cx, cy, _scale, _scale, 0, c_white, alpha);
    return true;
}

/// @function scr_draw_relic_passive_hud(_player)
/// @description 屏幕右上角显示当前持有的所有被动遗物图标 + 叠层数
///
/// 版式（从右上角往左下排布）：
///   ┌───┬───┬───┬───┐
///   │ ▣ │ ▣ │ ▣ │ ▣ │   ← 一行 4 个（与槽位数一致）
///   ├───┼───┼───┼───┤
///   │ ▣ │ ▣ │   │   │   ← 超出换行
///   └───┴───┴───┴───┘
/// 每个图标右下角显示叠层数（count > 1 才显示，×3 这种）
///
/// @param {id} _player 玩家实例
function scr_draw_relic_passive_hud(_player) {
    if (!instance_exists(_player)) return;
    if (!variable_instance_exists(_player, "relic_pool")) return;
    if (array_length(_player.relic_pool) <= 0) return;      // 没有就不占屏幕

    var _list = scr_relic_passive_get_display_list(_player);
    if (array_length(_list) <= 0) return;

    // ===== 布局参数 =====
    // ★ 图标格继续放大（56 → 68）：叠层数字要放得自然
    var _icon = 68;             // 图标格子尺寸
    var _gap = 10;
    var _per_row = 4;           // 每行几个（与初始槽位数一致）
    var _margin = 18;

    var _gui_w = display_get_gui_width();

    // ★ 从右上角开始，往左排、往下换行
    var _origin_x = _gui_w - _margin - _icon;
    var _origin_y = _margin + 34;      // 让开顶部（血条在左上，这里给标题留位）

    // ===== 标题 =====
    if (font_exists(font_chinese)) draw_set_font(font_chinese);
    draw_set_halign(fa_right);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(200, 200, 200));
    draw_text(_gui_w - _margin, _margin + 10, "被动遗物 " + string(array_length(_list)) + "/" + string(scr_relic_passive_slot_count(_player)));
    draw_set_halign(fa_left);

    // ===== 逐格绘制 =====
    for (var i = 0; i < array_length(_list); i++) {
        var _e = _list[i];

        var _col = i mod _per_row;
        var _row = i div _per_row;

        var _ix = _origin_x - _col * (_icon + _gap);
        var _iy = _origin_y + _row * (_icon + _gap);

        // ===== 背景：品质色（与背包栏一致），静态不闪 =====
        //   先黑底保证图标可读，再叠品质色
        draw_set_alpha(1);
        draw_set_color(make_color_rgb(20, 20, 20));
        draw_rectangle(_ix, _iy, _ix + _icon, _iy + _icon, false);

        draw_set_alpha(0.28);
        draw_set_color(_e.rarity_color);
        draw_rectangle(_ix, _iy, _ix + _icon, _iy + _icon, false);

        // 品质色描边
        draw_set_alpha(1);
        draw_set_color(_e.rarity_color);
        for (var t = 0; t < 2; t++) {
            draw_rectangle(_ix - t, _iy - t, _ix + _icon + t, _iy + _icon + t, true);
        }

        // 图标（统一缩放策略，见 scr_relic_icon_draw）
        var _drawn = scr_relic_icon_draw(_e.sprite, _ix + _icon / 2, _iy + _icon / 2, _icon, 6, 1);
        if (!_drawn) {
            // 精灵还没做 → 画色块占位，保证功能可测
            draw_set_alpha(0.85);
            draw_set_color(_e.color);
            draw_rectangle(_ix + 10, _iy + 10, _ix + _icon - 10, _iy + _icon - 10, false);
            draw_set_alpha(1);
        }

        // ===== 叠层数（>1 才显示）=====
        // ★ 格子放大后，数字用大字体 + 粗描边，自然融入不会显挤
        if (_e.count > 1) {
            if (font_exists(font_chinese)) draw_set_font(font_chinese);
            draw_set_halign(fa_right);
            draw_set_valign(fa_bottom);
            var _txt = "×" + string(_e.count);
            var _tx = _ix + _icon - 4;
            var _ty = _iy + _icon - 2;
            // 四向描边（比原来的两向更清晰）
            draw_set_color(c_black);
            draw_text(_tx + 1, _ty + 1, _txt);
            draw_text(_tx - 1, _ty - 1, _txt);
            draw_text(_tx + 1, _ty - 1, _txt);
            draw_text(_tx - 1, _ty + 1, _txt);
            draw_set_color(c_white);
            draw_text(_tx, _ty, _txt);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }

    // ===== 恢复默认 =====
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_alpha(1);
}

// ============================================================
// 背包界面：被动遗物栏（在背包右侧）
// ============================================================
/// @function scr_draw_passive_relic_panel(ui, player)
/// @description 背包界面里显示被动遗物格（已解锁 / 未解锁）
/// @param {id} ui obj_inventory_ui 实例
/// @param {id} player 玩家实例
function scr_draw_passive_relic_panel(ui, player) {
    if (!instance_exists(ui)) return;
    if (!instance_exists(player)) return;

    var _x = variable_instance_exists(ui, "ui_passive_x") ? ui.ui_passive_x : 1340;
    var _y = variable_instance_exists(ui, "ui_passive_y") ? ui.ui_passive_y : 150;

    var _total = variable_instance_exists(player, "passive_relic_slots") ? player.passive_relic_slots : 4;
    var _unlocked = scr_relic_passive_slot_count(player);

    // ===== 标题 =====
    if (font_exists(font_chinese)) draw_set_font(font_chinese);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_yellow);
    draw_text(_x + ui.slot_size / 2, _y - 30, "被动遗物");

    // ===== 格子（纵向排，与其他装备栏一致）=====
    var _list = scr_relic_passive_get_display_list(player);

    for (var i = 0; i < _total; i++) {
        var _sx = _x;
        var _sy = _y + i * (ui.slot_size + ui.slot_gap);

        var _is_unlocked = (i < _unlocked);
        var _entry = (i < array_length(_list)) ? _list[i] : undefined;

        var _is_selected = (i == ui.selected_passive);
        var _is_hover    = (i == ui.hover_passive);

        // ===== 未解锁：灰底 + 锁 =====
        if (!_is_unlocked) {
            draw_set_alpha(1);
            draw_set_color(make_color_rgb(20, 20, 20));
            draw_rectangle(_sx, _sy, _sx + ui.slot_size, _sy + ui.slot_size, false);
            draw_set_color(make_color_rgb(80, 80, 80));
            draw_rectangle(_sx, _sy, _sx + ui.slot_size, _sy + ui.slot_size, true);

            draw_set_color(make_color_rgb(100, 100, 100));
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(_sx + ui.slot_size / 2, _sy + ui.slot_size / 2, "锁");
            continue;
        }

        // ===== 已解锁：背景 = 品质色 =====
        // ★ 规则（用户要求）：
        //   选中   → 背景**呼吸闪烁**（alpha 0.25~0.60）
        //   未选中 → 背景**静态**品质色（alpha 0.25，稳定不闪）
        //   悬浮   → 略微提亮，给"可点击"反馈
        var _bg_col   = c_white;
        var _bg_alpha = 0.18;
        var _has_item = (_entry != undefined);

        if (_has_item) {
            _bg_col = _entry.rarity_color;
            _bg_alpha = 0.25;                        // 静态品质色
            if (_is_selected) {
                // 呼吸：用 sin 驱动，柔和不刺眼
                _bg_alpha = 0.25 + 0.35 * (0.5 + 0.5 * sin(current_time * 0.006));
            } else if (_is_hover) {
                _bg_alpha = 0.34;
            }
        } else {
            // 空格：暗底
            _bg_col   = make_color_rgb(40, 40, 40);
            _bg_alpha = 1;
        }

        // 先铺黑底（保证品质色有基底，文字/图标可读）
        draw_set_alpha(1);
        draw_set_color(make_color_rgb(22, 22, 22));
        draw_rectangle(_sx, _sy, _sx + ui.slot_size, _sy + ui.slot_size, false);

        // 叠品质色
        draw_set_alpha(_bg_alpha);
        draw_set_color(_bg_col);
        draw_rectangle(_sx, _sy, _sx + ui.slot_size, _sy + ui.slot_size, false);
        draw_set_alpha(1);

        // ===== 边框 =====
        if (_has_item) {
            var _bc = _entry.rarity_color;
            var _bt = 2;
            if (_is_selected) {
                _bc = c_aqua;                        // 选中：青色粗边（与装备栏一致）
                _bt = 4;
            } else if (_is_hover) {
                _bc = make_color_rgb(150, 200, 255);
                _bt = 2;
            }
            draw_set_color(_bc);
            for (var t = 0; t < _bt; t++) {
                draw_rectangle(_sx - t, _sy - t, _sx + ui.slot_size + t, _sy + ui.slot_size + t, true);
            }
        } else {
            draw_set_color(make_color_rgb(90, 90, 90));
            draw_rectangle(_sx, _sy, _sx + ui.slot_size, _sy + ui.slot_size, true);
        }

        // ===== 图标 + 叠层数 =====
        if (_has_item) {
            var _icon = ui.slot_size;
            var _drawn = scr_relic_icon_draw(_entry.sprite, _sx + _icon / 2, _sy + _icon / 2, _icon, 10, 1);
            if (!_drawn) {
                draw_set_alpha(0.85);
                draw_set_color(_entry.color);
                draw_rectangle(_sx + 14, _sy + 14, _sx + _icon - 14, _sy + _icon - 14, false);
                draw_set_alpha(1);
            }

            if (_entry.count > 1) {
                draw_set_halign(fa_right);
                draw_set_valign(fa_bottom);
                var _txt = "×" + string(_entry.count);
                var _tx = _sx + ui.slot_size - 5;
                var _ty = _sy + ui.slot_size - 3;
                draw_set_color(c_black);
                draw_text(_tx + 1, _ty + 1, _txt);
                draw_text(_tx - 1, _ty - 1, _txt);
                draw_set_color(c_white);
                draw_text(_tx, _ty, _txt);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
            }

            // ★ "不可叠加"不再画角标（用户要求去掉"单"字样）——
            //   信息改由悬浮说明窗里的「不可叠加」一行承担
        }
    }

    // ===== 槽位计数 =====
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(180, 180, 180));
    draw_text(_x + ui.slot_size / 2, _y + _total * (ui.slot_size + ui.slot_gap) + 10,
              string(_unlocked) + "/" + string(_total));

    // 恢复
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_alpha(1);
}

/// @function scr_draw_passive_relic_tooltip(ui, player)
/// @description ★ 被动遗物悬浮说明窗（在被动遗物栏右侧弹出）
/// @note 不用 scr_draw_item_tooltip —— 那个依赖"物品实例"（entity_data / sprite_index），
///       而被动遗物是**纯数据**没有实例。所以这里按同样的视觉风格单独画。
function scr_draw_passive_relic_tooltip(ui, player) {
    if (!instance_exists(ui)) return;
    if (!instance_exists(player)) return;
    if (!variable_instance_exists(ui, "hover_passive")) return;
    if (ui.hover_passive < 0) return;

    var _list = scr_relic_passive_get_display_list(player);
    if (ui.hover_passive >= array_length(_list)) return;

    var _e = _list[ui.hover_passive];

    // ===== 布局 =====
    var _padding = 12;
    var _line_h = 24;
    var _header_h = 34;
    var _desc_line_h = 20;

    // ===== 内容行 =====
    var _lines = [];
    array_push(_lines, "品质: " + scr_get_type_name_cn(_e.rarity));
    array_push(_lines, "层数: ×" + string(_e.count));
    array_push(_lines, (_e.stackable ? "可叠加" : "不可叠加"));

    // ===== 框宽：只看 名字 + 属性行（描述折行，不撑宽）=====
    if (font_exists(font_chinese)) draw_set_font(font_chinese);

    var _max_w = string_width(_e.name);
    for (var i = 0; i < array_length(_lines); i++) {
        var _w = string_width(_lines[i]);
        if (_w > _max_w) _max_w = _w;
    }

    var _tooltip_w = max(_max_w, 220) + _padding * 2;
    var _desc_w = _tooltip_w - _padding * 2;

    // 描述折行（复用 CJK 折行，中文才能正确断行）
    var _desc_lines = scr_text_wrap_cjk(_e.description, _desc_w, false);
    if (array_length(_desc_lines) <= 0) _desc_lines = [""];

    var _stats_h = array_length(_lines) * _line_h;
    var _desc_h  = array_length(_desc_lines) * _desc_line_h;
    var _tooltip_h = _header_h + _stats_h + 8 + _desc_h + _padding;

    // ===== 位置：被动栏右侧 =====
    var _px = ui.ui_passive_x + ui.slot_size + 12;
    var _py = ui.ui_passive_y + ui.hover_passive * (ui.slot_size + ui.slot_gap);

    // 边缘翻转（别跑出屏幕）
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    if (_px + _tooltip_w > _gui_w - 4) _px = ui.ui_passive_x - 12 - _tooltip_w;
    if (_py + _tooltip_h > _gui_h - 4) _py = _gui_h - _tooltip_h - 4;
    if (_py < 4) _py = 4;

    // ===== 背景 =====
    draw_set_alpha(0.95);
    draw_set_color(c_black);
    draw_rectangle(_px, _py, _px + _tooltip_w, _py + _tooltip_h, false);

    // ===== 边框（品质色，与其它 tooltip 一致）=====
    draw_set_alpha(1);
    draw_set_color(_e.rarity_color);
    for (var t = 0; t < 4; t++) {
        draw_rectangle(_px - t, _py - t, _px + _tooltip_w + t, _py + _tooltip_h + t, true);
    }

    // ===== 名字 =====
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(_e.rarity_color);
    draw_text(_px + _padding, _py + _padding, _e.name);

    // ===== 属性行 =====
    draw_set_color(c_white);
    var _tx = _px + _padding;
    for (var i = 0; i < array_length(_lines); i++) {
        draw_text(_tx, _py + _header_h + _line_h * i, _lines[i]);
    }

    // ===== 描述 =====
    var _desc_y = _py + _header_h + _stats_h + 8;
    draw_set_color(c_gray);
    for (var i = 0; i < array_length(_desc_lines); i++) {
        draw_text(_tx, _desc_y + i * _desc_line_h, _desc_lines[i]);
    }

    // ★ 已移除底部的 "[右键/Q] 拆卸即碎裂" 提示行（用户要求删掉）

    // 恢复
    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// ============================================================
// 被动遗物栏：交互（选中 / 悬浮 / 拆卸）
// ============================================================
/// @function scr_passive_relic_panel_update(ui, player)
/// @description 处理鼠标在被动遗物栏上的交互
///
/// 操作（用户定案）：
///   左键  → 选中该格（高亮 + 背景呼吸闪烁）；再点一次取消
///   悬浮  → 显示说明窗（tooltip）
///   右键 或 Q → 拆卸选中格 → **碎裂销毁**（不可恢复）
function scr_passive_relic_panel_update(ui, player) {
    if (!instance_exists(ui)) return;
    if (!instance_exists(player)) return;
    if (!player.inventory_ui_open) return;

    var _x = variable_instance_exists(ui, "ui_passive_x") ? ui.ui_passive_x : 1340;
    var _y = variable_instance_exists(ui, "ui_passive_y") ? ui.ui_passive_y : 150;

    var _total = variable_instance_exists(player, "passive_relic_slots") ? player.passive_relic_slots : 4;
    var _unlocked = scr_relic_passive_slot_count(player);
    var _list = scr_relic_passive_get_display_list(player);

    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    // ===== 1. 命中检测（悬浮 / 点击）=====
    ui.hover_passive = -1;
    var _clicked_index = -1;

    for (var i = 0; i < _total; i++) {
        var _sx = _x;
        var _sy = _y + i * (ui.slot_size + ui.slot_gap);

        if (_mx >= _sx && _mx <= _sx + ui.slot_size && _my >= _sy && _my <= _sy + ui.slot_size) {
            ui.hover_passive = i;
            if (mouse_check_button_pressed(mb_left)) _clicked_index = i;
            break;
        }
    }

    // ===== 2. 左键：选中 / 取消 =====
    if (_clicked_index >= 0) {
        if (_clicked_index < _unlocked) {
            if (ui.selected_passive == _clicked_index) {
                ui.selected_passive = -1;             // 再点一次 → 取消选中
            } else {
                ui.selected_passive = _clicked_index;
                show_debug_message("[被动遗物] 选中格 " + string(_clicked_index));
            }
        }
    }

    // ===== 3. 拆卸入口：右键 或 Q =====
    //   ★ 只作用于"选中的格"，避免误拆
    //   ★ 用户要求：**不直接拆**，先弹确认框警告
    var _want_dismantle = keyboard_check_pressed(ord("Q")) || mouse_check_button_pressed(mb_right);

    if (_want_dismantle && ui.selected_passive >= 0 && !ui.pd_active) {
        var _idx = ui.selected_passive;

        // 鼠标必须还在面板横向范围内（防止在别处按 Q 误触发）
        var _over_panel = (_mx >= _x && _mx <= _x + ui.slot_size);

        if (_over_panel && _idx < array_length(_list)) {
            var _entry = _list[_idx];
            scr_passive_relic_open_dismantle_dialog(ui, _entry);
        }
    }
}

/// @function scr_passive_relic_open_dismantle_dialog(ui, entry)
/// @description ★ 打开拆卸确认框（第 1 阶段：警告 + 是/否）
function scr_passive_relic_open_dismantle_dialog(ui, entry) {
    if (!instance_exists(ui)) return;

    ui.pd_active       = true;
    ui.pd_stage        = 0;                     // 先出警告
    ui.pd_relic_id     = entry.id;
    ui.pd_relic_name   = entry.name;
    ui.pd_relic_color  = entry.rarity_color;
    ui.pd_max_count    = entry.count;
    ui.pd_chosen_count = 1;
}

/// @function scr_passive_relic_dismantle(player, relic_id, display_name, rarity_color, amount)
/// @description ★ 拆卸被动遗物 → 碎裂销毁（不可恢复）
/// @param {real} amount 拆几个；0 或负数 = 全部
/// @note 用户定案："卸下即永久销毁"
function scr_passive_relic_dismantle(player, relic_id, display_name = "", rarity_color = c_white, amount = 0) {
    if (!instance_exists(player)) return false;
    if (!scr_relic_passive_has(player, relic_id)) return false;

    var _count_before = scr_relic_passive_get_count(player, relic_id);

    // ★ amount <= 0 → 全部拆除；否则按指定数量（夹在 1..现有层数）
    var _destroyed = (amount <= 0) ? _count_before : clamp(amount, 1, _count_before);
    var _remove_all = (_destroyed >= _count_before);

    // ★ 逐层调用 remove(remove_all=false) —— 因为 remove 一次只减 1 层。
    //   （数据层只有"减 1 层"和"整条删"两种语义，没有"减 N 层"，
    //     所以这里循环。层数一般个位数，性能无影响。）
    var _ok = false;
    if (_remove_all) {
        _ok = scr_relic_passive_remove(player, relic_id, true);
    } else {
        for (var i = 0; i < _destroyed; i++) {
            _ok = scr_relic_passive_remove(player, relic_id, false);
            if (!_ok) break;
        }
    }
    if (!_ok) return false;

    // ===== 碎裂反馈（碎片粒子，数量随销毁层数增加）=====
    if (variable_global_exists("psystem") && variable_global_exists("pt_enemy_hit")) {
        var _burst = 12 + _destroyed * 4;
        for (var i = 0; i < _burst; i++) {
            part_particles_create(
                global.psystem,
                player.x + random_range(-14, 14),
                player.y + random_range(-14, 14),
                global.pt_enemy_hit, 1
            );
        }
    }

    if (_remove_all) {
        scr_show_hint(player, display_name + " 已全部碎裂");
    } else {
        var _left = scr_relic_passive_get_count(player, relic_id);
        scr_show_hint(player, display_name + " 碎裂 ×" + string(_destroyed) + "（剩余 ×" + string(_left) + "）");
    }

    show_debug_message("[被动遗物] 碎裂: " + string(relic_id) +
                       " | 销毁 ×" + string(_destroyed) + " / 原有 ×" + string(_count_before) +
                       " | 剩余 ×" + string(scr_relic_passive_get_count(player, relic_id)));
    return true;
}

// ============================================================
// 被动遗物：拆卸确认框（绘制）
// ============================================================
/// @function scr_draw_passive_dismantle_dialog(ui, player)
/// @description 两阶段：
///   阶段0 = 警告"拆卸后该遗物将格式化，是否拆卸？" + 是/否
///   阶段1 = 数量选择（单个 / 指定数量 / 全部）—— 仅当 count > 1
function scr_draw_passive_dismantle_dialog(ui, player) {
    if (!instance_exists(ui)) return;
    if (!variable_instance_exists(ui, "pd_active") || !ui.pd_active) return;

    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();

    // ===== 全屏遮罩 =====
    draw_set_alpha(0.55);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);

    // ===== 框体 =====
    //   阶段0：只有警告 + 是/否 → 矮一点
    //   阶段1：多一行数量选择 + 模式按钮 + 是/否 → 高一点
    var _cw = 480;
    var _ch = (ui.pd_stage == 0) ? 290 : 380;
    var _cx = _gw / 2 - _cw / 2;
    var _cy = _gh / 2 - _ch / 2;

    // 背景
    draw_set_color(make_color_rgb(38, 30, 30));
    draw_rectangle(_cx, _cy, _cx + _cw, _cy + _ch, false);

    // 边框（危险色：红）
    draw_set_color(make_color_rgb(200, 70, 70));
    for (var t = 0; t < 3; t++) {
        draw_rectangle(_cx - t, _cy - t, _cx + _cw + t, _cy + _ch + t, true);
    }

    if (font_exists(font_chinese)) draw_set_font(font_chinese);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    var _cxm = _cx + _cw / 2;

    // ===== 标题：！ + 警告（★ 用户要求把 ⚠ 换成 ！）=====
    draw_set_color(make_color_rgb(255, 90, 90));
    draw_text_transformed(_cxm, _cy + 36, "！ 警告", 1.3, 1.3, 0);

    // ===== 遗物名（品质色）=====
    draw_set_color(ui.pd_relic_color);
    draw_text(_cxm, _cy + 74, ui.pd_relic_name);

    // ============================================================
    // 阶段 1：数量选择（选模式 → 再点「是」确认）
    // ============================================================
    if (ui.pd_stage == 1) {
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);

        draw_set_color(make_color_rgb(230, 230, 230));
        draw_text(_cxm, _cy + 104, "当前持有 ×" + string(ui.pd_max_count) + "，请选择拆卸数量");

        // ---- 三个模式按钮 ----
        var _bw = 128, _bh = 52, _gap_x = 14;
        var _total_w = _bw * 3 + _gap_x * 2;
        var _bx0 = _cxm - _total_w / 2;
        var _by = _cy + 132;

        var _labels = ["单个 ×1", "指定 ×" + string(ui.pd_chosen_count), "全部 ×" + string(ui.pd_max_count)];
        var _cols   = [make_color_rgb(50, 55, 80), make_color_rgb(50, 70, 55), make_color_rgb(90, 48, 48)];

        for (var i = 0; i < 3; i++) {
            var _bx = _bx0 + i * (_bw + _gap_x);
            var _hover = (_mx >= _bx && _mx <= _bx + _bw && _my >= _by && _my <= _by + _bh);
            var _picked = (ui.pd_mode == i);

            // ★ 选中态：亮边 + 提亮底色（让玩家看清"当前选的是哪个模式"）
            var _c = _cols[i];
            if (_picked) _c = merge_color(_c, c_white, 0.30);
            if (_hover)  _c = merge_color(_c, c_white, 0.20);

            draw_set_color(_c);
            draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);

            draw_set_color(_picked ? c_yellow : c_white);
            for (var t = 0; t < (_picked ? 3 : 1); t++) {
                draw_rectangle(_bx - t, _by - t, _bx + _bw + t, _by + _bh + t, true);
            }

            draw_set_color(c_white);
            draw_text(_bx + _bw / 2, _by + _bh / 2, _labels[i]);
        }

        // ---- 操作提示（用户指定文案）----
        draw_set_color(make_color_rgb(190, 190, 190));
        draw_text(_cxm, _cy + 208, "滚轮选择数量");
        draw_set_color(make_color_rgb(150, 150, 150));
        draw_text(_cxm, _cy + 234, "选中模式后点「是」执行");

        // ---- 是 / 否（★ 必须再点一次才执行）----
        var _cbw = 130, _cbh = 46;
        var _cby = _cy + _ch - 70;
        var _yes_x = _cxm - _cbw - 12;
        var _no_x  = _cxm + 12;

        // 是（红）
        var _yes_hover = (_mx >= _yes_x && _mx <= _yes_x + _cbw && _my >= _cby && _my <= _cby + _cbh);
        draw_set_color(_yes_hover ? make_color_rgb(200, 70, 70) : make_color_rgb(140, 45, 45));
        draw_rectangle(_yes_x, _cby, _yes_x + _cbw, _cby + _cbh, false);
        draw_set_color(c_white);
        draw_rectangle(_yes_x, _cby, _yes_x + _cbw, _cby + _cbh, true);
        draw_text(_yes_x + _cbw / 2, _cby + _cbh / 2, "是");

        // 否（灰）
        var _no_hover = (_mx >= _no_x && _mx <= _no_x + _cbw && _my >= _cby && _my <= _cby + _cbh);
        draw_set_color(_no_hover ? make_color_rgb(90, 90, 110) : make_color_rgb(60, 60, 70));
        draw_rectangle(_no_x, _cby, _no_x + _cbw, _cby + _cbh, false);
        draw_set_color(c_white);
        draw_rectangle(_no_x, _cby, _no_x + _cbw, _cby + _cbh, true);
        draw_text(_no_x + _cbw / 2, _cby + _cbh / 2, "否");
    }

    // ============================================================
    // 阶段 0：警告 + 是/否
    // ============================================================
    else {
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);

        draw_set_color(make_color_rgb(255, 200, 120));
        draw_text(_cxm, _cy + 118, "拆卸后该遗物将格式化");

        draw_set_color(make_color_rgb(230, 230, 230));
        draw_text(_cxm, _cy + 152, "是否拆卸？");

        // ---- 是 / 否 按钮 ----
        var _bw = 130, _bh = 46;
        var _by = _cy + _ch - 70;
        var _yes_x = _cxm - _bw - 12;
        var _no_x  = _cxm + 12;

        // 是（红）
        var _yes_hover = (_mx >= _yes_x && _mx <= _yes_x + _bw && _my >= _by && _my <= _by + _bh);
        draw_set_color(_yes_hover ? make_color_rgb(200, 70, 70) : make_color_rgb(140, 45, 45));
        draw_rectangle(_yes_x, _by, _yes_x + _bw, _by + _bh, false);
        draw_set_color(c_white);
        draw_rectangle(_yes_x, _by, _yes_x + _bw, _by + _bh, true);
        draw_text(_yes_x + _bw / 2, _by + _bh / 2, "是");

        // 否（灰）
        var _no_hover = (_mx >= _no_x && _mx <= _no_x + _bw && _my >= _by && _my <= _by + _bh);
        draw_set_color(_no_hover ? make_color_rgb(90, 90, 110) : make_color_rgb(60, 60, 70));
        draw_rectangle(_no_x, _by, _no_x + _bw, _by + _bh, false);
        draw_set_color(c_white);
        draw_rectangle(_no_x, _by, _no_x + _bw, _by + _bh, true);
        draw_text(_no_x + _bw / 2, _by + _bh / 2, "否");

        // ★ 键盘提示：放在按钮和正文之间，留足间距（原来贴太近会重叠）
        draw_set_color(make_color_rgb(170, 170, 170));
        draw_text(_cxm, _by - 34, "回车 = 是    ESC = 否");
    }

    // 恢复
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_alpha(1);
}

// ============================================================
// 被动遗物：拆卸确认框（交互）
// ============================================================
/// @function scr_passive_dismantle_dialog_update(ui, player)
/// @description 确认框交互；返回 true 表示"框开着，屏蔽其它输入"
/// @returns {bool}
function scr_passive_dismantle_dialog_update(ui, player) {
    if (!instance_exists(ui)) return false;
    if (!variable_instance_exists(ui, "pd_active") || !ui.pd_active) return false;
    if (!instance_exists(player)) return false;

    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _cw = 480;
    var _ch = (ui.pd_stage == 0) ? 290 : 380;
    var _cx = _gw / 2 - _cw / 2;
    var _cy = _gh / 2 - _ch / 2;
    var _cxm = _cx + _cw / 2;

    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    // ============================================================
    // 阶段 1：数量选择（选模式 → 再点「是」确认）
    // ============================================================
    if (ui.pd_stage == 1) {
        // ---- ★ 鼠标滚轮调整「指定数量」----
        // ★ 用户要求：**只有选中「指定」模式时，滚轮才生效**。
        //   选在「单个」/「全部」上时滚轮不动数字（那两个模式的数量是固定的）。
        // ★ 滚轮也不切模式（第四轮已修）。
        if (ui.pd_mode == 1) {
            var _wheel = mouse_wheel_up() - mouse_wheel_down();
            if (_wheel != 0) {
                ui.pd_chosen_count += _wheel;
                if (ui.pd_chosen_count > ui.pd_max_count) ui.pd_chosen_count = 1;   // 超上限 → 回 1
                if (ui.pd_chosen_count < 1) ui.pd_chosen_count = ui.pd_max_count;   // 低于 1 → 到上限
            }

            // ---- 键盘 ← → 同样只在「指定」下生效 ----
            if (keyboard_check_pressed(vk_left)) {
                ui.pd_chosen_count -= 1;
                if (ui.pd_chosen_count < 1) ui.pd_chosen_count = ui.pd_max_count;
            }
            if (keyboard_check_pressed(vk_right)) {
                ui.pd_chosen_count += 1;
                if (ui.pd_chosen_count > ui.pd_max_count) ui.pd_chosen_count = 1;
            }
            ui.pd_chosen_count = clamp(ui.pd_chosen_count, 1, ui.pd_max_count);
        }

        // ---- 按钮几何 ----
        var _bw = 128, _bh = 52, _gap_x = 14;
        var _total_w = _bw * 3 + _gap_x * 2;
        var _bx0 = _cxm - _total_w / 2;
        var _by = _cy + 132;

        var _cbw = 130, _cbh = 46;
        var _cby = _cy + _ch - 70;
        var _yes_x = _cxm - _cbw - 12;
        var _no_x  = _cxm + 12;

        var _do_yes = false;
        var _do_no  = false;

        if (mouse_check_button_pressed(mb_left)) {
            // 模式按钮：只切换 pd_mode，**不执行**（用户要求：还要再点「是」）
            for (var i = 0; i < 3; i++) {
                var _bx = _bx0 + i * (_bw + _gap_x);
                if (_mx >= _bx && _mx <= _bx + _bw && _my >= _by && _my <= _by + _bh) {
                    ui.pd_mode = i;
                }
            }

            if (_mx >= _yes_x && _mx <= _yes_x + _cbw && _my >= _cby && _my <= _cby + _cbh) _do_yes = true;
            if (_mx >= _no_x  && _mx <= _no_x  + _cbw && _my >= _cby && _my <= _cby + _cbh) _do_no  = true;
        }

        if (keyboard_check_pressed(vk_enter)) _do_yes = true;

        // ---- 取消：ESC / 点「否」都**直接关掉整个框**（用户要求）----
        // ★ 原来点「否」是退回阶段0（警告），用户觉得多余 —— 那是"又跳回第一个界面"。
        if (keyboard_check_pressed(vk_escape)) {
            ui.pd_active = false;
            return true;
        }
        if (_do_no) {
            ui.pd_active = false;       // 直接关闭，不退回警告
            return true;
        }

        // ---- ★ 确认执行：按当前选中的模式决定拆几个 ----
        if (_do_yes) {
            var _amt;
            if (ui.pd_mode == 0) {
                _amt = 1;                                   // 单个
            } else if (ui.pd_mode == 1) {
                _amt = ui.pd_chosen_count;                  // 指定
            } else {
                _amt = ui.pd_max_count;                     // 全部
            }

            scr_passive_relic_dismantle(player, ui.pd_relic_id, ui.pd_relic_name, ui.pd_relic_color, _amt);
            ui.pd_active = false;
            ui.selected_passive = -1;
            return true;
        }
    }

    // ============================================================
    // 阶段 0：警告 + 是/否
    // ============================================================
    else {
        var _bw = 130, _bh = 46;
        var _by = _cy + _ch - 70;
        var _yes_x = _cxm - _bw - 12;
        var _no_x  = _cxm + 12;

        var _do_yes = false;
        var _do_no  = false;

        if (mouse_check_button_pressed(mb_left)) {
            if (_mx >= _yes_x && _mx <= _yes_x + _bw && _my >= _by && _my <= _by + _bh) _do_yes = true;
            if (_mx >= _no_x  && _mx <= _no_x  + _bw && _my >= _by && _my <= _by + _bh) _do_no  = true;
        }

        if (keyboard_check_pressed(vk_enter)) _do_yes = true;
        if (keyboard_check_pressed(vk_escape)) _do_no = true;

        if (_do_no) {
            ui.pd_active = false;
            return true;
        }

        if (_do_yes) {
            // ★ 数量 > 1 → 进入数量选择阶段（默认模式 = 单个）
            if (ui.pd_max_count > 1) {
                ui.pd_stage = 1;
                ui.pd_mode = 1;                 // 默认「指定」（数量用滚轮改）
                ui.pd_chosen_count = 1;
            } else {
                // 只有 1 个 → 直接拆
                scr_passive_relic_dismantle(player, ui.pd_relic_id, ui.pd_relic_name, ui.pd_relic_color, 0);
                ui.pd_active = false;
                ui.selected_passive = -1;
            }
            return true;
        }
    }

    return true;    // 框开着 → 屏蔽其它输入
}
