// obj_axe - Create 事件

show_debug_message("🔧 obj_axe Create 开始");

// ★★★ 设置 weapon_id ★★★
weapon_id = "axe";
show_debug_message("🔧 weapon_id 已设置为: " + string(weapon_id));

// ★★★ 调用父类 ★★★
event_inherited();
show_debug_message("🔧 event_inherited 完成，weapon_id = " + string(weapon_id));

// ★★★ 显式初始化 ★★★
scr_weapon_init(id);
show_debug_message("🔧 obj_axe 初始化完成，weapon_id = " + string(weapon_id));