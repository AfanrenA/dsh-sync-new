/// @description 游戏总控制器（持久）
window_set_cursor(cr_none);
// ============================================================
// 像素风 + 整数倍缩放
// ============================================================
instance_create_depth(0, 0, -10000, obj_custom_cursor);
global.base_width = 640;
global.base_height = 360;

// 关闭纹理过滤（防模糊）
gpu_set_texfilter(false);
// ★ 删除这行：gpu_set_tex_filter_ext(false);

// 初始窗口大小（2倍）
window_set_size(global.base_width * 2, global.base_height * 2);
window_center();

// ===== 持久标记 =====
persistent = true;

// ===== 屏幕效果引用 =====
screen_effect = noone;

// ===== 玩家引用 =====
player_ref = noone;

// ===== 黑屏（复活用） =====
black_screen_alpha = 0;
show_revive_hint = false;
revive_text = "数据消散！点击鼠标或按任意键重组";
revive_text_color = c_white;

show_debug_message("[GAME] 游戏控制器已创建");
// ===== 顿帧计时器 =====
global.hit_pause_timer = 0;