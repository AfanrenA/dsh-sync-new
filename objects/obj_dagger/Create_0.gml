/// @description 飞刀武器本体
weapon_id = "dagger";
event_inherited();  // 调用 obj_weapon_base 的 Create，触发 scr_weapon_init
scr_weapon_init(id); 