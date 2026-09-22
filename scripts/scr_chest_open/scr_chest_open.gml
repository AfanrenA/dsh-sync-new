// ======================================================================
// scr_chest_open(_chest) - 打开宝箱核心逻辑
// ======================================================================
function scr_chest_open(_chest) {
    if (!instance_exists(_chest)) return;
    if (_chest.is_open) return;
    
    // 标记已打开
    _chest.is_open = true;
    
    // ----- 1. 爆炸粒子特效（使用V3粒子系统） -----
    var _data = data_chest_get(_chest.chest_id);
    scr_particle_burst(
        _chest.x, _chest.y,
        _chest.particle_count,
        _chest.glow_color,
        _chest.particle_speed,
        _chest.particle_life,
        6  // 爆发半径
    );
    
    // 额外金色粒子（高级感）
    scr_particle_burst(
        _chest.x, _chest.y,
        _chest.particle_count * 0.3,
        make_color_rgb(255, 215, 0),
        _chest.particle_speed * 0.6,
        _chest.particle_life * 0.8,
        4
    );
    
    // ----- 2. 随机选择武器 -----
    var _pool = _chest.weapon_pool;
    if (array_length(_pool) == 0) {
        // 兜底：如果武器池为空，给一把剑
        _pool = ["w_sword"];
    }
    
    var _weapon_id = _pool[irandom(array_length(_pool) - 1)];
    var _weapon_obj = scr_weapon_get_object_from_id(_weapon_id);
    if (_weapon_obj == noone) {
        show_debug_message("警告: 宝箱无法找到武器对象 '" + string(_weapon_id) + "'");
        instance_destroy(_chest);
        return;
    }
    
    // ----- 3. 创建武器实例 -----
    var _drop_x = _chest.x + lengthdir_x(random_range(20, 50), random(360));
    var _drop_y = _chest.y + lengthdir_y(random_range(20, 50), random(360));
    
    var _weapon = instance_create_layer(_drop_x, _drop_y, "Instances", _weapon_obj);
    if (_weapon != noone) {
        // 设置品质（如果宝箱指定了覆盖品质）
        if (_chest.rarity_override >= 0) {
            _weapon.quality = _chest.rarity_override;
        }
        
        // ----- 调用V3掉落系统 -----
        scr_weapon_drop(_weapon, _drop_x, _drop_y);
    }
    
    // ----- 4. 可选：掉落金币/经验（预留扩展） -----
    // scr_drop_currency(_chest.x, _chest.y, random_range(10, 30));
    
    // ----- 5. 播放开锁音效（预留） -----
    // audio_play_sound(snd_chest_open, 10, false);
    
    // ----- 6. 销毁宝箱（延迟销毁，让粒子先播） -----
    alarm_set(0, 3);  // 3帧后销毁，保证粒子完整爆发
    
    // 注意：glow_sprite 会在父对象销毁时自动清理
}
