/// @description 爆炸特效
timer = 0;
max_timer = 30;
max_radius = 160;

// 碎片粒子
debris = [];
var _count = 12;
for (var i = 0; i < _count; i++) {
    var _ang = (360 / _count) * i + random_range(-15, 15);
    var _spd = random_range(4, 10);
    array_push(debris, {
        x: 0,
        y: 0,
        vx: lengthdir_x(_spd, _ang),
        vy: lengthdir_y(_spd, _ang),
        size: random_range(2, 4),
        life: random_range(15, 25)
    });
}