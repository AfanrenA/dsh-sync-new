// scr_muzzle_smoke.gml
// 枪口烟雾（榴弹发射时，扩散大、速度慢、持续久）
function scr_muzzle_smoke(_x, _y, _angle) {
    if (!variable_global_exists("psystem")) return;
    if (!variable_global_exists("pt_muzzle_smoke")) return;
    
    var _smoke_count = irandom_range(10, 15);
    for (var i = 0; i < _smoke_count; i++) {
        var _p = part_particles_create(global.psystem, _x, _y, global.pt_muzzle_smoke, 1);
        if (_p != undefined) {
            var _dir = _angle + irandom_range(-30, 30);
            var _spd = random_range(2, 5);
            part_particle_velocity(_p, lengthdir_x(_spd, _dir), lengthdir_y(_spd, _dir));
        }
    }
}