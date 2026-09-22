/// @description 绘制属性面板
function draw_ui_statspanel(_player) {
    // ---- 1. 收集数据 ----
    var _attack = 0;
    if (instance_exists(_player.current_weapon)) {
        _attack = _player.current_weapon.damage;
    }
    
    // 防御力（暂时从玩家变量读取，后续可能从装备读取）
    var _defense = _player.defense || 0;
    
    // 攻速（从武器读取 cooldown 的反比，越小越快）
    var _attack_speed = 1.0;
    if (instance_exists(_player.current_weapon)) {
        _attack_speed = 60 / (_player.current_weapon.cooldown);
        _attack_speed = round(_attack_speed * 10) / 10;  // 保留1位小数
    }
    
    var _fragments_0 = global.shard_0s || 0;
    var _fragments = global.shards || 0;
    var _cores = global.cores || 0;
    
    // ---- 2. 构建显示行 ----
    var _lines = array_create(0);
    array_push(_lines, "算力: " + string(_attack));
    array_push(_lines, "防御: " + string(_defense));
    array_push(_lines, "攻速: " + string(_attack_speed));
    array_push(_lines, "亏电碎片: " + string(_fragments_0));
    array_push(_lines, "含电碎片: " + string(_fragments));
    array_push(_lines, "数据内核: " + string(_cores));
    
    var _count = array_length(_lines);
    
    // ---- 3. 计算面板大小 ----
    var _max_w = 0;
    for (var i = 0; i < _count; i++) {
        var _w = string_width(_lines[i]);
        if (_w > _max_w) _max_w = _w;
    }
    
    var _panel_w = _max_w + 20;
    var _panel_h = _count * ui_stats_line_h + 12;
    var _x = ui_stats_x;
    var _y = ui_stats_y;
    
    // ---- 4. 绘制面板背景 ----
    draw_set_color(c_black);
    draw_set_alpha(0.5);
    draw_rectangle(_x, _y, _x + _panel_w, _y + _panel_h, false);
    draw_set_alpha(1);
    
    // ---- 5. 绘制边框 ----
    draw_set_color(c_gray);
    draw_set_alpha(0.3);
    draw_rectangle(_x, _y, _x + _panel_w, _y + _panel_h, true);
    draw_set_alpha(1);
    
    // ---- 6. 绘制文字（每行垂直居中） ----
    draw_set_color(c_white);
    draw_set_alpha(0.9);
    draw_set_valign(fa_top);
    draw_set_halign(fa_left);

    for (var i = 0; i < _count; i++) {
    var _line_center_y = _y + 6 + i * ui_stats_line_h + ui_stats_line_h / 2 -10;
    var _text_h = string_height(_lines[i]);
    var _text_y = _line_center_y - _text_h / 2;
    
    draw_text(_x + 10, _text_y, _lines[i]);
}

draw_set_alpha(1);
}