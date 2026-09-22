/// @description 火焰炸弹 - 创建
weapon_id = "firebomb";
event_inherited();   // 调用 obj_weapon_base 的 Create，触发 scr_weapon_init
scr_weapon_init(id); 