/// @description 榴弹炮（附件型武技）
event_inherited();

// ===== 附件标识 =====
type = "附件";

// ===== 弹药（榴弹匣）=====
ammo_current = 0;
ammo_max = 2;

// ===== 两段式发射状态机 =====
aiming = false;
aiming_just_started = false;

// ★ 瞄准锁定的目标位置
aim_target_x = 0;
aim_target_y = 0;

// ===== 数据缓存 =====
data = data_skill_get("skill_grenade");
if (data != undefined) {
    ammo_max = data.ammo_max;
}

// ===== 引用 =====
owner_ref = noone;
weapon_ref = noone;

aim_target_x = 0;
aim_target_y = 0;