// data_weapon.gml（包含数值和逻辑映射）
// ===== 武器数据 =====
// ======================================================================
// data_weapon.gml
// 武器数据配置表 + 逻辑映射表
// 
// 设计原则（V3 数据驱动）：
//   1. 所有武器数据集中管理，修改只需改此文件
//   2. 父对象读取通用字段（name, type, damage, cooldown, quality）
//   3. 子对象按类型读取专属字段（近战/远程/投掷）
//   4. 逻辑映射表决定攻击行为脚本
// ======================================================================


// ======================================================================
// 1. 武器数据表
// ======================================================================
// 字段说明：
//   - name: 显示名称
//   - type: 武器类型（melee / hack / ranged / thrown）
//   - damage: 攻击力
//   - cooldown: 攻击冷却（帧数）
//   - quality_base: 品质基础等级（1-7）
//   - quality_offset: 品质偏移量
//   - swing_*: 挥砍参数（melee/hack 专用）
//   - slash_*: 剑气参数（melee 专用）
//   - bullet_*: 子弹参数（ranged 专用）
//   - throw_*: 投掷参数（thrown 专用）
// ======================================================================

// ======================================================================
// data_weapon.gml
// 武器数据配置表（V3 数据驱动）
// ======================================================================

function data_weapon_get(_id) {
    var _weapons = {
        // 拳头（默认武器）
/* ==============================================================
fist: {
    name: "拳头",
    type: "melee",
    damage: 5,
    cooldown: 15,              // 0.25秒，比剑快
    quality_base: 1,
    quality_offset: 0,
    swing_total_frames: 8,     // 挥拳动画更快
    swing_angle_range: 45,
    swing_distance: 20,
    hitbox_life: 6,
    hitbox_radius: 18,
    can_deflect: false,
    slash_sprite: noone,       // 拳头不发射剑气
    // 预留遗物/技能扩展字段
    fist_knockback: 2,         // 击退力度（遗物可增强）
    fist_stun_chance: 0,       // 眩晕概率（遗物可增加）
    fist_element: "none",      // 元素属性（技能可赋予）
	visible: false
},*/
        // ==============================================================
        // 巨剑（melee）
        // ==============================================================
        sword: {
            name: "红色巨剑",
            type: "melee",
			sprite:spr_changjian,
            damage: 15,
            cooldown: 50,
            quality_base: 7,
            quality_offset: 0,
            hitbox_offset_x: -15,
            swing_total_frames: 15,
            swing_angle_range: 75,
            swing_distance: 55,
            slash_sprite: obj_slash,
            slash_speed: 4,
            slash_life: 50,
            slash_scale_start: 0.4,
            slash_scale_end: 2.5,
            hitbox_life: 12,
            hitbox_radius: 25,
            can_deflect: false
        },
        
        // ==============================================================
        // 無上神斧（hack）
        // ==============================================================
        axe: {
            name: "無上神斧",
            type: "hack",
			sprite:spr_axe,
            damage: 25,
            cooldown: 100,
            quality_base: 4,
            quality_offset: 0,
            hitbox_offset_x: -45,
            swing_total_frames: 12,
            swing_angle_range: 95,
            swing_distance: 125,
            slash_sprite: noone,
            hitbox_life: 18,
            hitbox_radius: 30,
            can_deflect: true
        },
        
        // ==============================================================
        // 能量枪（ranged）
        // ==============================================================
        powergun: {
            name: "能量枪",
            type: "ranged",
			sprite:spr_powergun,
            damage: 8,
            cooldown: 30,
            quality_base: 2,
            quality_offset: 1,
            bullet_sprite: obj_bullet,
            bullet_speed: 12,
            bullet_life: 60,
            visual_recoil: 25,
            physical_recoil: 50,
            fire_point_x: 60,
            fire_point_y: 2,
            burst_max: 5,
            burst_cooldown: 300
        },
       
// 火焰炸弹（thrown）
// ==============================================================
firebomb: {
    name: "火焰炸弹",
    type: "thrown",
	sprite:spr_firebomb,
    damage: 25,
    cooldown: 65,
    quality_base: 6,        // ★ 补上 ★
    quality_offset: 2, 
    // ---- 飞行参数 ----
    throw_speed: 8,
    throw_gravity: 0.15,
    throw_life: 120,
    projectile_obj: obj_thrown_projectile,
    // ---- 爆炸参数 ----
    is_explosive: true,          // ★ 炸弹 = true
    explosion_delay: 30,
    explosion_radius: 120,
    explosion_damage: 40,
    // ---- 预警圈参数 ----
    warning_radius: 120,
    warning_duration: 180,      // 1.5秒
    warning_alpha: 0.6,       // 很淡
    warning_scale_start: 0.3,  // 从30%开始扩大
    // ---- 元素 ----
    element: "fire",
    element_dot_damage: 5,
    element_dot_duration: 90,
    
    // ---- 视觉 ----
    sprite: spr_firebomb,
    trail_sprite: spr_trail_smoke
},

// ==============================================================
// 淬毒飞刃（thrown）
// ==============================================================
dagger: {
    name: "淬毒飞刃",
    type: "thrown",
	sprite:spr_dagger,
    damage: 15,
    cooldown: 20,
    quality_base: 3,
    quality_offset: 0,
    element_damage: 5,
    // ---- 飞行参数 ----
    throw_speed: 14,
    throw_gravity: 0,           // 直线飞行
    throw_life: 120,
    max_range: 600,
    
    // ---- 投射物对象 ----
    projectile_obj: obj_thrown_dagger,
    
    // ---- 流血效果 ----
    bleed_damage: 3,
    bleed_duration: 120,
    bleed_interval: 15,
    
    // ---- 是否穿透 ----
    pierce: false,
    
    // ---- 元素属性 ----
    element: "poison",          // "poison" | "fire" | "ice" | "lightning"
    element_damage: 5,          // 元素附加伤害
    
    // ---- 尾迹颜色 ----
    trail_color: c_lime,        // 毒 = 绿色
    trail_sprite: spr_dagger_trail,
    
    // ---- 视觉 ----
    sprite: spr_dagger,
    hit_effect_obj: obj_hit_effect,
    
    // ---- ★ 留存时间（扎在目标上）★ ----
    stick_duration: 600,        // 10秒 = 600帧
}
    };
    
    return _weapons[$ _id];
}


// ======================================================================
// 2. 武器行为映射表
// ======================================================================
// 根据武器类型返回对应的攻击行为脚本引用
// 所有攻击脚本在 04_Systems_功能系统/ 中定义
// ======================================================================

/*function data_weapon_behavior(_type) {
    var _behaviors = {
        sword: scr_attack_melee,
        axe: scr_attack_hack,
        powergun: scr_attack_ranged,
        firebomb: scr_attack_thrown
    };
    
    // 如果找不到对应的行为，返回 noone（调用方应处理）
    return _behaviors[$ _type] || noone;
}*/