// ============================================================
// spawn_death_effect - 死亡特效生成器
// ============================================================

function spawn_death_effect(_inst) {
    if (!instance_exists(_inst)) exit;
    
    var _x = _inst.x;
    var _y = _inst.y;
    
    var _who = "enemy";
    if (variable_instance_exists(_inst, "who")) {
        _who = _inst.who;
    }
    
    var _cfg = data_death_effect_get(_who);
    
    // ---- 1. 爆炸冲击波 ----
    if (_cfg.explosion && _cfg.explosion_radius > 0) {
        spawn_particles(_x, _y, c_white, {
            count: _cfg.explosion_count,
            speed: 6,
            spread: 360,
            life_min: 8,
            life_max: 15,
            size_min: 0.3,
            size_max: 0.8,
            gravity: 0,
            sprite: spr_particle_spark
        });
    }
    
    // ---- 2. 主体粒子 ----
    spawn_particles(_x, _y, _cfg.color, {
        count: _cfg.count,
        speed: _cfg.speed,
        spread: _cfg.spread,
        life_min: _cfg.life_min,
        life_max: _cfg.life_max,
        size_min: _cfg.size_min,
        size_max: _cfg.size_max,
        gravity: _cfg.gravity,
        sprite: spr_particle_spark
    });
    
    // ---- 3. 中心闪光 ----
    spawn_particles(_x, _y, c_white, {
        count: _cfg.flash_count,
        speed: 1.5,
        spread: 60,
        life_min: 3,
        life_max: 8,
        size_min: 0.1,
        size_max: 0.4,
        gravity: 0,
        sprite: spr_particle_spark
    });
    
    // ---- 4. 烟尘 ----
    if (_cfg.smoke_count > 0) {
        spawn_particles(_x, _y, c_gray, {
            count: _cfg.smoke_count,
            speed: 1.5,
            spread: 200,
            life_min: 20,
            life_max: 40,
            size_min: 0.4,
            size_max: 1.2,
            gravity: -0.02,
            sprite: spr_particle_spark
        });
    }
}