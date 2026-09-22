// data_projectile.gml
global.__projectile_table = undefined;

function data_projectile_get(projectile_id) {
    if (global.__projectile_table == undefined) {
        global.__projectile_table = {
            
            slash: {
                id: "slash",
                object: obj_slash,
                speed: 5,
                life: 999,
                damage: 1,
                scale_start: 0.5,
                scale_end: 2.0,
                scale_frames: 15,
                element_type: "none",
                sprite: spr_slash,
                color: c_aqua,
                max_distance: 500,
                min_distance: 50
            },
            
            // ============================================================
            // 榴弹炮（抛物线 + 爆炸）
            // ============================================================
                        grenade_launcher: {
                id: "grenade_launcher",
                object: obj_grenade_launcher,
                sprite: spr_grenade_launcher,
                
                speed: 8,
                gravity: 0.4,
                life: 300,
                
                // ★ 调大这三个
                explosion_damage: 80,        // 30 → 80
                explosion_radius: 100,       // 64 → 160
                explosion_knockback: 100,     // 8 → 40
                explosion_stun_duration: 0.6,// 0 → 0.3（加硬直）
                explosion_falloff_min: 0.5,  // 0.3 → 0.5（最低衰减提到 50%）
                
                element_type: "fire",
                color: c_white,
                max_distance: 0,
                min_distance: 0
            }
            
        };
    }
    
    return global.__projectile_table[$ projectile_id];
}