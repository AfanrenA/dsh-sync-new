// ============================================================
// 右下角：本命遗物 HUD
// ============================================================
/// @function scr_draw_relic_hud(_player)
/// @description 屏幕右下角显示当前装备的本命遗物：图标 + 状态 + 进度条
///
/// 设计目标（用户要求）：「一眼看出装了什么遗物 / 用了之后还剩多久」
/// 三种状态用 **颜色 + 边框 + 文字 + 进度条方向** 四重编码（不只靠颜色，色盲可辨）：
///   冷却中 → 图标暗 + 灰边框 + 进度条【从左往右长】+ "冷却 32 秒"
///   已就绪 → 图标亮 + 品质色呼吸边框      + "R 就绪"
///   生效中 → 图标高亮脉冲 + 外圈光晕      + 进度条【从右往左缩】+ "剩余 8 秒"
/// ★ 进度条方向相反是关键：一眼区分"我在等冷却"还是"我在生效中"
///
/// @param {id} _player 玩家实例
function scr_draw_relic_hud(_player) {
    if (!instance_exists(_player)) return;

    // ===== 0. 没装遗物 → 整个 HUD 不显示 =====
    if (!variable_instance_exists(_player, "relic_slot")) return;
    if (!instance_exists(_player.relic_slot)) return;

    var _relic = _player.relic_slot;
    var _data  = _relic.entity_data;
    if (_data == undefined) return;

    // ===== 1. 读状态 =====
    var _cd_now = variable_instance_exists(_relic, "cooldown_timer") ? _relic.cooldown_timer : 0;
    var _is_active = variable_instance_exists(_relic, "is_active") && _relic.is_active;
    var _active_timer = variable_instance_exists(_relic, "active_timer") ? _relic.active_timer : 0;

    // 冷却总时长（含品质倍率），用于算进度
    var _qi = variable_instance_exists(_relic, "quality_index") ? _relic.quality_index : 0;
    var _cd_mult = data_relic_get_quality_mult(_relic.relic_id, _qi, "quality_cooldown_mult");
    var _cd_max = (_data.cooldown != undefined ? _data.cooldown : 60) * 60 * _cd_mult;
    if (_cd_max <= 0) _cd_max = 1;

    // 生效总时长（含品质倍率）
    var _dur_mult = data_relic_get_quality_mult(_relic.relic_id, _qi, "quality_duration_mult");
    var _dur_max = (_data.duration != undefined ? _data.duration : 10) * 60 * _dur_mult;
    if (_dur_max <= 0) _dur_max = 1;

    // ===== 2. 配色 =====
    var _rarity = variable_instance_exists(_relic, "rarity") ? _relic.rarity : "common";
    var _quality_col = scr_get_rarity_color(_rarity);

    // 遗物主题色（数据表 active_color），拿不到就退回品质色
    var _theme_col = _quality_col;
    if (variable_struct_exists(_data, "active_color")) {
        _theme_col = scr_get_color_from_hex(_data.active_color);
    }

    // ===== 3. 布局（右下角贴边）=====
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();

    var _box_w = 110;
    var _box_h = 122;       // ★ 收紧：只留 图标64 + 进度条 + 状态文字（遗物名已按用户要求移除）
    var _margin = 18;

    var _x = _gui_w - _box_w - _margin;
    var _y = _gui_h - _box_h - _margin;

    // 呼吸/脉冲相位（全局时间驱动，无需额外变量）
    var _pulse = 0.5 + 0.5 * sin(current_time * 0.005);   // 0~1

    // ===== 4. 外发光（仅"生效中"）=====
    if (_is_active) {
        var _glow_alpha = 0.22 + 0.18 * _pulse;
        draw_set_alpha(_glow_alpha);
        draw_set_color(_theme_col);
        for (var g = 1; g <= 6; g++) {
            draw_rectangle(_x - g, _y - g, _x + _box_w + g, _y + _box_h + g, true);
        }
        draw_set_alpha(1);
    }

    // ===== 5. 背景（★ 品质色底 + 激活期间呼吸闪烁）=====
    // ★ 用户要求：背景 = 当前遗物品质色；R 激活期间闪烁，平时不闪。
    //
    //   做法：先铺一层半透明黑（保证文字可读），再叠品质色。
    //   叠色的 alpha 分两档：
    //     平时     → 固定 0.30（稳定不闪，避免和"就绪呼吸边框"打架）
    //     激活期间 → 0.30 ~ 0.62 之间呼吸（sin 驱动，柔和渐变，非硬闪）
    //   ⚠️ 注意：这里**不用** _theme_col（那是遗物主题色），用户要的是**品质色**。
    var _bg_quality_alpha = 0.30;
    if (_is_active) {
        _bg_quality_alpha = 0.30 + 0.32 * _pulse;      // 呼吸式明暗渐变
    }

    // 底色（黑）
    draw_set_alpha(0.70);
    draw_set_color(c_black);
    draw_rectangle(_x, _y, _x + _box_w, _y + _box_h, false);

    // 品质色叠加
    draw_set_alpha(_bg_quality_alpha);
    draw_set_color(_quality_col);
    draw_rectangle(_x, _y, _x + _box_w, _y + _box_h, false);
    draw_set_alpha(1);

    // ===== 6. 边框（按状态变色）=====
    var _border_col = c_gray;
    var _border_thick = 1;
    if (_is_active) {
        _border_col = _theme_col;
        _border_thick = 3 + round(_pulse * 2);      // 脉冲
    } else if (_cd_now <= 0) {
        _border_col = _theme_col;
        _border_thick = 2 + round(_pulse * 2);      // 呼吸
    } else {
        _border_col = make_color_rgb(90, 90, 90);   // 冷却中：灰
        _border_thick = 1;
    }

    draw_set_color(_border_col);
    for (var t = 0; t < _border_thick; t++) {
        draw_rectangle(_x - t, _y - t, _x + _box_w + t, _y + _box_h + t, true);
    }

    // ===== 7. 图标 =====
    var _icon_size = 64;
    var _icon_x = _x + (_box_w - _icon_size) / 2;
    var _icon_y = _y + 8;

    // ★ 图标垫底：用**圆形柔光**，不用矩形！
    //   原因：遗物精灵虽然画布是 64×64，但图案本身是圆形（螃蟹/闪电都是圆的）。
    //   画矩形垫底 → 四个角会露在圆形轮廓外，和品质色背景形成明显色差
    //   （用户反馈的"矩形透明背景跟框内背景有色差"）。
    //   圆形垫底贴合图案轮廓，既不露方角，又保证图标对比度。
    var _cx = _icon_x + _icon_size / 2;
    var _cy = _icon_y + _icon_size / 2;
    var _base_r = _icon_size / 2;

    // 由外向内叠几层圆，做出柔和径向渐变（GM 没有原生径向渐变，用同心圆近似）
    var _ring_layers = 7;
    for (var r = _ring_layers; r >= 1; r--) {
        var _rr = _base_r * (r / _ring_layers);
        // 外层更透明、内层更实
        var _ring_alpha = 0.06 + 0.055 * (_ring_layers - r);
        draw_set_alpha(_ring_alpha);
        draw_set_color(c_black);
        draw_circle(_cx, _cy, _rr, false);
    }
    draw_set_alpha(1);

    // 图标本体（冷却中压暗）
    var _spr = variable_instance_exists(_relic, "sprite_index") ? _relic.sprite_index : -1;
    if (_spr != -1 && sprite_exists(_spr)) {
        var _sw = sprite_get_width(_spr);
        var _sh = sprite_get_height(_spr);
        var _scale = 1;
        if (_sw > 0 && _sh > 0) {
            // ★ 尽量取整数倍缩放：像素画非整数缩放会重采样，
            //   在图案边缘产生半透明杂边 → 又是一层"色差"。
            //   精灵正好 64×64、图标框也 64 → scale=1.0，像素完美无重采样。
            var _fit = min(_icon_size / _sw, _icon_size / _sh);
            if (_fit >= 1) {
                _scale = floor(_fit);          // 能放大就取整数倍
                if (_scale < 1) _scale = 1;
            } else {
                _scale = _fit;                 // 放不下才允许小数缩放
            }
        }

        // ★ 冷却中 → 去色压暗；就绪/生效 → 正常亮度
        var _icon_col = c_white;
        var _icon_alpha = 1;
        if (_cd_now > 0 && !_is_active) {
            _icon_col = make_color_rgb(120, 120, 120);
            _icon_alpha = 0.75;
        } else if (_is_active) {
            // 生效中：向主题色偏染 + 亮度脉冲
            _icon_col = merge_color(c_white, _theme_col, 0.35 + 0.25 * _pulse);
        }

        draw_sprite_ext(
            _spr, 0,
            _icon_x + _icon_size / 2,
            _icon_y + _icon_size / 2,
            _scale, _scale, 0,
            _icon_col, _icon_alpha
        );
    }

    // ===== 8. 进度条（★ 冷却增长 / 剩余缩短，方向相反）=====
    var _bar_x = _x + 10;
    var _bar_w = _box_w - 20;
    var _bar_h = 8;
    var _bar_y = _icon_y + _icon_size + 8;

    // 槽底
    draw_set_color(make_color_rgb(45, 45, 45));
    draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);

    if (_is_active) {
        // ---- 生效中：剩余条从右往左缩 ----
        var _left_ratio = clamp(_active_timer / _dur_max, 0, 1);
        var _fill_w = _bar_w * _left_ratio;
        draw_set_color(_theme_col);
        // 靠右对齐填充 → 缩短时从左边"退"
        draw_rectangle(_bar_x + (_bar_w - _fill_w), _bar_y,
                       _bar_x + _bar_w, _bar_y + _bar_h, false);
    } else if (_cd_now > 0) {
        // ---- 冷却中：冷却条从左往右长 ----
        var _cd_ratio = clamp(1 - (_cd_now / _cd_max), 0, 1);
        draw_set_color(merge_color(make_color_rgb(80, 80, 80), _theme_col, 0.55));
        draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w * _cd_ratio, _bar_y + _bar_h, false);
    } else {
        // ---- 就绪：整条拉满 ----
        draw_set_color(_theme_col);
        draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);
    }

    // 条边框
    draw_set_color(make_color_rgb(20, 20, 20));
    draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, true);

    // ===== 9. 状态文字（★ 关键：让玩家知道还剩多久）=====
    if (font_exists(font_chinese)) draw_set_font(font_chinese);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    var _status_txt = "";
    var _status_col = c_white;

    if (_is_active) {
        // 剩余秒数（向上取整，避免显示 0 秒却还在生效）
        var _left_sec = ceil(_active_timer / 60);
        _status_txt = "剩余 " + string(_left_sec) + " 秒";
        _status_col = _theme_col;
    } else if (_cd_now > 0) {
        var _cd_sec = ceil(_cd_now / 60);
        _status_txt = "冷却 " + string(_cd_sec) + " 秒";
        _status_col = make_color_rgb(190, 190, 190);
    } else {
        _status_txt = "R 就绪";
        // 就绪时文字脉冲，制造"可以按了"的引导感
        _status_col = merge_color(_theme_col, c_white, 0.35 + 0.4 * _pulse);
    }

    draw_set_color(_status_col);
    draw_text(_x + _box_w / 2, _bar_y + _bar_h + 15, _status_txt);

    // ===== 恢复默认 =====
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_alpha(1);
}