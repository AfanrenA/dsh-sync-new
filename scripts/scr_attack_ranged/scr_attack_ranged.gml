// ======================================================================
// scr_attack_ranged.gml
// 远程攻击行为（生成子弹 + 弹匣消耗 + 后坐力 + 枪口火花）
// ======================================================================

function scr_attack_ranged(_owner) {
    
    // ============================================================
    // 1. 获取持有者的武器
    // ============================================================
    var _weapon = _owner.current_weapon;
    if (!instance_exists(_weapon)) {
        show_debug_message("⚠️ 远程攻击失败：持有者没有武器");
        return;
    }
    
    // ============================================================
    // 2. 获取武器数据
    // ============================================================
    var _data = data_weapon_get(_weapon.weapon_id);
    if (_data == undefined) {
        show_debug_message("⚠️ 远程攻击失败：武器数据不存在");
        return;
    }
    
    // ============================================================
    // 3. ★ 计算发射点位置
    // ============================================================
    var _offset_x = 30;
    var _offset_y = 0;
    
    if (struct_exists(_data, "fire_point_x")) {
        _offset_x = _data.fire_point_x;
    }
    if (struct_exists(_data, "fire_point_y")) {
        _offset_y = _data.fire_point_y;
    }
    
    var _flip = sign(_weapon.image_xscale);
    var _final_offset_x = _offset_x * _flip;
    var _final_offset_y = _offset_y * _flip;
    
    var _angle = _weapon.base_angle;
    var _perp_angle = _angle + 90;
    
    var _fire_x = _weapon.x + lengthdir_x(_final_offset_x, _angle) + lengthdir_x(_final_offset_y, _perp_angle);
    var _fire_y = _weapon.y + lengthdir_y(_final_offset_x, _angle) + lengthdir_y(_final_offset_y, _perp_angle);
    
    // ============================================================
    // ★★★ 4. 弹匣消耗（关键修复）★★★
    // ============================================================
    if (_weapon.magazine_max > 0) {
        // 弹匣为空 → 触发换弹
        if (_weapon.magazine_current <= 0) {
            _weapon.start_reload();
            show_debug_message("🔄 弹匣已空，换弹中...");
            return;
        }
        // 消耗一发
        _weapon.magazine_current -= 1;
        show_debug_message("🔫 剩余子弹: " + string(_weapon.magazine_current) + "/" + string(_weapon.magazine_max));
    }
    
    // ============================================================
    // 5. 生成子弹
    // ============================================================
    if (_data.bullet_sprite == noone) {
        show_debug_message("⚠️ 远程攻击失败：数据表未配置 bullet_sprite");
        return;
    }
    
    var _bullet = instance_create_layer(_fire_x, _fire_y, "Effects", _data.bullet_sprite);
    if (!instance_exists(_bullet)) {
        show_debug_message("⚠️ 远程攻击失败：子弹创建失败");
        return;
    }
    
    _bullet.direction = _weapon.base_angle;
    _bullet.speed = _data.bullet_speed;
    _bullet.life = _data.bullet_life;
    _bullet.damage = _weapon.damage;
    _bullet.owner = _owner;
    _bullet.image_angle = _weapon.base_angle;
    
    // ============================================================
    // 6. ★ 枪口火花
    // ============================================================
    scr_muzzle_sparks(_fire_x, _fire_y, _weapon.base_angle);
    
    // ============================================================
    // 7. ★ 视觉后坐力
    // ============================================================
    if (struct_exists(_data, "visual_recoil") && _data.visual_recoil > 0) {
        _weapon.recoil_timer = 8;
        _weapon.recoil_offset = _data.visual_recoil;
        _weapon.recoil_angle = _weapon.base_angle;
        show_debug_message("🎯 视觉后坐力: " + string(_data.visual_recoil));
    }
    
    // ============================================================
    // 8. ★ 物理后坐力
    // ============================================================
    if (struct_exists(_data, "physical_recoil") && _data.physical_recoil > 0) {
        var _recoil = _data.physical_recoil;
        var _angle2 = _weapon.base_angle + 180;
        _owner.x += lengthdir_x(_recoil, _angle2);
        _owner.y += lengthdir_y(_recoil, _angle2);
        show_debug_message("💥 物理后坐力: " + string(_recoil));
    }
}


// ============================================================
// 辅助函数：枪口火花粒子
// ============================================================
function scr_muzzle_sparks(_x, _y, _angle) {
    var _layer = "Effects";
    if (!layer_exists(_layer)) {
        _layer = layer_create(-1, _layer);
    }
    
    for (var i = 0; i < 6; i++) {
        var _p = instance_create_layer(_x, _y, _layer, obj_particle);
        if (_p == noone) continue;
        _p.image_blend = c_orange;
        _p.image_xscale = random_range(0.15, 0.4);
        _p.image_yscale = _p.image_xscale;
        var _a = _angle + random_range(-50, 50);
        _p.x_speed = lengthdir_x(random_range(1, 4), _a);
        _p.y_speed = lengthdir_y(random_range(1, 4), _a);
        _p.life = random_range(3, 8);
        _p.max_life = _p.life;
        _p.gravity = 0.06;
        _p.friction = 0.94;
        _p.sprite_index = spr_particle_spark;
    }
    
    for (var i = 0; i < 3; i++) {
        var _p = instance_create_layer(_x, _y, _layer, obj_particle);
        if (_p == noone) continue;
        _p.image_blend = c_yellow;
        _p.image_xscale = random_range(0.1, 0.25);
        _p.image_yscale = _p.image_xscale;
        var _a = _angle + random_range(-25, 25);
        _p.x_speed = lengthdir_x(random_range(2, 5), _a);
        _p.y_speed = lengthdir_y(random_range(2, 5), _a);
        _p.life = random_range(2, 5);
        _p.max_life = _p.life;
        _p.gravity = 0.04;
        _p.friction = 0.95;
        _p.sprite_index = spr_particle_spark;
    }
}