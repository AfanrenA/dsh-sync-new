// obj_camera Create 事件
/// @description 摄像机控制器（持久）

// ===== 持久标记 =====
persistent = true;

// ===== 摄像机参数 =====
target = noone;          // 跟随目标
smooth_speed = 0.1;      // 平滑速度

// ===== 震动参数（从 obj_screen_effect 读取） =====
shake_x = 0;
shake_y = 0;

show_debug_message("[CAMERA] 摄像机已创建");