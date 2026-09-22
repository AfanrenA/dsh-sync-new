

// ============================================================
// 被动遗物数据表（右上角池 / 可叠加 / 流派 Build 核心）
// ============================================================
// ★★ 精灵占位说明（重要）★★
//   sprite 字段暂时写 noone —— 因为对应的 spr_relic_xxx 资源还没建，
//   **直接写精灵名会导致编译失败**（GM 找不到资源名就报错）。
//   用户做好图之后，把下面 5 处的 noone 改成对应精灵名即可：
//       relic_solar_panel        → spr_relic_solar_panel
//       relic_wind_turbine       → spr_relic_wind_turbine
//       relic_overload_capacitor → spr_relic_overload_capacitor
//       relic_kinetic_recovery   → spr_relic_kinetic_recovery
//       relic_overclock_particle → spr_relic_overclock_particle
//   没精灵时 HUD/背包栏会自动画**主题色方块**占位，功能照样可测。
//
// 与主动遗物的区别：
//   主动 = 单槽、按 R 触发、有冷却和持续时间、不可叠加
//   被动 = 池子（多格）、常驻生效、可叠加（同名 count++）、部分不可叠加
//
// ★ 叠加语义：所有"数值型"效果都按 count 线性叠加，公式写在各自的 effect_script 里。
//   stackable = false 的遗物，重复拾取时 **不增加 count**（只提示）。
//
// 字段说明（全部数据驱动，改数值不用改代码）：
//   id / display_name / description   —— 基础标识
//   pool                             —— 池类型，固定 "passive"
//   stackable                        —— 能否叠加
//   max_stack                        —— 叠加上限（0 = 无限）
//   active_script                    —— ★ 生效脚本名（每帧调用，对齐主动遗物的写法）
//   params                           —— ★ 该遗物的所有可调参数（数值全在这）
//   quality_*_mult                   —— 品质倍率（可选）
//   sprite                           —— 图标
//   rarity_range                     —— 掉落品质范围

global.__relic_passive_table = undefined;


