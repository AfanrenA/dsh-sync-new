// ============================================================
// spawn_particles - 通用粒子生成器（V3 标准）
// 灵活生成各类粒子特效
// ============================================================

/// @description 生成通用粒子
/// @param {real} _x 位置X
/// @param {real} _y 位置Y
/// @param {color} _color 主颜色
/// @param {array} _options 可选参数：{ count, speed, spread, life, size, gravity, sprite }
function spawn_particles(_x, _y, _color, _options = undefined) {
    // ---- 默认参数 ----
    var _count = 10;
    var _speed = 3;
    var _spread = 360;
    var _life_min = 8;
    var _life_max = 20;
    var _size_min = 0.2;
    var _size_max = 0.5;
    var _gravity = 0.05;
    var _sprite = spr_particle_spark;
    var _dir = 0;
    
    // ---- 覆盖自定义参数 ----
    if (_options != undefined) {
        if (struct_exists(_options, "count")) _count = _options.count;
        if (struct_exists(_options, "speed")) _speed = _options.speed;
        if (struct_exists(_options, "spread")) _spread = _options.spread;
        if (struct_exists(_options, "life_min")) _life_min = _options.life_min;
        if (struct_exists(_options, "life_max")) _life_max = _options.life_max;
        if (struct_exists(_options, "size_min")) _size_min = _options.size_min;
        if (struct_exists(_options, "size_max")) _size_max = _options.size_max;
        if (struct_exists(_options, "gravity")) _gravity = _options.gravity;
        if (struct_exists(_options, "sprite")) _sprite = _options.sprite;
        if (struct_exists(_options, "dir")) _dir = _options.dir;
    }
    
    // ---- 确保粒子图层存在 ----
    var _layer = "Effects";
    if (!layer_exists(_layer)) {
        _layer = layer_create(-1, _layer);
    }
    
    // ---- 生成粒子 ----
    for (var i = 0; i < _count; i++) {
        var _p = instance_create_layer(_x, _y, _layer, obj_particle);
        if (_p == noone) continue;
        
        var _angle = _dir + irandom_range(-_spread * 0.5, _spread * 0.5);
        var _spd = random_range(_speed * 0.3, _speed);
        
        _p.sprite_index = _sprite;
        _p.image_blend = choose(_color, c_orange, c_yellow, c_white);
        _p.image_xscale = random_range(_size_min, _size_max);
        _p.image_yscale = _p.image_xscale;
        _p.image_alpha = 1;
        _p.x_speed = lengthdir_x(_spd, _angle);
        _p.y_speed = lengthdir_y(_spd, _angle);
        _p.life = irandom_range(_life_min, _life_max);
        _p.max_life = _p.life;
        _p.gravity = _gravity;
        _p.friction = 0.94;
    }
}