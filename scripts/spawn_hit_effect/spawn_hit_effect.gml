// ============================================================
// spawn_hit_effect - 受击特效（V3 标准）
// 基于 spawn_particles 组合生成受击特效
// ============================================================

/// @description 生成受击特效
/// @param {real} _x 位置X
/// @param {real} _y 位置Y
/// @param {real} _dir 受击方向
/// @param {color} _color 主颜色
function spawn_hit_effect(_x, _y, _dir = 0, _color = c_white) {
    // ---- 1. 散射粒子（向受击方向散射） ----
    spawn_particles(_x, _y, _color, {
        count: 14,
        speed: 4,
        spread: 140,
        life_min: 6,
        life_max: 16,
        size_min: 0.2,
        size_max: 0.6,
        gravity: 0.06,
        dir: _dir
    });
    
    // ---- 2. 中心闪光（白色爆发） ----
    spawn_particles(_x, _y, c_white, {
        count: 6,
        speed: 1.5,
        spread: 60,
        life_min: 3,
        life_max: 7,
        size_min: 0.1,
        size_max: 0.3,
        gravity: 0,
        dir: _dir
    });
    
    // ---- 3. 碎片（大颗粒） ----
    spawn_particles(_x, _y, choose(c_red, c_orange, c_yellow), {
        count: 4,
        speed: 2.5,
        spread: 160,
        life_min: 8,
        life_max: 16,
        size_min: 0.4,
        size_max: 0.8,
        gravity: 0.1,
        dir: _dir
    });
}