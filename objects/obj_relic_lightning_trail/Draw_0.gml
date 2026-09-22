// obj_relic_lightning_trail Draw —— 电流尾迹

var _n = array_length(points);
if (_n < 2) exit;

// ============================================================
// 1. 生成绘制点：抖动 + 分段曲度 + 按各自年龄算 alpha
// ============================================================
var _draw_pts = [];
var _draw_alphas = [];

for (var i = 0; i < _n; i++) {
    var _age = points[i][2];
    if (_age >= point_max_age) {
        // ★ 已死点：用上一个点占位（保持曲线不断）
        if (i > 0) {
            array_push(_draw_pts, _draw_pts[i - 1]);
            array_push(_draw_alphas, 0);
        }
        continue;
    }

    var _px = points[i][0];
    var _py = points[i][1];

    // ★ 分段曲度抖动：用 idx 和 seed 算出每段不同的抖动幅度
    if (i > 0 && i < _n - 1) {
        var _wave  = sin(jitter_seed + i * 0.7 + current_time * 0.008);
        var _jitter = (6 + _wave * 5);        // 1 ~ 11 像素，有的段曲度大有的小

        // 抖动方向：垂直于路径
        var _prev_x = points[i - 1][0];
        var _prev_y = points[i - 1][1];
        var _next_x = points[i + 1][0];
        var _next_y = points[i + 1][1];
        var _perp = point_direction(_prev_x, _prev_y, _next_x, _next_y) + 90;

        _px += lengthdir_x(random_range(-_jitter, _jitter), _perp);
        _py += lengthdir_y(random_range(-_jitter, _jitter), _perp);
    }

    array_push(_draw_pts, [_px, _py]);

    // ★ 每个点自己的 alpha（年龄越大越淡）
    var _a = 1 - (_age / point_max_age);
    _a = clamp(_a, 0, 1);
    array_push(_draw_alphas, _a);
}

if (array_length(_draw_pts) < 2) exit;

// ============================================================
// 2. 画主曲线（分段绘制，每段用两端 alpha 的较小值）
// ============================================================
var _m = array_length(_draw_pts);

// ---- 2.1 外层辉光 ----
draw_set_color(bolt_color);
for (var i = 0; i < _m - 1; i++) {
    var _a = min(_draw_alphas[i], _draw_alphas[i + 1]);
    if (_a <= 0) continue;
    draw_set_alpha(_a * 0.20);
    draw_line_width(
        _draw_pts[i][0], _draw_pts[i][1],
        _draw_pts[i + 1][0], _draw_pts[i + 1][1],
        bolt_width * 6
    );
}

// ---- 2.2 中层 ----
draw_set_color(bolt_color);
for (var i = 0; i < _m - 1; i++) {
    var _a = min(_draw_alphas[i], _draw_alphas[i + 1]);
    if (_a <= 0) continue;
    draw_set_alpha(_a * 0.7);
    draw_line_width(
        _draw_pts[i][0], _draw_pts[i][1],
        _draw_pts[i + 1][0], _draw_pts[i + 1][1],
        bolt_width * 2.5
    );
}

// ---- 2.3 白芯（带轻微闪烁）----
draw_set_color(core_color);
for (var i = 0; i < _m - 1; i++) {
    var _a = min(_draw_alphas[i], _draw_alphas[i + 1]);
    if (_a <= 0) continue;
    var _flicker = 1;
    if ((current_time div 40 + i) mod 4 < 1) _flicker = 0.5;
    draw_set_alpha(_a * _flicker);
    draw_line_width(
        _draw_pts[i][0], _draw_pts[i][1],
        _draw_pts[i + 1][0], _draw_pts[i + 1][1],
        bolt_width
    );
}

// ============================================================
// 3. ★ 分叉电弧：不规则的往外释放
// ============================================================
for (var i = 0; i < _m; i++) {
    if (_draw_alphas[i] <= 0.1) continue;

    // ★ 用 (i + 帧号) 做伪随机，让每条分叉"存在几帧后消失"
    var _seed = jitter_seed + i * 13;
    var _t = (current_time div 50) + i;
    var _r = frac(sin(_seed + _t) * 43758.5453);   // 伪随机 0~1

    if (_r > branch_chance) continue;

    // 生成 1~3 条分叉
    var _branch_count = 1 + floor(_r * branch_max * 3) mod branch_max;
    for (var b = 0; b < _branch_count; b++) {
        var _bseed = _seed + b * 7 + _t;
        var _br = frac(sin(_bseed * 12.9898) * 43758.5453);

        // 方向：垂直于主路径 ± 大范围
        var _perp2 = 0;
        if (i > 0) {
            _perp2 = point_direction(_draw_pts[i - 1][0], _draw_pts[i - 1][1], _draw_pts[i][0], _draw_pts[i][1]);
        } else if (i < _m - 1) {
            _perp2 = point_direction(_draw_pts[i][0], _draw_pts[i][1], _draw_pts[i + 1][0], _draw_pts[i + 1][1]);
        }
        _perp2 += 90;

        var _bdir  = _perp2 + random_range(-70, 70) + (b * 60);
        var _blen  = random_range(branch_len_min, branch_len_max);
        var _alpha = _draw_alphas[i];

        // 分叉折线（2 段）
        var _b1x = _draw_pts[i][0] + lengthdir_x(_blen * 0.55, _bdir);
        var _b1y = _draw_pts[i][1] + lengthdir_y(_blen * 0.55, _bdir);
        var _b2x = _draw_pts[i][0] + lengthdir_x(_blen, _bdir + random_range(-30, 30));
        var _b2y = _draw_pts[i][1] + lengthdir_y(_blen, _bdir + random_range(-30, 30));

        // 辉光
        draw_set_alpha(_alpha * 0.35);
        draw_set_color(bolt_color);
        draw_line_width(_draw_pts[i][0], _draw_pts[i][1], _b1x, _b1y, branch_width * 3);
        draw_line_width(_b1x, _b1y, _b2x, _b2y, branch_width * 3);

        // 白芯
        draw_set_alpha(_alpha * 0.9);
        draw_set_color(core_color);
        draw_line_width(_draw_pts[i][0], _draw_pts[i][1], _b1x, _b1y, branch_width);
        draw_line_width(_b1x, _b1y, _b2x, _b2y, branch_width);
    }
}

// ===== 重置 =====
draw_set_alpha(1);
draw_set_color(c_white);