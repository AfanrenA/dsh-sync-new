/// @description 爆炸预警圈 - 创建
radius = 120;
max_radius = 120;        // 最终半径
duration = 90;           // 存在帧数（1.5秒）
timer = 0;

// ★★★ 半透明淡红色 ★★★
base_alpha = 0.25;       // 很淡
image_alpha = base_alpha;

// 缩放动画
scale = 0.3;             // 从 30% 开始
scale_speed = 0.015;     // 每帧扩大