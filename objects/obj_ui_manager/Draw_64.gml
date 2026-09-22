// obj_ui_manager Draw GUI 事件

if (player_ref == noone || !instance_exists(player_ref)) return;

// ===== 1. 血条 =====
scr_draw_ui_hpbar(player_ref);

// ===== 2. 信息卡片 =====
scr_draw_ui_infocards(player_ref);

// 假设你在 Draw GUI 事件里
scr_draw_ammo_magazine(player_ref, 20, display_get_gui_height() - 200);

// ===== 4. 榴弹匣（装了附件才显示）=====
scr_draw_grenade_magazine(player_ref, 204, display_get_gui_height() - 159);
