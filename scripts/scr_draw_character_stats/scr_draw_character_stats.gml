/// @function scr_draw_character_stats(ui, player)
function scr_draw_character_stats(ui, player) {
    var _x = ui.ui_left_x;
    var _y = ui.ui_left_y;
    var _w = ui.ui_left_w;
    var _h = ui.ui_left_h;
    
    // 背景
    draw_set_alpha(0.5);
    draw_set_color(c_black);
    draw_rectangle(_x, _y, _x + _w, _y + _h, false);
    draw_set_alpha(1);
    
    // 边框
    draw_set_color(c_white);
    draw_rectangle(_x, _y, _x + _w, _y + _h, true);
    
    // 标题
    draw_set_font(font_chinese);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_yellow);
    draw_text(_x + _w / 2, _y + 30, "角色属性");
    
    // 属性
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    
    var _line_y = _y + 80;
    var _line_height = 40;
    
    // 名字
    draw_text(_x + 20, _line_y, "名字: " + string(player.entity_data.name));
    _line_y += _line_height;
    
    // 种族
    var _race = "人类";
    if (variable_instance_exists(player, "race")) _race = player.race;
    draw_text(_x + 20, _line_y, "种族: " + _race);
    _line_y += _line_height;
    
    // 血量
    draw_text(_x + 20, _line_y, "电量: " + string(player.hp) + " / " + string(player.max_hp));
    _line_y += _line_height;
    
    // 护盾
    var _max_shield = variable_instance_exists(player, "max_shield") ? player.max_shield : 0;
    var _shield = variable_instance_exists(player, "shield") ? player.shield : 0;
    draw_text(_x + 20, _line_y, "护盾: " + string(_shield) + " / " + string(_max_shield));
    _line_y += _line_height;
    
    // 移速
    draw_text(_x + 20, _line_y, "移速: " + string(player.move_speed));
    _line_y += _line_height;
    
    // 称号
    var _title = "新兵";
    if (variable_instance_exists(player, "title")) _title = player.title;
    draw_text(_x + 20, _line_y, "称号: " + _title);
    // ===== 记录 =====
draw_set_color(c_yellow);
draw_text(_x + 20, _y + 400, "记录");

draw_set_color(c_white);
var _record_y = _y + 440;

// 击杀总数
draw_text(_x + 20, _record_y, "已格式化敌人：" + string(player.kill_total));
_record_y += 30;

// 各类型击杀
var _keys = variable_struct_get_names(player.kill_records);
for (var i = 0; i < array_length(_keys); i++) {
    var _enemy_id = _keys[i];
    var _count = player.kill_records[$ _enemy_id];
    var _enemy_data = data_enemy_get(_enemy_id);
    var _enemy_name = _enemy_data != undefined ? _enemy_data.name : _enemy_id;
    draw_text(_x + 40, _record_y, _enemy_name + "：" + string(_count));
    _record_y += 25;
}

_record_y += 10;

// 已解锁武器
draw_text(_x + 20, _record_y, "已解锁武器：" + string(array_length(player.unlocked_weapons)));
_record_y += 30;

// 已解锁武技
draw_text(_x + 20, _record_y, "已解锁武技：" + string(array_length(player.unlocked_skills)));
_record_y += 30;

// 已解锁遗物
draw_text(_x + 20, _record_y, "已解锁遗物：" + string(array_length(player.unlocked_relics)));
	
    // 重置
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}