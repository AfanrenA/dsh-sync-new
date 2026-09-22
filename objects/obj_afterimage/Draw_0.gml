// ===== 描边发光（8方向偏移 + bm_add） =====
if (snapshot_sprite != -1 && life > 0) {
    var _t = life / life_max;                    // 1 → 0 渐隐
    var _outline_alpha = 0.6 * _t;               // 描边透明度
    var _offsets = [[-3,0],[3,0],[0,-3],[0,3],[-2,-2],[2,-2],[-2,2],[2,2]];
    
    gpu_set_blendmode(bm_add);
    for (var _i = 0; _i < array_length(_offsets); _i++) {
        var _ox = _offsets[_i][0];
        var _oy = _offsets[_i][1];
        draw_sprite_ext(
            snapshot_sprite, snapshot_index,
            x + _ox, y + _oy,
            snapshot_xscale, snapshot_yscale,
            snapshot_angle,
            outline_color, _outline_alpha
        );
    }
    gpu_set_blendmode(bm_normal);
}

// ===== 本体 =====
var _body_alpha = 0.7 * (life / life_max);
draw_sprite_ext(snapshot_sprite, snapshot_index, x, y, snapshot_xscale, snapshot_yscale, snapshot_angle, c_white, _body_alpha);