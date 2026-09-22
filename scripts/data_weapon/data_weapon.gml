// data_weapon.gml
// 武器数据表 - 所有武器的基础数据
// 返回 struct，通过 data_weapon_get(id) 获取

global.__weapon_table = undefined;

function data_weapon_get(weapon_id) {
    if (global.__weapon_table == undefined) {
        global.__weapon_table = {

// ============================================================
// 铁剑（melee 类型，有剑气）
// ============================================================
sword_basic: {
    // ----- 基础标识 -----
    id: "sword_basic",
    display_name: "铁剑",
    type: "melee",
    object: obj_sword_basic,
    keep_glow_on_pickup: true,
    description: "一把普通的铁剑，锋利但朴素。",
    rarity_range: [1, 3],
    
    attack_behavior: "scr_attack_melee",
    hitbox_behavior: "damage_only",
    can_crit: true,
    crit_chance: 0.5,
    crit_multiplier: 1.5,
    base_damage: 5,
    attack_speed: 1.5,
    attack_range: 80,
    
    slot_type: "main_hand",
    
    hitbox_offset_x: -25,
    hitbox_offset_y: 0,
    
    swing_total_frames: 20,
    swing_angle_range: 120,
    swing_up_frames: 15,
    swing_down_frames: 5,
    swing_up_angle: 90,
    swing_down_angle: -90,
    
    knockback_power: 10.0,
    stun_duration: 0.15,
    hitbox_life: 35,
    
    ai: {
        preferred_range: 300
    }
},

// ============================================================
// 無上巨斧（hack 类型，可抵消飞行物）
// ============================================================
axe: {
    id: "axe",
    display_name: "無上巨斧",
    object: obj_axe,
    type: "hack",
    keep_glow_on_pickup: false,
    description: "可以砍树！",
    rarity_range: [2, 4],
    
    attack_behavior: "scr_attack_hack",
    hitbox_behavior: "destroy_projectiles",
    
    base_damage: 10,
    attack_speed: 2.5,
    attack_range: 40,
    crit_multiplier: 1.5,
    can_crit: true,
    crit_chance: 0.8,
    
    slot_type: "main_hand",
    
    hitbox_offset_x: -25,
    hitbox_offset_y: 0,
    swing_total_frames: 40,
    swing_angle_range: 160,
    swing_up_frames: 25,
    swing_down_frames: 15,
    swing_up_angle: 120,
    swing_down_angle: -120,
    
    knockback_power: 30.0,
    stun_duration: 0.12,
    hitbox_life: 50,
    
    ai: {
        preferred_range: 250
    }
},

// ============================================================
// 脉冲枪（远程武器）
// ============================================================
gun_pulse: {
    id: "gun_pulse",
    display_name: "脉冲枪",
    type: "ranged",
    object: obj_gun_pulse,
    keep_glow_on_pickup: false,
    knockback_power: 8.0,
    stun_duration: 0.1,
    rarity_range: [1, 2],
    description: "知道什么叫高科技吗？",
    attack_behavior: "scr_attack_ranged",
    
    base_damage: 12,
    attack_speed: 0.4,
    attack_range: 400,
    crit_multiplier: 1.8,
    can_crit: true,
    
    // ★ 远程专属
    fire_mode: "auto",
    max_ammo: 5,
    reload_time_per_bullet: 30,
    bullet_object: obj_bullet_pulse,   // ★ 改成 bullet_object
    bullet_speed: 15,
    bullet_life: 600,
    
    visual_recoil: 12,
    physical_recoil: 0,
    fire_point_x: 82,
    fire_point_y: 0,
    
    slot_type: "main_hand",
    
    ai: {
        preferred_range: 350
    }
},

// ============================================================
// 火焰炸弹（投掷武器）
// ============================================================
bomb_fire: {
    id: "bomb_fire",
    display_name: "火焰炸弹",
    type: "thrown",
    keep_glow_on_pickup: false,
    
    rarity_range: [1, 3],
    
    attack_behavior: "scr_attack_thrown",
    
    base_damage: 25,
    attack_speed: 1.2,
    attack_range: 200,
    crit_multiplier: 1.0,
    can_crit: false,
    
    slot_type: "main_hand",
    
    ai: {
        preferred_range: 200
    }
},

// ============================================================
// 电解飞刀（投掷武器）
// ============================================================
knife_electrolyte: {
    id: "knife_electrolyte",
    display_name: "电解飞刀",
    type: "thrown",
    keep_glow_on_pickup: false,
    
    rarity_range: [2, 5],
    
    attack_behavior: "scr_attack_thrown",
    
    base_damage: 15,
    attack_speed: 0.7,
    attack_range: 300,
    crit_multiplier: 2.0,
    can_crit: true,
    
    slot_type: "main_hand",
    
    ai: {
        preferred_range: 280
    }
}

        };
    }
    return global.__weapon_table[$ weapon_id];
}

function data_weapon_get_final_stats(weapon_id, rarity_id) {
    var weapon = data_weapon_get(weapon_id);
    var rarity = data_rarity_get(rarity_id);
    
    var final_stats = {
        base_damage: weapon.base_damage * rarity.stat_multiplier,
        attack_speed: weapon.attack_speed,
        attack_range: weapon.attack_range,
        knockback: (variable_struct_exists(weapon, "knockback_power") ? weapon.knockback_power : 5.0) * rarity.stat_multiplier,
        crit_multiplier: weapon.crit_multiplier + (rarity.tier * 0.1),
        rarity_color: rarity.ui_color,
        rarity_glow: rarity.glow_color,
        vfx_tier: rarity.vfx_tier,
        affix_unlock_tier: rarity.affix_unlock_tier
    };
    
    return final_stats;
}