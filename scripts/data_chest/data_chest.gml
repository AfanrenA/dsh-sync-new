// ======================================================================
// data_chest.gml
// 宝箱数据配置表（V3 数据驱动）
// ======================================================================
// 职责：
//   1. 定义所有宝箱类型的数据
//   2. 每种宝箱包含：武器池、辉光颜色、粒子参数、品质覆盖
// ======================================================================

/// @description 根据宝箱ID获取宝箱数据
/// @param {string} _id 宝箱ID（如 "chest_melee"）
/// @returns {struct} 宝箱配置对象
function data_chest_get(_id) {
    
    // ★ 用结构体存储所有宝箱数据 ★
    var _data = {
        // ============================================================
        // 基础宝箱：近战武器池
        // ============================================================
        chest_melee: {
            weapon_pool: ["sword", "axe","powergun","firebomb","dagger"],      // 武器ID列表
            glow_color: c_lime,                 // 辉光颜色
            glow_alpha: 0.15,                   // 辉光透明度
            glow_pulse_speed: 1.5,              // 脉冲速度
            particle_count: 20,                 // 粒子数量
            particle_speed: 6,                  // 粒子速度
            particle_life: 15,                  // 粒子寿命
            rarity_override: -1                 // -1 = 随机品质
        },
        
        // ============================================================
        // 远程宝箱：远程武器池
        // ============================================================
        chest_ranged: {
            weapon_pool: ["powergun"],          // 武器ID列表
            glow_color: c_blue,                 // 辉光颜色
            glow_alpha: 0.18,
            glow_pulse_speed: 1.2,
            particle_count: 25,
            particle_speed: 5,
            particle_life: 18,
            rarity_override: -1
        },
        
        // ============================================================
        // 精英宝箱：高概率出高品质
        // ============================================================
        chest_elite: {
            weapon_pool: ["sword", "axe", "powergun"],
            glow_color: c_fuchsia,
            glow_alpha: 0.25,
            glow_pulse_speed: 0.8,
            particle_count: 40,
            particle_speed: 8,
            particle_life: 25,
            rarity_override: 3                 // 强制紫/橙品质
        }
    };
    
    // ---- 检查宝箱ID是否存在 ----
    if (!struct_exists(_data, _id)) {
        show_debug_message("⚠️ data_chest_get: 未知宝箱ID '" + string(_id) + "'，使用默认 chest_melee");
        return _data[$ "chest_melee"];
    }
    
    // ---- 返回对应宝箱数据 ----
    return _data[$ _id];
}