var _progress = timer / max_timer;

// ===== 1. 中心闪光（前 5 帧，快速消失）=====
if (timer <= 5) {
    var _flash_alpha = 1 - (timer / 5);
    draw_set_alpha(_flash_alpha);
    draw_set_color(c_white);
    draw_circle(x, y, max_radius * 0.3, false);
}

// ===== 2. 三层扩散圈（红 → 橙 → 黄，速度不同）=====
// 红圈（最外，最快）
var _r1 = max_radius * _progress;
var _a1 = (1 - _progress) * 0.9;
draw_set_alpha(_a1);
draw_set_color(c_red);
for (var i = 0; i < 4; i++) {
    draw_circle(x, y, _r1 - i * 2, true);
}

// 橙圈（中间，稍慢）
var _p2 = clamp(_progress * 1.2, 0, 1);
var _r2 = max_radius * 0.8 * _p2;
var _a2 = (1 - _p2) * 0.7;
draw_set_alpha(_a2);
draw_set_color(c_orange);
for (var i = 0; i < 3; i++) {
    draw_circle(x, y, _r2 - i * 2, true);
}

// 黄圈（内层，最慢）
var _p3 = clamp(_progress * 0.9, 0, 1);
var _r3 = max_radius * 0.5 * _p3;
var _a3 = (1 - _p3) * 0.6;
draw_set_alpha(_a3);
draw_set_color(c_yellow);
draw_circle(x, y, _r3, false);

// ===== 3. 碎片粒子 =====
for (var i = 0; i < array_length(debris); i++) {
    var _d = debris[i];
    var _da = _d.life / 25;
    draw_set_alpha(_da);
    draw_set_color(c_yellow);
    draw_circle(x + _d.x, y + _d.y, _d.size, false);
}

// ===== 恢复 =====
draw_set_alpha(1);
draw_set_color(c_white);