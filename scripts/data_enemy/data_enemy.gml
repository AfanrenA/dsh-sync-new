function data_enemy_get(id) {
    static enemies = {
        // ============================================================
        // 剑士 - 追击 + 近战
        // ============================================================
        swordsman: {
            label: "剑士",
            hp: 100,
            speed: 2.5,
            weapon_id: "sword",
            weapon_quality_min: "common",
            weapon_quality_max: "rare",
            
            // ===== AI参数 =====
            aggro_range: 550,           // 索敌范围
            attack_range: 400,           // 攻击距离（近战）
            retreat_range: 250,         // 后退距离
            decision_interval: 15,      // 决策间隔（帧）
            behavior_weights: {         // 行为权重（随机决策）
                chase: 50,
                attack: 40,
                retreat: 5,
                idle: 5
            },
            ai_script: "scr_ai_swordsman_decision",
            
            drop_table: "melee_enemy",
            exp_reward: 20,
            who: "enemy"
        },
        
        // ============================================================
        // 机动士兵 - 游击冷枪
        // ============================================================
        soldier: {
            label: "机动士兵",
            hp: 70,
            speed: 3.0,
            weapon_id: "powergun",
            weapon_quality_min: "common",
            weapon_quality_max: "uncommon",
            
            aggro_range: 500,
            attack_range: 350,          // 远程攻击距离
            retreat_range: 200,
            decision_interval: 10,
            behavior_weights: {
                chase: 20,
                attack: 30,
                retreat: 35,            // 喜欢后退
                idle: 15
            },
            ai_script: "scr_ai_soldier_decision",
            
            drop_table: "ranged_enemy",
            exp_reward: 15,
            who: "enemy"
        },
        
        // ============================================================
        // 斧哥 - 不出手则已，一出手毙命
        // ============================================================
        axeman: {
            label: "斧哥",
            hp: 200,
            speed: 1.8,
            weapon_id: "axe",
            weapon_quality_min: "uncommon",
            weapon_quality_max: "epic",
            
            aggro_range: 300,
            attack_range: 70,
            retreat_range: 100,
            decision_interval: 20,      // 决策慢（稳重）
            behavior_weights: {
                chase: 55,
                attack: 40,
                retreat: 3,
                idle: 2
            },
            ai_script: "scr_ai_axeman_decision",
            
            drop_table: "melee_elite",
            exp_reward: 35,
            who: "elite"
        },
        
        // ============================================================
        // 蛮牛子 - 蛮牛冲撞
        // ============================================================
        bull: {
            label: "蛮牛子",
            hp: 350,
            speed: 2.8,
            weapon_id: "heavy_sword",
            weapon_quality_min: "common",
            weapon_quality_max: "rare",
            
            aggro_range: 400,
            attack_range: 65,
            retreat_range: 80,
            decision_interval: 12,
            behavior_weights: {
                chase: 40,
                attack: 25,
                retreat: 5,
                idle: 5,
                skill: 25               // 技能倾向
            },
            skills: ["bull_rush"],
            skill_cooldowns: {
                bull_rush: 300
            },
            ai_script: "scr_ai_bull_decision",
            
            drop_table: "melee_elite",
            exp_reward: 40,
            who: "elite"
        },
        
        // ============================================================
        // 爆炸小子 - 投掷 + 死亡自爆
        // ============================================================
        bomber: {
            label: "爆炸小子",
            hp: 60,
            speed: 3.8,
            weapon_id: "fire_bomb",
            weapon_quality_min: "common",
            weapon_quality_max: "uncommon",
            
            aggro_range: 550,
            attack_range: 400,          // 投掷距离
            retreat_range: 250,
            decision_interval: 8,       // 决策快（机敏）
            behavior_weights: {
                chase: 15,
                attack: 40,
                retreat: 30,
                idle: 5,
                skill: 10
            },
            skills: ["hell_cannon"],
            skill_cooldowns: {
                hell_cannon: 300
            },
            on_death_skill: "big_boom",
            ai_script: "scr_ai_bomber_decision",
            
            drop_table: "ranged_enemy",
            exp_reward: 18,
            who: "enemy"
        },
        
        // ============================================================
        // 飞刀客 - 阴险 + 加速 + 瞬移
        // ============================================================
        blade_master: {
            label: "飞刀客",
            hp: 55,
            speed: 3.2,
            weapon_id: "dagger",
            weapon_quality_min: "common",
            weapon_quality_max: "rare",
            
            aggro_range: 450,
            attack_range: 300,
            retreat_range: 300,
            decision_interval: 8,
            behavior_weights: {
                chase: 10,
                attack: 30,
                retreat: 35,
                idle: 15,
                skill: 10
            },
            skills: ["speed_boost", "blink"],
            skill_cooldowns: {
                speed_boost: 900,
                blink: 1200
            },
            ai_script: "scr_ai_dagger_decision",
            
            drop_table: "ranged_enemy",
            exp_reward: 22,
            who: "enemy"
        }
    };
    return enemies[$ id];
}