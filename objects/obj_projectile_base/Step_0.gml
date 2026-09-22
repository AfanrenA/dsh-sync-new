// obj_projectile_base Step 事件
// 所有投射物的通用逻辑
if (global.hit_pause_timer > 0) exit;

// ===== 距离追踪 =====
traveled_distance += move_speed;

// ===== 距离到达销毁（优先于一切） =====
if (max_distance != undefined && max_distance > 0) {
    var _half_w = (sprite_width * abs(image_xscale)) * 0.5;
    if (traveled_distance + _half_w >= max_distance) {
                show_debug_message("[销毁-距离] id=" + projectile_id + " traveled=" + string(traveled_distance) + " | max=" + string(max_distance) + " | 落点x=" + string(x) + " y=" + string(y) + " | 出生x=" + string(dbg_spawn_x) + " y=" + string(dbg_spawn_y));
        instance_destroy();
        exit;
    }
}

// 基础飞行
scr_projectile_move(self);

// 碰撞检测
var _hit = scr_projectile_collision(self);
if (_hit != noone && instance_exists(_hit)) {
    var _target = _hit;
    
    // 检查目标是否存活
    if (!_target.is_alive || _target.is_dead) {
        //show_debug_message("[销毁-撞死人] id=" + projectile_id + " target=" + object_get_name(_target.object_index) + " alive=" + string(_target.is_alive) + " dead=" + string(_target.is_dead) + " traveled=" + string(traveled_distance));
        instance_destroy();
        exit;
    }
    
    // 检查攻击者是否存活
    if (owner_id == noone || !owner_id.is_alive || owner_id.is_dead) {
        //show_debug_message("[销毁-攻击者死] id=" + projectile_id + " traveled=" + string(traveled_distance));
        instance_destroy();
        exit;
    }
    
    var _pkt = scr_damage_packet_create(damage);
    scr_damage_packet_from_projectile(_pkt, self);
    scr_damage_apply(_target, _pkt, owner_id);
    
    scr_show_enemy_hpbar(_target);
    
    //show_debug_message("[销毁-命中] id=" + projectile_id + " target=" + object_get_name(_target.object_index) + " traveled=" + string(traveled_distance));
    instance_destroy();
    exit;
}

// 生命周期
life -= 1;
if (life <= 0) {
    //show_debug_message("[销毁-life] id=" + projectile_id + " traveled=" + string(traveled_distance) + " life=" + string(life));
    instance_destroy();
}