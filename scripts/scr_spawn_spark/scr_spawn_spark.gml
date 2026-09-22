// ======================================================================
// scr_spawn_spark - 生成火花特效（V3 标准）
// ======================================================================
/// @description 在指定位置生成火花粒子
/// @param {real} _x 位置X
/// @param {real} _y 位置Y
/// @param {color} _color 粒子颜色
/// @param {real} _count 粒子数量

function scr_spawn_spark(_x, _y, _color, _count) {
    // ---- 确保粒子图层存在 ----
    var _layer = "Effects";
    if (!layer_exists(_layer)) {
        _layer = layer_create(-1, _layer);
    }
    
    // ---- 生成粒子 ----
    repeat (_count) {
        var _p = instance_create_layer(_x, _y, _layer, obj_particle);
        if (_p == noone) continue;
        
        _p.image_blend = _color;
        _p.image_xscale = random_range(0.15, 0.5);
        _p.image_yscale = _p.image_xscale;
        _p.x_speed = random_range(-4, 4);
        _p.y_speed = random_range(-4, 4);
        _p.life = random_range(4, 12);
        _p.max_life = _p.life;
        _p.gravity = 0.1;
        _p.friction = 0.92;
        _p.sprite_index = spr_particle_spark;
        _p.image_alpha = 1;
    }
}