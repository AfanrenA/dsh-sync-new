// ============================================================
// obj_enemy_melee - Create 事件
// ============================================================

// ★ 第一步：先设置精灵（在调用父对象之前） ★
sprite_index = spr_enemy_melee;  // 换成你敌人的精灵

// ★ 第二步：再调用父对象（创建碰撞组件） ★
event_inherited();
// ★★★ 直接调用 scr_enemy_init ★★★
scr_enemy_init(id, "swordsman");
// ★ 第三步：设置敌人特有属性 ★
hp = 150;
max_hp = 150;
move_speed = 2.5;
// ---- 身份标识 ----
who = "enemy";
show_debug_message("🏃 敌人速度: " + string(move_speed) + " 攻击范围: " + string(attack_range));

