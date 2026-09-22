// ======================================================================
// obj_slash - Create 事件
// 剑气（继承 obj_projectile_base）
// 极简：只声明变量，值由 scr_weapon_slash 设置
// ======================================================================


event_inherited();
// ---- 剑气属性（覆盖父对象默认值） ----
sprite_index = spr_slash;
speed = 6;
life = 30;
max_life = 30;
damage = 10;

// ★ 缩放动画参数（由发射者设置，父对象 Step 会自动处理）★
scale_start = 0.5;   // 初始缩放（小）
scale_end = 2.0;     // 最终缩放（大）slash 设置 ----