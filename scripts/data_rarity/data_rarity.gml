	// data_rarity.gml
	// 品质数据表 - 所有可装备模块共用
	// 等级 1-7：1=普通 2=稀有 3=精英 4=史诗 5=传说 6=神话 7=神圣
	// 返回 struct，通过 data_rarity_get(id) 获取
	global.__rarity_table = undefined;
	function data_rarity_get(rarity_id) {
	    if (global.__rarity_table == undefined) {
	        global.__rarity_table = {
	            common: {
	                id: "common",
	                name: "普通",
	                tier: 1,
	                stat_multiplier: 1.0,
	                affix_unlock_tier: 0,
	                drop_weight: 100,
	                min_drop_source: 1,
	                max_drop_source: 7,
	                ui_color: "#9E9E9E",
	                glow_color: "#BDBDBD",
	                vfx_tier: 0
	            },
            
	            rare: {
	                id: "rare",
	                name: "稀有",
	                tier: 2,
	                stat_multiplier: 1.15,
	                affix_unlock_tier: 0,
	                drop_weight: 60,
	                min_drop_source: 1,
	                max_drop_source: 7,
	                ui_color: "#4CAF50",
	                glow_color: "#66BB6A",
	                vfx_tier: 1
	            },
            
	            elite: {
	                id: "elite",
	                name: "精英",
	                tier: 3,
	                stat_multiplier: 1.35,
	                affix_unlock_tier: 1,           // 精英开始解锁第一个词条
	                drop_weight: 30,
	                min_drop_source: 2,
	                max_drop_source: 7,
	                ui_color: "#2196F3",
	                glow_color: "#42A5F5",
	                vfx_tier: 2
	            },
            
	            epic: {
	                id: "epic",
	                name: "史诗",
	                tier: 4,
	                stat_multiplier: 1.6,
	                affix_unlock_tier: 2,           // 史诗解锁第二个词条
	                drop_weight: 12,
	                min_drop_source: 3,
	                max_drop_source: 7,
	                ui_color: "#9C27B0",
	                glow_color: "#AB47BC",
	                vfx_tier: 3
	            },
            
	            legendary: {
	                id: "legendary",
	                name: "传说",
	                tier: 5,
	                stat_multiplier: 1.9,
	                affix_unlock_tier: 3,           // 传说解锁第三个词条
	                drop_weight: 5,
	                min_drop_source: 4,
	                max_drop_source: 7,
	                ui_color: "#FF9800",
	                glow_color: "#FFB74D",
	                vfx_tier: 4
	            },
            
	            mythic: {
	                id: "mythic",
	                name: "神话",
	                tier: 6,
	                stat_multiplier: 2.3,
	                affix_unlock_tier: 4,           // 神话解锁第四个词条
	                drop_weight: 2,
	                min_drop_source: 5,
	                max_drop_source: 7,
	                ui_color: "#F44336",
	                glow_color: "#EF5350",
	                vfx_tier: 5
	            },
            
	            divine: {
	                id: "divine",
	                name: "神圣",
	                tier: 7,
	                stat_multiplier: 2.8,
	                affix_unlock_tier: 5,           // 神圣解锁第五个词条
	                drop_weight: 1,
	                min_drop_source: 6,
	                max_drop_source: 7,
	                ui_color: "#FFD700",
	                glow_color: "#FFEA00",
	                vfx_tier: 6
	            }
	        };
	    }
    
	    return global.__rarity_table[$ rarity_id];
	}

	// 便捷函数：根据掉落源等级随机品质
	function data_rarity_roll(source_tier) {
	    var rarities = ["common", "rare", "elite", "epic", "legendary", "mythic", "divine"];
	    var total_weight = 0;
	    var eligible = [];
    
	    for (var i = 0; i < array_length(rarities); i++) {
	        var rarity = data_rarity_get(rarities[i]);
	        if (source_tier >= rarity.min_drop_source && source_tier <= rarity.max_drop_source) {
	            eligible[array_length(eligible)] = rarity;
	            total_weight += rarity.drop_weight;
	        }
	    }
    
	    var roll = random(total_weight);
	    var current = 0;
	    for (var j = 0; j < array_length(eligible); j++) {
	        current += eligible[j].drop_weight;
	        if (roll <= current) {
	            return eligible[j].id;
	        }
	    }
    
	    return eligible[0].id; // 保底返回第一个
	}

	// 兼容函数：等级转品质名称
	function get_quality_name(_level) {
	    var _safe_level = clamp(_level, 1, 7);
    
	    switch (_safe_level) {
	        case 1: return "common";
	        case 2: return "rare";
	        case 3: return "elite";
	        case 4: return "epic";
	        case 5: return "legendary";
	        case 6: return "mythic";
	        case 7: return "divine";
	        default: return "common";
	    }
	}