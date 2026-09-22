// scr_muzzle_sparks.gml
// 枪口火花 + 渣子（严格朝枪口方向飞）
function scr_muzzle_sparks(_x, _y, _angle) {
    if (!variable_global_exists("psystem")) return;
    if (!variable_global_exists("pt_muzzle_flash")) return;
    if (!variable_global_exists("pt_muzzle_debris")) return;
    
    // ===== 火花：严格朝枪口方向 ±15° 小锥形 =====
    var _flash_count = irandom_range(6, 10);
    for (var i = 0; i < _flash_count; i++) {
        var _p = part_particles_create(global.psystem, _x, _y, global.pt_muzzle_flash, 1);
        if (_p != undefined) {
            // ★ 单颗粒子精确控制速度向量
            var _dir = _angle + irandom_range(-15, 15);
            var _spd = random_range(6, 12);
            part_particle_velocity(_p, lengthdir_x(_spd, _dir), lengthdir_y(_spd, _dir));
        }
    }
    
    // ===== 渣子：更窄的锥形 ±10°，稍慢 =====
    var _debris_count = irandom_range(3, 5);
    for (var j = 0; j < _debris_count; j++) {
        var _p2 = part_particles_create(global.psystem, _x, _y, global.pt_muzzle_debris, 1);
        if (_p2 != undefined) {
            var _dir2 = _angle + irandom_range(-10, 10);
            var _spd2 = random_range(3, 7);
            part_particle_velocity(_p2, lengthdir_x(_spd2, _dir2), lengthdir_y(_spd2, _dir2));
        }
    }
}