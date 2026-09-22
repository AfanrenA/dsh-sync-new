// obj_relic_lightning_bolt Draw

if (!variable_instance_exists(id, "points_live")) exit;
if (array_length(points_live) < 2) exit;

var _n = array_length(points_live);

// ===== 闪烁 alpha（电弧更"跳"）=====
var _fade = clamp(life / max_life, 0, 1);
var _flicker = 1;
if ((life mod 3) < 1) _flicker = 0.35;
if ((life mod 7) < 2) _flicker = 0.7;
var _alpha = _fade * _flicker;

// ===== 转成世界坐标 =====
var _wp = [];
for (var i = 0; i < _n; i++) {
    array_push(_wp, [x + points_live[i][0], y + points_live[i][1]]);
}

// ===== 1. 外层辉光 =====
draw_set_alpha(_alpha * 0.18);
draw_set_color(bolt_color);
for (var i = 0; i < _n - 1; i++) {
    draw_line_width(_wp[i][0], _wp[i][1], _wp[i + 1][0], _wp[i + 1][1], bolt_width * 7);
}

// ===== 2. 中层 =====
draw_set_alpha(_alpha * 0.65);
draw_set_color(bolt_color);
for (var i = 0; i < _n - 1; i++) {
    draw_line_width(_wp[i][0], _wp[i][1], _wp[i + 1][0], _wp[i + 1][1], bolt_width * 3);
}

// ===== 3. 白芯 =====
draw_set_alpha(_alpha);
draw_set_color(core_color);
for (var i = 0; i < _n - 1; i++) {
    draw_line_width(_wp[i][0], _wp[i][1], _wp[i + 1][0], _wp[i + 1][1], bolt_width);
}

// ============================================================
// 4. ★ 分叉电弧（爆发的比尾迹更密更长）
// ============================================================
for (var i = 1; i < _n - 1; i++) {
    // 伪随机：每帧变化，形成"滋滋"放电
    var _seed = jitter_seed + i * 17;
    var _t    = jitter_timer;
    var _r    = frac(sin(_seed + _t * 0.7) * 43758.5453);

    if (_r > 0.40) continue;        // 40% 概率分叉

    var _branch_count = 1 + floor(_r * 6) mod 3;   // 1~3 条

    for (var b = 0; b < _branch_count; b++) {
        var _bseed = _seed + b * 11 + _t;
        var _br = frac(sin(_bseed * 12.9898) * 43758.5453);

        // 垂直于主路径
        var _perp = point_direction(_wp[i - 1][0], _wp[i - 1][1], _wp[i + 1][0], _wp[i + 1][1]) + 90;
        var _bdir = _perp + random_range(-80, 80);
        var _blen = random_range(25, 70);

        // 分叉走 3 段（更蜿蜒）
        var _cx = _wp[i][0];
        var _cy = _wp[i][1];
        var _cdir = _bdir;

        draw_set_alpha(_alpha * 0.9);
        draw_set_color(core_color);
        var _px = _cx;
        var _py = _cy;
        for (var seg = 0; seg < 3; seg++) {
            _cdir += random_range(-35, 35);
            var _nx2 = _px + lengthdir_x(_blen / 3, _cdir);
            var _ny2 = _py + lengthdir_y(_blen / 3, _cdir);

            draw_set_alpha(_alpha * 0.3);
            draw_set_color(bolt_color);
            draw_line_width(_px, _py, _nx2, _ny2, 4);

            draw_set_alpha(_alpha * 0.9);
            draw_set_color(core_color);
            draw_line_width(_px, _py, _nx2, _ny2, 1.5);

            _px = _nx2;
            _py = _ny2;
        }
    }
}

// ===== 重置 =====
draw_set_alpha(1);
draw_set_color(c_white);