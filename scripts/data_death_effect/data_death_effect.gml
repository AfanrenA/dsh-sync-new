// ============================================================
// data_death_effect.gml - 死亡特效配置表
// ============================================================

function data_death_effect_get(_who) {
    static _data = {
        // ---- 玩家 ----
        player: {
            color: c_blue,
            count: 40,
            speed: 6,
            spread: 360,
            size_min: 0.2,
            size_max: 0.9,
            life_min: 20,
            life_max: 40,
            gravity: 0.08,
            sprite: spr_particle_spark,
            explosion: true,
            explosion_radius: 80,
            explosion_count: 20,
            flash_count: 15,
            smoke_count: 8
        },
        
        // ---- 普通敌人 ----
        enemy: {
            color: c_red,
            count: 20,
            speed: 4,
            spread: 360,
            size_min: 0.15,
            size_max: 0.6,
            life_min: 12,
            life_max: 28,
            gravity: 0.08,
            sprite: spr_particle_spark,
            explosion: false,
            explosion_radius: 0,
            explosion_count: 0,
            flash_count: 8,
            smoke_count: 3
        },
        
        // ---- 精英敌人 ----
        elite: {
            color: c_orange,
            count: 35,
            speed: 5,
            spread: 360,
            size_min: 0.2,
            size_max: 0.8,
            life_min: 15,
            life_max: 35,
            gravity: 0.08,
            sprite: spr_particle_spark,
            explosion: true,
            explosion_radius: 60,
            explosion_count: 15,
            flash_count: 12,
            smoke_count: 5
        },
        
        // ---- Boss ----
        boss: {
            color: c_yellow,
            count: 60,
            speed: 7,
            spread: 360,
            size_min: 0.3,
            size_max: 1.2,
            life_min: 25,
            life_max: 50,
            gravity: 0.05,
            sprite: spr_particle_spark,
            explosion: true,
            explosion_radius: 120,
            explosion_count: 25,
            flash_count: 20,
            smoke_count: 10
        },
        
        // ---- 小兵 ----
        minion: {
            color: c_gray,
            count: 12,
            speed: 3,
            spread: 360,
            size_min: 0.1,
            size_max: 0.4,
            life_min: 8,
            life_max: 18,
            gravity: 0.1,
            sprite: spr_particle_spark,
            explosion: false,
            explosion_radius: 0,
            explosion_count: 0,
            flash_count: 4,
            smoke_count: 2
        }
    };
    
    if (!struct_exists(_data, _who)) {
        show_debug_message("⚠️ 死亡特效配置不存在: " + string(_who) + "，使用默认 enemy");
        return _data[$ "enemy"];
    }
    
    return _data[$ _who];
}