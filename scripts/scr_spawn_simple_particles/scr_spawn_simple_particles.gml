// ============================================================
// scr_spawn_simple_particles - 简单粒子调用（兼容旧代码）
// ============================================================

function scr_spawn_simple_particles(_x, _y, _count, _color, _size_min = 0.2, _size_max = 0.5, _life_min = 4, _life_max = 12) {
    spawn_particles(_x, _y, _color, {
        count: _count,
        size_min: _size_min,
        size_max: _size_max,
        life_min: _life_min,
        life_max: _life_max
    });
}