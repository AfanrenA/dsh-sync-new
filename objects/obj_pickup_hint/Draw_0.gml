if (!instance_exists(target_item)) exit;
if (!target_item.is_on_ground) exit;
if (!target_item.pickup_hint_visible) exit;

draw_set_font(font_chinese);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);

var _full_text = hint_label + hint_name;
var _total_width = string_width(_full_text);
var _start_x = x - _total_width / 2;

draw_set_alpha(0.8 + 0.2 * sin(current_time / 200));

// 画 [F] 标签
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_text(_start_x, y, hint_label);

// 画物品名
draw_set_color(hint_color);
draw_text(_start_x + string_width(hint_label), y, hint_name);

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);