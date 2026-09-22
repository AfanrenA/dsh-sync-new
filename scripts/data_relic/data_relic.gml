// data_relic.gml
// 本命遗物数据表 —— 字段对齐 data_skill / data_agility / data_weapon
// 核心原则：效果全部数据驱动，active_script 指定主动效果脚本名
// 注意：本表只存"本命遗物"（主动、单槽、可拆卸）
//       普通遗物（被动、右上角池）走另一套数据，不要混进来

global.__relic_table = undefined;

function data_relic_get(relic_id) {
    if (global.__relic_table == undefined) {
        global.__relic_table = {

// ============================================================
// 蟹化 —— 化身为蟹，横行为主
// ============================================================
relic_crabification: {
    // ----- 基础标识 -----
    id: "relic_crabification",
    display_name: "蟹化",
    description: "化身为蟹。直线移动迟缓，斜向突进极快；护盾与力量暴涨，出招变慢。",
    slot: "relic",
    type: "本命",
    object: obj_relic_base,

    // ----- 主动配置 -----
    active_script: "scr_relic_crabification",   // ★ 按 R 时执行的脚本名
    cooldown: 60,                                // 冷却（秒）
    duration: 12,                                // 生效持续（秒）

    // ----- 效果参数（全部数据驱动，效果脚本只读不写死） -----
    // 语义约定：
    //   move_line_mult     —— 直线移速倍率（W/S/A/D 单键）
    //   move_diag_mult     —— 斜向移速倍率（WA/WD/SA/SD 双键）
    //   shield_mult        —— 护盾上限与当前值倍率
    //   damage_mult        —— 攻击力倍率
    //   attack_cooldown_mult —— 攻击冷却倍率（>1 = 出招变慢；0.3 攻速 ≈ 3.3333）
    //   agility_cd_mult    —— 身法冷却倍率
    effect: {
        move_line_mult:       0.3,
        move_diag_mult:       3.0,
        shield_mult:          3.0,
        damage_mult:          2.0,
        attack_cooldown_mult: 3.3333,
        agility_cd_mult:      1.0,
    },

    // ----- 品质倍率（只放大"强度"，不放大"持续时间"） -----
    quality_duration_mult: [1.0, 1.1, 1.2, 1.35, 1.5, 1.7, 2.0],
    quality_cooldown_mult: [1.0, 0.95, 0.9, 0.85, 0.8, 0.7, 0.6],

    // ----- 视觉 -----
    sprite: spr_relic_crabification,
    active_color: "#FF6644",

    // ----- 掉落 -----
    rarity_range: [2, 5],
},

// ============================================================
// 雷霆万钧 —— 周身放电 + 身法冷却减半 + 位移留雷
// ============================================================
relic_thunder: {
    // ----- 基础标识 -----
    id: "relic_thunder",
    display_name: "雷霆万钧",
    description: "周身爆发电弧。身法冷却减半，位移身法所过之处留下持续闪电。",
    slot: "relic",
    type: "本命",
    object: obj_relic_base,

    // ----- 主动配置 -----
    active_script: "scr_relic_thunder",
    cooldown: 45,
    duration: 15,

    // ----- 效果参数（雷霆不改属性，只改身法冷却） -----
    effect: {
        move_line_mult:       1.0,
        move_diag_mult:       1.0,
        shield_mult:          1.0,
        damage_mult:          1.0,
        attack_cooldown_mult: 1.0,
        agility_cd_mult:      0.5,     // ★ 身法冷却减半
    },

    // ----- 爆发配置（按 R 瞬间 + 每次闪避各触发一次） -----
    burst: {
        bolt_count:        12,      // 电弧条数
        bolt_range_min:    100,     // 最短蔓延距离
        bolt_range_max:    200,     // 最长蔓延距离
        burst_life:        120,      // 爆发持续帧数（1.5 秒）
        burst_damage:      15,      // 电弧单次伤害
        burst_radius:      18,      // 电弧判定半径
        retrigger_on_dash: true,    // ★ 闪避时再爆发一次
    },

    // ----- 位移留雷配置 -----
    // 注意：密度由 segment_step 控制（像素），不是每帧生成
    // 闪避距离 400 / 40 = 一次闪避生成约 10 个节点
        trail: {
        lightning_enabled: true,
        segment_step:      12,      // ★ 每 12 像素一个点（更密，曲线更平滑）
        node_life_min:     90,      // ★ 1.5 秒
        node_life_max:     150,     // ★ 2.5 秒
        node_damage:       10,
        node_radius:       24,
    },

    // ----- 品质倍率 -----
    quality_duration_mult: [1.0, 1.1, 1.2, 1.35, 1.5, 1.7, 2.0],
    quality_cooldown_mult: [1.0, 0.95, 0.9, 0.85, 0.8, 0.7, 0.6],

    // ----- 视觉 -----
    sprite: spr_relic_thunder,
    active_color: "#66CCFF",

    // ----- 掉落 -----
    rarity_range: [2, 5],
}

        };
    }
    return global.__relic_table[$ relic_id];
}

// ============================================================
// 工具：读品质倍率（对齐 data_skill 的 data_skill_get_quality_mult 写法）
// ============================================================
/// @function data_relic_get_quality_mult(relic_id, quality_index, field_name)
/// @returns {real} 品质倍率，找不到返回 1.0
function data_relic_get_quality_mult(relic_id, quality_index, field_name) {
    var _data = data_relic_get(relic_id);
    if (_data == undefined) return 1.0;
    if (!variable_struct_exists(_data, field_name)) return 1.0;

    var _arr = _data[$ field_name];
    if (!is_array(_arr)) return 1.0;
    if (array_length(_arr) <= 0) return 1.0;

    var _idx = clamp(quality_index, 0, array_length(_arr) - 1);
    return _arr[_idx];
}