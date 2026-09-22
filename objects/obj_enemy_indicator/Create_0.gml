// obj_enemy_indicator Create 事件

follow_target = noone;        // 跟随的敌人
indicator_type = "exclamation";  // "exclamation" 或 "question"
lifetime = 120;               // 持续帧数
flash_count = 1;              // 闪烁次数
flash_timer = 0;
alpha = 1;
scale = 1;
timer = 0;

// 颜色设置
if (indicator_type == "exclamation") {
    draw_color = c_red;
    text = "!";
} else {
    draw_color = c_red;
    text = "?";
}