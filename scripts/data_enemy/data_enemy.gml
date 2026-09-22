// data_enemy.gml
// 敌人角色数据表 - 所有敌人配置
// 返回 struct，通过 data_enemy_get(id) 获取
global.__enemy_table = undefined;

function data_enemy_get(enemy_id) {
    if (global.__enemy_table == undefined) {
        global.__enemy_table = {

// ============================================================
// 火溶巡逻卫（被动型 - A类型）
// 行为：被动巡逻，好奇，警惕，反击
// ============================================================
enemy_hr_swordsman: {
    // ----- 基础标识 -----
    id: "enemy_hr_swordsman",              // 唯一ID，用于工厂创建和查找
    name: "火溶巡逻卫",                    // 显示名称
    type: "enemy",                         // 类型：enemy / boss / npc
    object: obj_enemy_hr_swordsman,        // 实际对象
    collision_knockback: 25.0,
    // ----- 基础属性 -----
    max_hp: 50,                            // 最大生命值
    move_speed: 2,                         // 移动速度（像素/帧）
    base_armor: 3,                         // 基础护甲（减伤 = armor / (armor + 50)）
    
    // ----- 武器系统 -----
    weapon_slots: [                        // 武器槽位配置
        { slot_type: "main_hand", weapon_id: "sword_basic", rarity_id: "common" }
    ],
    active_weapon_slot: 0,                 // 默认激活的武器槽索引
    
    // ----- 护盾系统 -----
    max_shield: 5,                         // 最大护盾值
    shield_regen_rate: 5,                  // 护盾恢复速度（每帧恢复量）
    shield_regen_delay: 300,               // 受伤后护盾恢复延迟（帧数，300帧=5秒）
    
    // ----- 受击反馈 -----
    hit_flash_duration: 0.3,               // 受击闪白持续时间（秒）
    hit_knockback_resist: 0.5,             // 击退抗性（0=无抗性，1=完全免疫）
    hit_stun_duration: 0.1,                // 受击硬直时间（秒）
    
    // ----- 派系 -----
    faction_id: "faction_huorong",         // 派系ID（影响掉落/抗性/阵营关系）
    
    // ----- 技能配置 -----
    skill_id: "skill_slash_wave",          // 装备的武技ID（留空表示无技能）
    skill_rarity: "common",                // 技能品质
    skill_use_chance: 0.1,                 // 使用概率（0-1，10%概率）
    skill_cooldown: 300,                   // 技能冷却（帧数，300帧=5秒）
    
    // ============================================================
    // ★ AI配置（所有AI参数集中管理）
    // ============================================================
    ai: {
        // ----- 派系身份（决定行为逻辑） -----
        faction: "A",                      // A=防御型 | B=主动攻击型 | C=中立暴怒型 | D=入侵型
        
        // ----- 感知配置（视野和索敌） -----
        vision_angle: 160,                 // 视野角度（度），正面160度锥形
        aggro_range: 800,                  // 索敌范围（像素），超过此距离不追击
        attack_range: 300,                 // 攻击范围（像素），进入此范围开始攻击
        behind_range: 150,                 // 背后触发距离（像素），从背后靠近触发追击
        lost_range: 900,                   // 丢失目标距离（像素），超过此距离放弃追击
        
        // ----- 移动速度 -----
        patrol_speed: 1,                   // 巡逻速度（像素/帧）
        chase_speed: 1.5,                  // 追击速度（像素/帧）
        
        // ----- 距离管理（攻击时保持距离） -----
        ideal_distance: 200,               // 理想保持距离（像素），攻击时尽量保持此距离
        too_close: 80,                     // 贴脸判定距离（像素），低于此值会后退
        too_far: 350,                      // 太远追击距离（像素），高于此值会靠近
        
        // ----- 状态计时（帧数，60帧=1秒） -----
        curious_duration: 120,             // 好奇持续2秒（A类型用）
        alert_trigger_window: 120,         // 警惕触发窗口2秒（A类型用）
        alert_watch_duration: 300,         // 警惕观察5秒（A类型用）
        alert_max_count: 5,                // 累计5次警惕触发反击（A类型用）
        counter_duration: 300,             // 反击持续5秒（A类型用）
        forget_time: 180,                  // 丢失目标忘记时间3秒
        
        // ----- 攻击目标列表（派系敌对关系） -----
        hostiles: ["player", "C", "D", "npc"]  // 攻击目标类型
    }
},

// ============================================================
// 火溶守卫（主动型 - B类型）
// 行为：主动追击，攻击，技能
// ============================================================
enemy_hr_swordsman_a: {
    id: "enemy_hr_swordsman_a",
    name: "火溶守卫",
    type: "enemy",
    object: obj_enemy_hr_swordsman_a,
    collision_knockback: 25.0,
    // ----- 基础属性 -----
    max_hp: 100,
    move_speed: 2,
    base_armor: 3,
    
    // ----- 武器系统 -----
    weapon_slots: [
        { slot_type: "main_hand", weapon_id: "sword_basic", rarity_id: "rare" }
    ],
    active_weapon_slot: 0,
    
    // ----- 护盾系统 -----
    max_shield: 30,
    shield_regen_rate: 5,
    shield_regen_delay: 300,
    
    // ----- 受击反馈 -----
    hit_flash_duration: 0.3,
    hit_knockback_resist: 0.5,
    hit_stun_duration: 0.1,
    
    // ----- 派系 -----
    faction_id: "faction_huorong",
    
    // ----- 技能配置 -----
    skill_id: "skill_slash_wave",
    skill_rarity: "common",
    skill_use_chance: 1,                   // 100%概率使用技能
    skill_cooldown: 300,                   // 5秒冷却
    
    // ============================================================
    // ★ AI配置
    // ============================================================
    ai: {
        faction: "B",                      // 主动攻击型
        
        // ----- 感知配置 -----
        vision_angle: 160,
        aggro_range: 800,
        attack_range: 600,                 // ★ 守卫攻击范围更大（600px）
        behind_range: 200,
        lost_range: 900,
        
        // ----- 移动速度 -----
        patrol_speed: 2,
        chase_speed: 3,                    // ★ 守卫追击更快
        
        // ----- 距离管理 -----
        ideal_distance: 200,
        too_close: 100,
        too_far: 250,
        
        // ----- 状态计时 -----
        curious_duration: 120,
        alert_trigger_window: 120,
        alert_watch_duration: 300,
        alert_max_count: 5,
        counter_duration: 300,
        forget_time: 180,
        
        // ----- 攻击目标 -----
        hostiles: ["player", "C", "D", "npc"]
    }
},

// ============================================================
// 火溶斧卫（主动型 - B类型，装备蛮牛冲撞）
// 行为：主动追击，近战，冲撞技能
// ============================================================
enemy_hr_axesman: {
    id: "enemy_hr_axesman",
    name: "火溶斧卫",
    type: "enemy",
    object: obj_enemy_hr_axesman,
    collision_knockback: 25.0,
    // ----- 基础属性 -----
    max_hp: 100,
    move_speed: 4,
    base_armor: 3,
    
    // ----- 武器系统 -----
    weapon_slots: [
        { slot_type: "main_hand", weapon_id: "axe", rarity_id: "elite" }
    ],
    active_weapon_slot: 0,
    
    // ----- 护盾系统 -----
    max_shield: 40,
    shield_regen_rate: 5,
    shield_regen_delay: 300,
    
    // ----- 受击反馈 -----
    hit_flash_duration: 0.3,
    hit_knockback_resist: 0.5,
    hit_stun_duration: 0.1,
    
    // ----- 派系 -----
    faction_id: "faction_huorong",
    
    // ----- 技能配置 -----
    skill_id: "skill_bull_rush",           // ★ 斧卫装备蛮牛冲撞
    skill_rarity: "rare",
    skill_use_chance: 1,
    skill_cooldown: 480,                   // 8秒冷却
    
    // ============================================================
    // ★ AI配置
    // ============================================================
    ai: {
        faction: "B",
        
        // ----- 感知配置 -----
        vision_angle: 160,
        aggro_range: 800,
        attack_range: 200,                 // ★ 斧卫攻击范围较小（200px）
        behind_range: 100,
        lost_range: 900,
        
        // ----- 移动速度 -----
        patrol_speed: 2,                   // ★ 斧卫巡逻更快
        chase_speed: 2.5,                  // ★ 斧卫追击最快
        
        // ----- 距离管理 -----
        ideal_distance: 150,               // ★ 斧卫保持更近的距离
        too_close: 60,
        too_far: 300,
        
        // ----- 状态计时 -----
        curious_duration: 120,
        alert_trigger_window: 120,
        alert_watch_duration: 300,
        alert_max_count: 5,
        counter_duration: 300,
        forget_time: 180,
        
        // ----- 攻击目标 -----
        hostiles: ["player", "C", "D", "npc"]
    }
},

// ============================================================
// 火溶防卫（远程型 - B类型）
// 行为：远程攻击，保持距离，风筝玩家
// ============================================================
enemy_hr_gunner: {
    id: "enemy_hr_gunner",
    name: "火溶防卫",
    type: "enemy",
    // object: obj_enemy_hr_gunner,        // 注释掉，等创建对象后启用
    
    // ----- 基础属性 -----
    max_hp: 35,
    move_speed: 1.5,
    base_armor: 1,
    
    // ----- 武器系统 -----
    weapon_slots: [
        { slot_type: "main_hand", weapon_id: "gun_pulse", rarity_id: "common" }
    ],
    active_weapon_slot: 0,
    
    // ----- 护盾系统（远程敌人护盾较少） -----
    max_shield: 0,                         // 远程敌人无护盾
    
    // ----- 受击反馈 -----
    hit_flash_duration: 0.8,
    hit_knockback_resist: 0.2,
    hit_stun_duration: 0.12,
    
    // ----- 派系 -----
    faction_id: "faction_huorong",
    
    // ============================================================
    // ★ AI配置
    // ============================================================
    ai: {
        faction: "B",
        
        // ----- 感知配置 -----
        vision_angle: 160,
        aggro_range: 300,
        attack_range: 250,
        behind_range: 125,
        lost_range: 400,
        
        // ----- 移动速度 -----
        patrol_speed: 0.8,
        chase_speed: 1.5,
        
        // ----- 距离管理（远程保持更远距离） -----
        ideal_distance: 250,               // ★ 远程保持250px距离
        too_close: 150,                    // ★ 贴脸判定更宽松
        too_far: 400,
        
        // ----- 状态计时 -----
        curious_duration: 120,
        alert_trigger_window: 120,
        alert_watch_duration: 300,
        alert_max_count: 5,
        counter_duration: 300,
        forget_time: 180,
        
        // ----- 攻击目标 -----
        hostiles: ["player", "C", "D", "npc"]
    }
}

        };  // ← global.__enemy_table 结束
    }
    
    return global.__enemy_table[$ enemy_id];
}