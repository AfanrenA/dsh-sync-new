/// @description 预警圈 - 逐帧更新
timer++;
scale += scale_speed;

// ★★★ 半径逐渐扩大（像蛤蟆怪预警圈）★★★
radius = max_radius * min(scale, 1.0);

// ★★★ 透明度逐渐变淡，最后消失 ★★★
var _life_progress = timer / duration;
image_alpha = base_alpha * (1 - _life_progress);

// 闪烁效果（快爆炸时闪烁）
if (_life_progress > 0.7) {
    image_alpha *= 0.5 + 0.5 * sin(timer * 0.3);
}

// 销毁
if (timer >= duration) {
    instance_destroy();
}