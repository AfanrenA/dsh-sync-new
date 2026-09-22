/// @description 绘制信息卡片（武器/遗物/技能）
function draw_ui_infocards(_player) {
    // ====================================================================
    // 1. 获取数据
    // ====================================================================
    
    // ---- 1.1 武器数据 ----
    var _weapon_name = "赤手空拳";
    var _weapon_rarity = "common";

    if (instance_exists(_player.current_weapon)) {
        _weapon_name = _player.current_weapon.weapon_name;
        if (!is_undefined(_player.current_weapon.rarity) && _player.current_weapon.rarity != "") {
            _weapon_rarity = _player.current_weapon.rarity;
        }
        //log_debug("UI 读取武器: " + string(_weapon_name) + " 品质: " + string(_weapon_rarity));
    }

    // ---- 1.2 存档数据 ----
    var _save_data = save_player_get();

    // ---- 1.3 遗物数据 ----
    // 假设遗物数据是一个数组，每个元素是 { id: "xxx", rarity: "common" }
    // 如果还没有品质数据，默认使用 "common"
    var _relic_display = "身无长物";
    var _relic_rarity = "common";  // 默认普通

    if (is_array(_save_data.relics) && array_length(_save_data.relics) > 0) {
        var _first_relic = _save_data.relics[0];
        // 如果遗物是结构体且包含 rarity 字段，读取它
        if (is_struct(_first_relic) && !is_undefined(_first_relic.rarity)) {
            _relic_rarity = _first_relic.rarity;
        }
        // 如果遗物是字符串（只有ID），则使用默认品质
        _relic_display = is_struct(_first_relic) ? _first_relic.name : string(_first_relic);
    }

    // ---- 1.4 技能数据 ----
    var _skill_display = "一无所长";
    var _skill_rarity = "common";  // 默认普通

    if (is_array(_save_data.skills) && array_length(_save_data.skills) > 0) {
        var _first_skill = _save_data.skills[0];
        if (is_struct(_first_skill) && !is_undefined(_first_skill.rarity)) {
            _skill_rarity = _first_skill.rarity;
        }
        _skill_display = is_struct(_first_skill) ? _first_skill.name : string(_first_skill);
    }

    // ====================================================================
    // 2. 构建卡片数据
    // ====================================================================
    
    var _cards = array_create(0);

    // 卡片1：武器
    array_push(_cards, {
        value: _weapon_name,
        color: get_rarity_color(_weapon_rarity)
    });

    // 卡片2：遗物（使用遗物品质颜色）
    array_push(_cards, {
        value: _relic_display,
        color: get_rarity_color(_relic_rarity)
    });

    // 卡片3：技能（使用技能品质颜色）
    array_push(_cards, {
        value: _skill_display,
        color: get_rarity_color(_skill_rarity)
    });

    // ====================================================================
    // 3. 绘制卡片
    // ====================================================================
    
    var _x = ui_card_x;
    var _y = ui_card_y;
    var _w = ui_card_width;
    var _h = ui_card_height;
    var _gap = ui_card_gap;

    for (var i = 0; i < array_length(_cards); i++) {
        var _card = _cards[i];
        var _cx = _x + i * (_w + _gap);
        var _cy = _y;

        // ---- 卡片背景 ----
        draw_set_color(c_black);
        draw_set_alpha(0.5);
        draw_rectangle(_cx, _cy, _cx + _w, _cy + _h, false);
        draw_set_alpha(1);

        // ---- 卡片边框 ----
        draw_set_color(_card.color);
        draw_set_alpha(0.6);
        draw_rectangle(_cx, _cy, _cx + _w, _cy + _h, true);
        draw_set_alpha(1);

        // ---- 卡片内容文字 ----
        draw_set_color(_card.color);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);

        var _text_h = string_height(_card.value);
        var _text_y = (_cy + _h / 2) - (_text_h / 2) - 8;

        draw_set_font(fnt_chinese);
        draw_text(_cx + _w / 2, _text_y, _card.value);

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}