// scr_explosion_smoke.gml
// 爆炸烟雾（从爆炸中心向四周扩散）
function scr_explosion_smoke(_x, _y, _radius) {
    if (!variable_global_exists("psystem")) return;
    if (!variable_global_exists("pt_muzzle_smoke")) return;
    
    var _count = irandom_range(15, 25);
    for (var i = 0; i < _count; i++) {
        var _px = _x + random_range(-20, 20);
        var _py = _y + random_range(-20, 20);
        var _p = part_particles_create(global.psystem, _px, _py, global.pt_muzzle_smoke, 1);
        if (_p != undefined) {
            var _dir = random(360);
            var _spd = random_range(1, 4);
            part_particle_velocity(_p, lengthdir_x(_spd, _dir), lengthdir_y(_spd, _dir));
        }
    }
}