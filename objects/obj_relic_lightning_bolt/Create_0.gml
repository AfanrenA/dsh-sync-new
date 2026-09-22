// obj_relic_lightning_bolt Create —— 爆发电弧（跟随持有者）
// 用法：scr_relic_thunder_burst 创建，设置 follow_ref + dir + len

// ===== 跟随 =====
follow_ref = noone;         // ★ 跟随的目标（玩家），每帧更新坐标
follow_offset_x = 0;        // 相对偏移（相对玩家中心的固定偏移）
follow_offset_y = 0;

// ===== 折线点（相对坐标，[x,y] 数组）=====
// ★ 存"相对 follow_ref 的偏移"，这样跟随时整条电弧一起平移
points = [];
segment_count = 6;

// ===== 生命周期 =====
life = 15;
max_life = 15;

// ===== 伤害 =====
damage = 15;
damage_radius = 18;
has_hit = [];
owner_ref = noone;

// ===== 视觉 =====
bolt_color = make_color_rgb(170, 90, 255);   // 紫色（对齐你的参考图）
core_color = c_white;
bolt_width = 3;

// ===== 抖动 =====
jitter_amount = 4;          // 每帧抖动幅度
jitter_timer = 0;

// ★ 颜色参数（供外部覆盖）
// ===== ★ 每帧重新生成的骨架 =====
points_live = [];
jitter_seed = random(1000);