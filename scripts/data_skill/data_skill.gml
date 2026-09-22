// data_skill.gml
// 武技数据表 - 所有技能的基础数据
// 返回 struct，通过 data_skill_get(id) 获取

global.__skill_table = undefined;

function data_skill_get(skill_id) {
    if (global.__skill_table == undefined) {
        global.__skill_table = {

// ============================================================
// 剑气斩（melee 武器适用）
// ============================================================
skill_slash_wave: {
    // ----- 基础标识 -----
    id: "skill_slash_wave",
    display_name: "剑气斩",
    description: "蓄力释放剑气波",
    type: "武技",
    slot: "skill",
    compatible_weapon_types: ["melee"],
    object: obj_skill_slash_wave,
    cast_script: "scr_skill_slash_wave",
    
    // ----- 蓄力配置 -----
    min_charge: 0,
    max_charge: 3,
    min_distance: 0,
    
    // ----- ★ 伤害配置（基于武器，不再有 base_damage） -----
    damage_multiplier: 0.7,
    
    // ----- ★ 独立暴击 -----
    can_crit: true,
    crit_chance: 0.15,
    crit_multiplier: 2.0,
    
    // ----- 距离和冷却 -----
    base_distance: 300,
    base_cooldown: 3.0,
    
    // ----- 品质倍率 -----
    quality_damage_mult: [1.0, 1.2, 1.5, 1.8, 2.2, 2.8, 3.5],
    quality_range_mult: [1.0, 1.1, 1.2, 1.4, 1.6, 1.9, 2.2],
    quality_cooldown_mult: [1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4],
    
    // ----- 视觉 -----
    sprite: spr_skill_slash_wave,
    charge_color: "#88CCFF",
    preview_color: "#FF4444",
    rarity: "common",
    
    ai: {
        use_range: 300,
        use_chance: 0.5,
        priority: 1,
        min_charge: 1.0,
        max_charge: 3.0,
        spread_count: 4,
        spread_angle: 20,
        damage_percent: 0.5,
    }
},

// ============================================================
// 蛮牛冲撞（hack 武器适用）
// ============================================================
skill_bull_rush: {
    id: "skill_bull_rush",
    display_name: "蛮牛冲撞",
    description: "蓄力向前冲锋",
    type: "武技",
    slot: "skill",
    compatible_weapon_types: ["hack"],
    object: obj_skill_bull_rush,
    cast_script: "scr_skill_bull_rush",
    
    min_charge: 0,
    max_charge: 3,
    min_distance: 0,
    
    damage_multiplier: 1.0,
    
    can_crit: true,
    crit_chance: 0.1,
    crit_multiplier: 2.0,
    
    base_distance: 500,
    base_cooldown: 4.0,
    
    quality_damage_mult: [1.0, 1.15, 1.4, 1.7, 2.0, 2.5, 3.0],
    quality_range_mult: [1.0, 1.1, 1.2, 1.3, 1.5, 1.7, 2.0],
    quality_cooldown_mult: [1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4],
    
    sprite: spr_skill_bull_rush,
    charge_color: "#FF6644",
    preview_color: "#FF4444",
    rarity: "common",
    
    ai: {
        use_range: 400,
        use_chance: 0.3,
        priority: 1,
        min_charge: 0.5,
        max_charge: 2.0,
    }
},

// ============================================================
// 榴弹炮（ranged 武器适用的附件型武技）
// ============================================================
// ============================================================
// 榴弹炮（ranged 武器适用的附件型武技）
// ============================================================
// ============================================================
// 榴弹炮（ranged 武器适用的附件型武技）
// ============================================================
skill_grenade: {
    // ----- 基础标识 -----
    id: "skill_grenade",
    display_name: "榴弹炮",
    description: "发射抛物线榴弹，接触或落地爆炸",
    type: "附件",
    slot: "skill",
    compatible_weapon_types: ["ranged"],
    object: obj_skill_grenade,
    cast_script: "",
    
    // ----- 冷却与弹药 -----
    base_cooldown: 6.0,
    ammo_max: 2,
    ammo_reload_time: 3.0,
    
    // ----- 品质倍率 -----
    quality_damage_mult: [1.0, 1.2, 1.5, 1.8, 2.2, 2.8, 3.5],
    quality_range_mult: [1.0, 1.1, 1.2, 1.4, 1.6, 1.9, 2.2],
    quality_cooldown_mult: [1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4],
    
    // ----- 武器上的部件视觉（两个形态）-----
    attachment_sprite_loaded: spr_skill_grenade_loaded,
    attachment_sprite_empty:  spr_skill_grenade_empty,
    attachment_mount_x: 18,
    attachment_mount_y: -7,
    
    // ----- 引用飞行物数据 -----
    projectile_id: "grenade_launcher",
    
    // ----- 发射后坐力 -----
    fire_recoil_distance: 120,
    fire_recoil_duration: 25,
    fire_recoil_lock: true,
    
    // ----- 视觉 -----
    sprite: spr_skill_grenade_loaded,
    charge_color: "#FFAA44",
    preview_color: "#FF2222",
    rarity: "common",
    
    ai: {
        use_range: 400,
        use_chance: 0.2,
        priority: 2,
    }
}

        };
    }
    return global.__skill_table[$ skill_id];
}

// ============================================================
// 便捷函数：获取品质加成
// ============================================================
function data_skill_get_quality_mult(skill_id, quality_index, stat_name) {
    var _data = data_skill_get(skill_id);
    if (_data == undefined) return 1.0;
    
    var _arr = _data[$ stat_name];
    if (_arr == undefined) return 1.0;
    
    if (quality_index < 0) quality_index = 0;
    if (quality_index >= array_length(_arr)) quality_index = array_length(_arr) - 1;
    
    return _arr[quality_index];
}