function data_relic_passive_get(relic_id) {
    if (global.__relic_passive_table == undefined) {
        global.__relic_passive_table = {

// ============================================================
// 太阳能板 —— 脱战后缓慢回电
// ============================================================
relic_solar_panel: {
    id: "relic_solar_panel",
    display_name: "太阳能板",
    description: "脱离战斗后，将阳光转化为电量，持续恢复。",
    pool: "passive",
    tags: ["续航", "脱战"],

    stackable: true,
    max_stack: 0,                       // 无上限

    // ★ 每帧调用：scr_relic_passive_solar_panel(owner, count, params)
    active_script: "scr_relic_passive_solar_panel",

    params: {
        // 脱战判定门槛（秒）：无攻击 + 无被攻击 + 无敌人锁定
        disengage_seconds: 15,

        // 回血速率：每秒恢复的最大血量百分比（×count 叠加）
        heal_pct_per_sec: 1.5,

        // 起效延迟（秒）：脱战成立后再等这么久才开始回（给"真的安全了"的缓冲）
        warmup_seconds: 0,
    },

    quality_effect_mult: [1.0, 1.15, 1.3, 1.5, 1.7, 2.0, 2.4],

    sprite: spr_relic_solar_panel,
    icon_color: "#FFD54F",
    rarity_range: [1, 5],
},

// ============================================================
// 风力发电机 —— 面朝与移动同向时，按移速回电（★ 不可叠加）
// ============================================================
relic_wind_turbine: {
    id: "relic_wind_turbine",
    display_name: "风力发电机",
    description: "迎风而行。面朝方向与移动方向一致时，移动越快，回复越快。",
    pool: "passive",
    tags: ["续航", "机动"],

    stackable: false,                   // ★ 用户明确：暂不叠加
    max_stack: 1,

    active_script: "scr_relic_passive_wind_turbine",

    params: {
        // "面朝方向与移动方向一致"的夹角容差（度）
        // 判定：|移动方向 - 面朝方向| <= angle_tolerance
        angle_tolerance: 45,

        // 移速基准：当前移速 / speed_reference = 强度系数
        // 例：移速 5、基准 5 → 系数 1.0
        speed_reference: 5.0,

        // 每秒回复的最大血量百分比（在系数 = 1.0 时）
        heal_pct_per_sec: 0.8,

        // 强度系数上限（防止移速暴涨时回血飞天）
        max_speed_factor: 3.0,

        // 必须真的在移动（速度低于这个值不算）
        min_move_speed: 0.1,
    },

    quality_effect_mult: [1.0, 1.15, 1.3, 1.5, 1.7, 2.0, 2.4],

    sprite: spr_relic_wind_turbine,
    icon_color: "#81D4FA",
    rarity_range: [1, 5],
},

// ============================================================
// 过载电容 —— 攻击消耗电量，消耗越多伤害越高（可叠加）
// ============================================================
relic_overload_capacitor: {
    id: "relic_overload_capacitor",
    display_name: "过载电容",
    description: "以电量驱动攻击。每次攻击消耗电量，并按消耗量提升伤害。",
    pool: "passive",
    tags: ["输出", "激进"],

    stackable: true,
    max_stack: 0,

    // ★ 这个遗物不改"每帧状态"，而是在**攻击时**注入：
    //   由 scr_relic_passive_overload_on_attack(owner, count, params) 调用
    active_script: "scr_relic_passive_overload_capacitor",

    params: {
        // 每次攻击消耗的血量（电量）
        hp_cost_per_attack: 1.0,

        // 每消耗 1 点电量 → 伤害加成百分比
        // 例：cost=1, bonus=1.5 → 消耗 1 点血，伤害 +1.5%
        damage_bonus_pct_per_cost: 1.5,

        // ★ 电量低于这个值 → 禁止攻击（0 = 不禁止，纯收益）
        min_hp_to_attack: 0,

        // 消耗量是否随叠加层数增加（false = 只加伤害不加消耗）
        cost_scales_with_stack: false,
    },

    quality_effect_mult: [1.0, 1.15, 1.3, 1.5, 1.7, 2.0, 2.4],

    sprite: spr_relic_overload_capacitor,
    icon_color: "#FF7043",
    rarity_range: [2, 6],
},

// ============================================================
// 动能回收器 —— 被强制位移时回收电量（可叠加）
// ============================================================
relic_kinetic_recovery: {
    id: "relic_kinetic_recovery",
    display_name: "动能回收器",
    description: "将被迫的位移转化为电量。后坐力、击退皆可回收，自主位移无效。",
    pool: "passive",
    tags: ["续航", "挨打"],

    stackable: true,
    max_stack: 0,

    // ★ 由位移系统调用：scr_relic_passive_kinetic_on_shift(owner, dist, count, params)
    active_script: "scr_relic_passive_kinetic_recovery",

    params: {
        // 每回收 1 点电量，需要多少像素的被迫位移
        // ★ 数值调保守：120px = 1 血。一次榴弹后坐力 120px → 回 1 血。
        //   想靠后坐力无限循环，需要堆很多层动能回收（见 DEVLOG 的收支表）。
        pixels_per_hp: 120,

        // 单次事件回收上限（防止一次大击退回满）
        max_hp_per_event: 3,

        // ★ 哪些位移算"被迫"（自主位移如身法闪避明确排除）
        count_knockback:  true,     // 敌人攻击击退
        count_recoil:     true,     // 武器后坐力
        count_dash:       false,    // ★ 身法闪避：不算（用户明确）
        count_rush:       false,    // 蛮牛冲撞等自主位移：不算
    },

    quality_effect_mult: [1.0, 1.15, 1.3, 1.5, 1.7, 2.0, 2.4],

    sprite: spr_relic_kinetic_recovery,
    icon_color: "#4DB6AC",
    rarity_range: [2, 6],
},

// ============================================================
// 超频颗粒 —— 冷却中可扣血强行释放（可叠加）
// ============================================================
relic_overclock_particle: {
    id: "relic_overclock_particle",
    display_name: "超频颗粒",
    description: "无视冷却。技能尚未就绪时，以电量强行超频驱动。",
    pool: "passive",
    tags: ["爆发", "激进"],

    stackable: true,
    max_stack: 0,

    // ★ 由技能入口调用：scr_relic_passive_overclock_can_cast / _pay
    active_script: "scr_relic_passive_overclock_particle",

    params: {
        // 每次强行释放消耗的血量（电量）
        // ★ 保守值：8 血/次。对比动能回收"120px 回 1 血"，
        //   1 层动能要 ~8 次后坐力才够放 1 次超频；堆到 ~8 层才接近自循环。
        //   （用户要的"叠加多了能一直用" —— 这就是那条曲线）
        hp_cost: 8,

        // ★ 消耗是否随叠加层数递减（层数越多越便宜，鼓励堆叠）
        //   false = 固定消耗；true = 消耗 / count
        cost_div_by_stack: false,

        // 消耗下限（防止层数高了变成 0 消耗）
        min_hp_cost: 1,

        // ★ 电量不足这个值 → 不能强放（防自杀）
        //   必须 > hp_cost，否则会出现"扣完必死"→ 永远放不出
        min_hp_required: 12,

        // 允许强放的技能类型（"skill" = 武技右键）
        allow_skill: true,
        allow_agility: false,

        // ★ 附件型武技（榴弹炮）取"补一发弹药"路线，不动装填进度
        //   true  = 允许扣血补弹
        //   false = 附件型不触发超频
        allow_attachment_refill: true,
    },

    quality_effect_mult: [1.0, 1.15, 1.3, 1.5, 1.7, 2.0, 2.4],

    sprite: spr_relic_overclock_particle,
    icon_color: "#BA68C8",
    rarity_range: [3, 7],
}

        };
    }
    return global.__relic_passive_table[$ relic_id];
}

// ============================================================
// 工具：被动遗物的品质倍率（写法对齐 data_relic_get_quality_mult）
// ============================================================
/// @function data_relic_passive_get_quality_mult(relic_id, quality_index)
/// @returns {real} 品质效果倍率，找不到返回 1.0
function data_relic_passive_get_quality_mult(relic_id, quality_index) {
    var _data = data_relic_passive_get(relic_id);
    if (_data == undefined) return 1.0;
    if (!variable_struct_exists(_data, "quality_effect_mult")) return 1.0;

    var _arr = _data.quality_effect_mult;
    if (!is_array(_arr) || array_length(_arr) <= 0) return 1.0;

    var _idx = clamp(quality_index, 0, array_length(_arr) - 1);
    return _arr[_idx];
}

/// @function data_relic_passive_is_stackable(relic_id)
/// @returns {bool}
function data_relic_passive_is_stackable(relic_id) {
    var _data = data_relic_passive_get(relic_id);
    if (_data == undefined) return false;
    if (!variable_struct_exists(_data, "stackable")) return false;
    return _data.stackable;
}

/// @function data_relic_passive_get_max_stack(relic_id)
/// @returns {real} 0 = 无上限
function data_relic_passive_get_max_stack(relic_id) {
    var _data = data_relic_passive_get(relic_id);
    if (_data == undefined) return 0;
    if (!variable_struct_exists(_data, "max_stack")) return 0;
    return _data.max_stack;
}