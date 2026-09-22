// data_player.gml
// 玩家角色数据表
// 返回 struct，通过 data_player_get(id) 获取
global.__player_table = undefined;
function data_player_get(player_id) {
    // 用全局变量做缓存，避免 static 的坑
    if (global.__player_table == undefined) {
        global.__player_table = {
            player_warrior: {
                id: "player_warrior",
				object: obj_player,
                name: "林远",
                type: "player",
                max_hp: 100,
                move_speed: 5,
                base_armor: 5,
                inventory_size: 8,
				inventory_display_size: 24,  // UI 画 24 格
                // 武器槽位（多武器接口）
                weapon_slots: [
                    { slot_type: "main_hand", weapon_id: "", rarity_id: "" },
                    { slot_type: "off_hand", weapon_id: "", rarity_id: "" }
                ],
                max_shield: 20,          // 护盾上限 20 点
                shield_regen_rate: 10,   // 恢复速度 10 点/秒
                shield_regen_delay: 600,  // 受伤后等 600 帧（10秒）才开始恢复
                // 当前激活的武器槽
                active_weapon_slot: 0,
                
                // 受击反馈参数
                hit_flash_duration: 0.1,
                hit_knockback_resist: 0.3,
                hit_stun_duration: 0.15,
                // ===== 新增：碰撞伤害参数 =====
                collision_knockback: 25.0,   // 玩家被撞时的击退力度
                collision_stun: 0.1,        // 玩家被撞时的硬直时间
                // 玩家专属：成长系统占位（阶段2+使用）
                level: 1,
                exp: 0,
                exp_to_next: 100,
                skill_points: 0
            },
            
            player_mage: {
                id: "player_mage",
                name: "前辈",
                type: "player",
                max_hp: 70,
                move_speed: 2.5,
                base_armor: 2,
				inventory_size: 8,
                weapon_slots: [
                    { slot_type: "main_hand", weapon_id: "", rarity_id: "" },
                    { slot_type: "off_hand", weapon_id: "", rarity_id: "" }
                ],
                active_weapon_slot: 0,
                hit_flash_duration: 0.3,
                hit_knockback_resist: 0.1,
                hit_stun_duration: 0.2,
                level: 1,
                exp: 0,
                exp_to_next: 100,
                skill_points: 0
            }
        };
    }
    
    return global.__player_table[$ player_id];
}