// ======================================================================
// obj_weapon_base - Step 事件（V3 纯净化版本）
// ======================================================================

// 0. ★ 武器自身冷却递减（放在最前面）★
// ============================================================
if (attack_cooldown > 0) {
    attack_cooldown -= 1;
}

// ============================================================
// 1. ★ 丢弃状态检查（优先级最高）★
// ============================================================
if (is_dropped) {
    if (instance_exists(fire_point)) {
        instance_destroy(fire_point);
        fire_point = noone;
    }
    var _player = instance_nearest(x, y, obj_player);
    if (instance_exists(_player)) {
        depth = _player.depth + 1;
    } else {
        depth = 1000;
    }
    exit;
}

// ============================================================
// 2. 持有者检查
// ============================================================
if (!instance_exists(owner)) {
    if (!is_dropped) {
        is_dropped = true;
        show_debug_message("⚠️ 武器失去主人: " + string(weapon_name));
    }
    exit;
}

// ============================================================
// 3. 计算基础朝向（逻辑方向）
// ============================================================
var _target = noone;
if (owner.object_index == obj_player || owner.object_index == obj_player_base) {
    base_angle = scr_weapon_aim(owner, noone);
} else {
    if (variable_instance_exists(owner, "target")) {
        _target = owner.target;
    }
    base_angle = scr_weapon_aim(owner, _target);
}

// ============================================================
// 4. 更新武器位置（跟随持有者）
// ============================================================
var _follow_dist = 24;
x = owner.x + lengthdir_x(_follow_dist, base_angle);
y = owner.y + lengthdir_y(_follow_dist, base_angle);

// ============================================================
// 4.5 ★ 深度排序（被持有状态）★
// ============================================================
if (instance_exists(owner)) {
    depth = owner.depth - 1;
} else {
    depth = -y;
}

// ============================================================
// 5. 左右翻转（根据朝向）
// ============================================================
image_yscale = scr_weapon_flip(base_angle);

// ============================================================
// 6. ★ 管理 fire_point 实体 ★
// ============================================================
if (instance_exists(owner)) {
    if (!instance_exists(fire_point)) {
        var _fire_obj = obj_fire_point;
        if (weapon_type == "ranged" || weapon_type == "thrown") {
            _fire_obj = obj_fire_point_ranged;
        }
        fire_point = instance_create_layer(x, y, "Instances", _fire_obj);
        fire_point.weapon_ref = id;
        fire_point.weapon_type = weapon_type;
        show_debug_message("✅ fire_point 已创建，绑定到: " + string(weapon_name));
    }
} else {
    if (instance_exists(fire_point)) {
        instance_destroy(fire_point);
        fire_point = noone;
    }
}

// ============================================================
// 7. ★ 武器类型分支 ★
// ============================================================
if (weapon_type == "melee" || weapon_type == "hack") {
    if (!is_swinging) {
        image_angle = base_angle;
    } else {
        scr_weapon_update_melee(id);
        if (instance_exists(hitbox_ref)) {
            scr_hitbox_update(hitbox_ref);
        }
    }
    // 延迟剑气
    if (slash_queued) {
        slash_delay -= 1;
        if (slash_delay <= 0) {
            slash_queued = false;
            if (instance_exists(fire_point)) {
                var _data = data_weapon_get(weapon_id);
                if (_data != undefined && _data.slash_sprite != noone) {
                    var _slash = instance_create_layer(fire_point.x, fire_point.y, "Effects", _data.slash_sprite);
                    if (_slash != noone) {
                        _slash.direction = base_angle;
                        _slash.speed = _data.slash_speed;
                        _slash.life = _data.slash_life;
                        _slash.max_life = _data.slash_life;
                        _slash.damage = damage;
                        _slash.owner = owner;
                        _slash.image_angle = base_angle;
                        _slash.scale_start = _data.slash_scale_start;
                        _slash.scale_end = _data.slash_scale_end;
                        _slash.image_xscale = _data.slash_scale_start;
                        _slash.image_yscale = _data.slash_scale_start;
                        show_debug_message("🗡️ 剑气已发射！");
                    }
                }
            }
        }
    }
} else {
    image_angle = base_angle;
}

// ============================================================
// 8. ★ 视觉后坐力 ★
// ============================================================
if (weapon_type == "ranged" && recoil_timer > 0) {
    recoil_timer -= 1;
    var _progress = recoil_timer / 8;
    var _offset = recoil_offset * _progress * 0.5;
    var _angle = recoil_angle + 180;
    x += lengthdir_x(_offset, _angle);
    y += lengthdir_y(_offset, _angle);
}

// ============================================================
// 9. ★ 换弹逻辑（武器自己管理）★
// ============================================================
if (is_reloading) {
    reload_timer -= 1;
    if (reload_timer <= 0) {
        is_reloading = false;
        magazine_current = magazine_max;
        show_debug_message("🔫 换弹完成: " + string(weapon_name) + " " + string(magazine_current) + " 发");
    } else {
        var _progress = 1 - (reload_timer / reload_time);
        magazine_loading = ceil(_progress * magazine_max);
        if (magazine_loading > magazine_max) magazine_loading = magazine_max;
    }
}

// ============================================================
// 10. ★ 强制深度修正 ★
// ============================================================
if (is_dropped) {
    depth = 100;
} else if (instance_exists(owner)) {
    depth = owner.depth - 1;
} else {
    depth = -y;
}