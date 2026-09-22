// data_faction.gml
// 敌人派系数据表
// 返回 struct，通过 data_faction_get(id) 获取
global.__faction_table = undefined;
function data_faction_get(faction_id) {
    if (global.__faction_table == undefined) {
        global.__faction_table = {
            faction_huorong: {
                id: "faction_huorong",
                name: "火溶家族",
                // 派系特性：对某些伤害类型的抗性/弱点
                damage_type_resist: {
                    physical: 0.1,      // 物理抗性 10%
                    fire: 0.5,         // 火焰弱点 50%（受到更少伤害）
                    ice: 0.3,
                    lightning: 0
                },
                // 掉落相关
                drop_source_tier: 2,    // 掉落源等级（影响品质掉落范围）
                drop_table: [
                    { item_type: "weapon", item_id: "sword_basic", drop_chance: 0.15 },
                    { item_type: "weapon", item_id: "axe", drop_chance: 0.05 }
                ]
            },
            
            faction_jinshan: {
                id: "faction_jinshan",
                name: "金山家族",
                damage_type_resist: {
                    physical: 0.2,
                    fire: 0,
                    ice: 0,
                    lightning: 0
                },
                drop_source_tier: 3,
                drop_table: [
                    { item_type: "weapon", item_id: "gun_pulse", drop_chance: 0.2 },
                    { item_type: "weapon", item_id: "bomb_fire", drop_chance: 0.1 }
                ]
            }
        };
    }
    
    return global.__faction_table[$ faction_id];
}