/// obj_telegraph Step 事件

timer += 1;
if (timer >= lifetime) {
    instance_destroy();
    exit;
}

// 跟随目标位置
if (instance_exists(follow_target)) {
    x = follow_target.x;
    y = follow_target.y;
} else {
    instance_destroy();
}