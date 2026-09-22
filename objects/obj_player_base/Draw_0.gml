// ============================================================
// obj_player_base - Draw 事件
// V3 原则：组合优于继承，按需调用独立绘制函数
// ============================================================

// 1. 先画父对象（obj_character_base 的绘制）
event_inherited();

// 2. 画玩家自己
draw_self();

// 3. 在玩家之上画闪白（受击时）
scr_draw_hit_flash(id);

// 4. 画冷却圈（攻击冷却 + 换弹）
scr_draw_cooldown_ring(id);

scr_debug_draw_collision(id);