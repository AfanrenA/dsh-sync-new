/// @description 命中特效（纯代码绘制）
life = 15;                  // 存活帧数
image_alpha = 1;
size = 8 + random(8);       // 随机大小
angle = random(360);        // 随机旋转
color = c_red;              // 默认红色
x_speed = random_range(-2, 2);  // 轻微扩散
y_speed = random_range(-2, 2);