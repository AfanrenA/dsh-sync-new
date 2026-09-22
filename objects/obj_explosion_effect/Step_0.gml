timer += 1;

// 碎片更新
for (var i = array_length(debris) - 1; i >= 0; i--) {
    var _d = debris[i];
    _d.x += _d.vx;
    _d.y += _d.vy;
    _d.vx *= 0.92;
    _d.vy *= 0.92;
    _d.life -= 1;
    if (_d.life <= 0) {
        array_delete(debris, i, 1);
    }
}

if (timer >= max_timer) {
    instance_destroy();
}