/// obj_item_base Draw —— 所有地面物品共用绘制
/// ★ 画出自己 + 拾取提示

if (sprite_index != noone) {
    draw_self();
}

// ===== 地面拾取提示 =====
if (is_on_ground && pickup_hint_visible) {
    var _name = display_name;
    var _color = rarity_color != undefined ? rarity_color : c_white;
    scr_draw_pickup_hint(self, "[F] ", _name, _color);
}