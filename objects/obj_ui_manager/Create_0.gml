// obj_ui_manager Create 事件
// 持久对象，管理所有UI

// ===== 血条参数 =====
hp_bar_x = 20;
hp_bar_y = 20;
hp_bar_width = 200;
hp_bar_height = 20;
hp_bar_spacing = 2;  // 格子间距
hp_segment_count = 10;  // 10格
hp_per_segment = 10;  // 每格10HP（总HP 100）

// 颜色
hp_color_full = c_lime;
hp_color_empty = c_black;
hp_color_damaged = c_red;
hp_bar_border = c_white;

// 护盾参数
shield_bar_x = 20;
shield_bar_y = 45;  // 在血条下方
shield_bar_width = 200;
shield_bar_height = 8;
shield_color = c_blue;
shield_border = c_white;

// 玩家引用
player_ref = noone;

// 动画参数
hp_anim_timer = 0;
hp_anim_speed = 0.05;