/// @description 榴弹炮（附件型武技）- 只做瞄准兜底
event_inherited();

// ===== 装填逻辑不在这里 =====
// cooldown_timer 递减 + 装填判定都在 scr_character_state_update
// 原因：cooldown_timer 是基类字段，scr_character_state_update 已经递减它
//       这里再递减会走快一倍

// ===== 瞄准兜底：瞄准中弹药没了就退出 =====
if (aiming && ammo_current <= 0) {
    aiming = false;
}