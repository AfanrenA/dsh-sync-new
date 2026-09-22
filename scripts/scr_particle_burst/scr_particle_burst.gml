// ======================================================================
// scr_particle_burst - 粒子爆发（V3 标准）
// ======================================================================
/// @description 在指定位置生成爆发粒子
/// @param {real} _x 中心X
/// @param {real} _y 中心Y
/// @param {real} _count 粒子数量
/// @param {color} _color 粒子颜色
/// @param {real} _speed 粒子速度
/// @param {real} _life 粒子寿命
/// @param {real} _spread 扩散半径

function scr_particle_burst(_x, _y, _count, _color, _speed, _life, _spread) {
    // ★ 确保粒子图层存在 ★
    var _layer = "Particles";
    if (!layer_exists(_layer)) {
        _layer = layer_create(-1, _layer);
        show_debug_message("✅ 自动创建粒子图层: " + string(_layer));
    }
    
    repeat (_count) {
        var _p = instance_create_layer(_x, _y, _layer, obj_particle);
        if (_p == noone) continue;
        
        var _angle = random(360);
        var _dist = random(_spread);
        _p.x += lengthdir_x(_dist, _angle);
        _p.y += lengthdir_y(_dist, _angle);
        
        _p.x_speed = lengthdir_x(random(_speed), _angle);
        _p.y_speed = lengthdir_y(random(_speed), _angle) - random(1);
        
        _p.image_blend = _color;
        _p.image_alpha = 1;
        _p.image_xscale = random_range(0.3, 0.8);
        _p.image_yscale = _p.image_xscale;
        _p.sprite_index = spr_particle_spark;
        _p.life = random_range(_life * 0.5, _life);
        _p.max_life = _p.life;
        _p.gravity = 0.05;
        _p.friction = 0.98;
    }
}