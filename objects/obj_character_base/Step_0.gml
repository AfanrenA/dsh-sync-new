// obj_character_base Step 事件

if (is_dead || !is_alive) exit;
if (global.hit_pause_timer > 0) exit;
// ===== 所有角色通用的状态更新（闪白、冷却、冲撞、硬直） =====
scr_character_state_update(self);

// ===== 武技蓄力状态更新（进度、距离） =====
scr_character_skill_state_update(self);

