// obj_relic_lightning_trail Create —— 电流尾迹（每点独立寿命 + 分叉电弧）

// ===== 轨迹点：每个点 [x, y, age] =====
points = [];

// ===== 生命周期 =====
life = 45;                  // 整体存活兜底（所有点老化完后销毁）
max_life = 45;
point_max_age = 60;         // ★ 每个点的最大年龄（越大尾迹越长）

// ===== 伤害 =====
damage = 10;
damage_radius = 20;
damage_interval = 12;
damage_timer = 0;
has_hit = [];
owner_ref = noone;

// ===== 视觉 =====
bolt_color = make_color_rgb(170, 90, 255);
core_color = c_white;
bolt_width = 3;

// ===== 分叉电弧参数 =====
branch_chance = 0.25;       // 每个点每帧分叉概率
branch_max = 3;             // 单个点最多同时有几条分叉
branch_len_min = 18;
branch_len_max = 55;
branch_width = 1.5;

// ===== 曲度参数（★ 分段随机，让曲线多样化）=====
jitter_seed = random(1000);   // 每条尾迹一个种子，形状不同