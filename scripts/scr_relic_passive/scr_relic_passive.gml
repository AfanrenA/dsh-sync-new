// scr_relic_passive.gml
// ============================================================
// 被动遗物系统（右上角池 / 可叠加 / 流派 Build 核心）
// ============================================================
// 架构（遵循项目核心宗旨）：
//   1. 数据驱动 —— 所有数值在 data_relic_passive 里，本文件只读不算死数
//   2. 模块化     —— 每个遗物的效果是独立脚本，由 active_script 指定
//   3. 工厂模式   —— 池子条目统一由 scr_relic_passive_add 创建
//   4. 插槽化     —— 与武器/武技/身法/主动遗物共享 owner 概念
//   5. 行为与对象分离 —— 遗物不建对象，纯数据 struct
//
// ★ 存储形态（用户定案）：
//     owner.relic_pool = [ { id, count, quality_index, rarity }, ... ]
//   不建实例。理由：屏幕外/背包里的遗物没有"存在感"，
//   拾取时就直接转成数据，卸载/存档都简单。

// ============================================================
// 一、存储层（增 / 查 / 删 / 数）
// ============================================================

/// @function scr_relic_passive_init(owner)
/// @description 初始化被动遗物池（幂等，重复调用不会清空已有数据）
function scr_relic_passive_init(owner) {
    if (!instance_exists(owner)) return;
    if (!variable_instance_exists(owner, "relic_pool")) {
        owner.relic_pool = [];
    }
    if (!variable_instance_exists(owner, "passive_relic_slots")) {
        owner.passive_relic_slots = 4;      // ★ 初始 4 格（用户定案）
    }
    if (!variable_instance_exists(owner, "passive_relic_slots_unlocked")) {
        owner.passive_relic_slots_unlocked = 4;
    }
    // 战斗状态追踪（脱战判定用）
    if (!variable_instance_exists(owner, "combat_last_action_timer")) {
        owner.combat_last_action_timer = 0;
    }
}

/// @function scr_relic_passive_find_index(owner, relic_id)
/// @returns {real} 池中下标，-1 = 没有
function scr_relic_passive_find_index(owner, relic_id) {
    if (!instance_exists(owner)) return -1;
    if (!variable_instance_exists(owner, "relic_pool")) return -1;

    var _pool = owner.relic_pool;
    for (var i = 0; i < array_length(_pool); i++) {
        if (_pool[i] == undefined) continue;
        if (_pool[i].id == relic_id) return i;
    }
    return -1;
}

/// @function scr_relic_passive_get_count(owner, relic_id)
/// @returns {real} 该遗物持有层数（0 = 没有）
function scr_relic_passive_get_count(owner, relic_id) {
    var _idx = scr_relic_passive_find_index(owner, relic_id);
    if (_idx < 0) return 0;
    return owner.relic_pool[_idx].count;
}

/// @function scr_relic_passive_has(owner, relic_id)
/// @returns {bool}
function scr_relic_passive_has(owner, relic_id) {
    return (scr_relic_passive_get_count(owner, relic_id) > 0);
}

/// @function scr_relic_passive_is_full(owner)
/// @returns {bool} 池子已满（且没有可叠加的同类遗物）
function scr_relic_passive_is_full(owner, relic_id = "") {
    scr_relic_passive_init(owner);

    // ★ 已有同类且可叠加 → 不算满（叠加不占新格子）
    if (relic_id != "") {
        var _idx = scr_relic_passive_find_index(owner, relic_id);
        if (_idx >= 0 && data_relic_passive_is_stackable(relic_id)) {
            var _max = data_relic_passive_get_max_stack(relic_id);
            var _cur = owner.relic_pool[_idx].count;
            if (_max <= 0 || _cur < _max) return false;   // 还能叠
        }
    }

    return (array_length(owner.relic_pool) >= owner.passive_relic_slots_unlocked);
}

/// @function scr_relic_passive_add(owner, relic_id, rarity, quality_index)
/// @description 加入被动遗物（自动处理叠加 / 满格 / 不可叠加）
/// @returns {string} 结果："added" | "stacked" | "full" | "max_stack" | "invalid"
function scr_relic_passive_add(owner, relic_id, rarity = "common", quality_index = 0) {
    if (!instance_exists(owner)) return "invalid";

    var _data = data_relic_passive_get(relic_id);
    if (_data == undefined) {
        show_debug_message("[被动遗物] 数据不存在: " + string(relic_id));
        return "invalid";
    }

    scr_relic_passive_init(owner);

    var _idx = scr_relic_passive_find_index(owner, relic_id);

    // ===== 已有同类 =====
    if (_idx >= 0) {
        if (!data_relic_passive_is_stackable(relic_id)) {
            return "max_stack";                 // 不可叠加
        }
        var _max = data_relic_passive_get_max_stack(relic_id);
        if (_max > 0 && owner.relic_pool[_idx].count >= _max) {
            return "max_stack";                 // 到叠加上限
        }
        owner.relic_pool[_idx].count += 1;
        show_debug_message("[被动遗物] 叠加: " + relic_id + " ×" + string(owner.relic_pool[_idx].count));
        return "stacked";
    }

    // ===== 新遗物：检查格子 =====
    if (array_length(owner.relic_pool) >= owner.passive_relic_slots_unlocked) {
        return "full";
    }

    array_push(owner.relic_pool, {
        id: relic_id,
        count: 1,
        rarity: rarity,
        quality_index: quality_index,
    });

    show_debug_message("[被动遗物] 获得: " + relic_id + " (" + string(rarity) + ")");
    return "added";
}

/// @function scr_relic_passive_remove(owner, relic_id, remove_all)
/// @description 移除被动遗物（默认整条移除；remove_all=false 则只减一层）
/// @returns {bool}
function scr_relic_passive_remove(owner, relic_id, remove_all = true) {
    var _idx = scr_relic_passive_find_index(owner, relic_id);
    if (_idx < 0) return false;

    if (remove_all || owner.relic_pool[_idx].count <= 1) {
        array_delete(owner.relic_pool, _idx, 1);
    } else {
        owner.relic_pool[_idx].count -= 1;
    }
    return true;
}

/// @function scr_relic_passive_total_stacks(owner)
/// @returns {real} 所有被动遗物的总层数（UI 显示用）
function scr_relic_passive_total_stacks(owner) {
    if (!instance_exists(owner)) return 0;
    if (!variable_instance_exists(owner, "relic_pool")) return 0;
    var _n = 0;
    for (var i = 0; i < array_length(owner.relic_pool); i++) {
        _n += owner.relic_pool[i].count;
    }
    return _n;
}

// ============================================================
// 二、战斗状态追踪（脱战判定）
// ============================================================
// 脱战定义（用户定案）：
//   15 秒内 没攻击 + 没被攻击 + 身上没有被敌人锁定（仇恨）

/// @function scr_combat_mark_action(owner)
/// @description 标记"发生了战斗行为"（攻击/被攻击时调用）
function scr_combat_mark_action(owner) {
    if (!instance_exists(owner)) return;
    scr_relic_passive_init(owner);
    owner.combat_last_action_timer = 0;
}

/// @function scr_combat_update(owner)
/// @description 每帧推进战斗计时（角色 Step 调用）
function scr_combat_update(owner) {
    if (!instance_exists(owner)) return;
    scr_relic_passive_init(owner);
    owner.combat_last_action_timer += 1;
}

/// @function scr_combat_has_threat(owner)
/// @description 是否有敌人正锁定该角色（仇恨）
/// @returns {bool}
function scr_combat_has_threat(owner) {
    if (!instance_exists(owner)) return false;

    // 敌人侧：_aggro_target == owner 且 _aggro_timer > 0
    var _enemies = instance_number(obj_enemy_base);
    for (var i = 0; i < _enemies; i++) {
        var _e = instance_find(obj_enemy_base, i);
        if (!instance_exists(_e)) continue;
        if (!variable_instance_exists(_e, "_aggro_timer")) continue;
        if (_e._aggro_timer <= 0) continue;
        if (!variable_instance_exists(_e, "_aggro_target")) continue;
        if (_e._aggro_target == owner) return true;
    }
    return false;
}

/// @function scr_combat_is_disengaged(owner, seconds)
/// @description 是否已脱战（持续 seconds 秒满足全部条件）
/// @param {real} seconds 脱战门槛（秒）
/// @returns {bool}
function scr_combat_is_disengaged(owner, seconds = 15) {
    if (!instance_exists(owner)) return false;
    scr_relic_passive_init(owner);

    // 条件 1+2：无攻击、无被攻击（计时器累计够久）
    if (owner.combat_last_action_timer < seconds * 60) return false;

    // 条件 3：没有敌人锁定
    if (scr_combat_has_threat(owner)) return false;

    return true;
}

// ============================================================
// 三、数值应用工具
// ============================================================

/// @function scr_relic_passive_heal(owner, amount)
/// @description 给 owner 回血（电量），★ 不超过 max_hp
/// @returns {real} 实际回复量
function scr_relic_passive_heal(owner, amount) {
    if (!instance_exists(owner)) return 0;
    if (amount <= 0) return 0;
    if (!variable_instance_exists(owner, "hp")) return 0;
    if (!variable_instance_exists(owner, "max_hp")) return 0;
    if (!owner.is_alive) return 0;

    var _before = owner.hp;
    owner.hp = min(owner.hp + amount, owner.max_hp);
    return (owner.hp - _before);
}

/// @function scr_relic_passive_collect_counts(owner)
/// @description 收集"当前拥有的被动遗物 → 层数"映射，供各效果脚本查询
/// @returns {struct} { relic_id: count, ... }
function scr_relic_passive_collect_counts(owner) {
    var _map = {};
    if (!instance_exists(owner)) return _map;
    if (!variable_instance_exists(owner, "relic_pool")) return _map;

    for (var i = 0; i < array_length(owner.relic_pool); i++) {
        var _e = owner.relic_pool[i];
        if (_e == undefined) continue;
        _map[$ _e.id] = _e.count;
    }
    return _map;
}

// ============================================================
// 四、每帧总入口（★ 角色 Step 只需调这一个）
// ============================================================

/// @function scr_relic_passive_update(owner)
/// @description 驱动所有已持有的被动遗物（每帧调用一次）
function scr_relic_passive_update(owner) {
    if (!instance_exists(owner)) return;
    if (!owner.is_alive) return;

    scr_relic_passive_init(owner);
    scr_combat_update(owner);

    // ★ 超频"放行证"超时作废（防止买了不打、通行证永久挂着）
    if (variable_instance_exists(owner, "_oc_ready_shot_timer")) {
        if (owner._oc_ready_shot_timer > 0) {
            owner._oc_ready_shot_timer -= 1;
            if (owner._oc_ready_shot_timer <= 0) {
                owner._oc_ready_shot = false;
                owner._oc_ready_shot_timer = 0;
            }
        }
    }

    var _pool = owner.relic_pool;
    for (var i = 0; i < array_length(_pool); i++) {
        var _entry = _pool[i];
        if (_entry == undefined) continue;

        var _data = data_relic_passive_get(_entry.id);
        if (_data == undefined) continue;
        if (!variable_struct_exists(_data, "active_script")) continue;
        if (_data.active_script == "") continue;

        var _script = asset_get_index(_data.active_script);
        if (_script == -1) {
            show_debug_message("[被动遗物] 脚本不存在: " + string(_data.active_script));
            continue;
        }

        // 传参：owner, count, params, quality_index
        var _params = variable_struct_exists(_data, "params") ? _data.params : {};
        var _qi = variable_struct_exists(_entry, "quality_index") ? _entry.quality_index : 0;
        script_execute(_script, owner, _entry.count, _params, _qi);
    }
}

// ============================================================
// 五、五个遗物的效果脚本
// ============================================================
// 统一签名：function xxx(owner, count, params, quality_index)
//   count = 叠加层数，params = 数据表里的参数 struct
// ★ 所有数值都从 params 读，代码里不写死任何一个数字

// ------------------------------------------------------------
// 太阳能板：脱战后缓慢回电
// ------------------------------------------------------------
/// @function scr_relic_passive_solar_panel(owner, count, params, qi)
function scr_relic_passive_solar_panel(owner, count, params, qi) {
    if (!instance_exists(owner)) return;

    var _disengage_sec = variable_struct_exists(params, "disengage_seconds") ? params.disengage_seconds : 15;
    var _warmup_sec    = variable_struct_exists(params, "warmup_seconds") ? params.warmup_seconds : 0;

    // 脱战判定（含"无仇恨"）
    if (!scr_combat_is_disengaged(owner, _disengage_sec + _warmup_sec)) return;

    var _pct = variable_struct_exists(params, "heal_pct_per_sec") ? params.heal_pct_per_sec : 1.5;
    var _qmult = data_relic_passive_get_quality_mult("relic_solar_panel", qi);

    // 每秒回复 = max_hp × pct% × count × 品质倍率  → 换算成每帧
    var _per_frame = owner.max_hp * (_pct / 100) * count * _qmult / 60;

    // 累积小数，避免每帧 0.0x 被舍掉（否则永远回不了血）
    if (!variable_instance_exists(owner, "_solar_accum")) owner._solar_accum = 0;
    owner._solar_accum += _per_frame;

    if (owner._solar_accum >= 0.05) {
        var _healed = scr_relic_passive_heal(owner, owner._solar_accum);
        owner._solar_accum = 0;
    }
}

// ------------------------------------------------------------
// 风力发电机：面朝与移动同向 → 按移速回电（不可叠加）
// ------------------------------------------------------------
/// @function scr_relic_passive_wind_turbine(owner, count, params, qi)
function scr_relic_passive_wind_turbine(owner, count, params, qi) {
    if (!instance_exists(owner)) return;

    var _tol        = variable_struct_exists(params, "angle_tolerance") ? params.angle_tolerance : 45;
    var _speed_ref  = variable_struct_exists(params, "speed_reference") ? params.speed_reference : 5.0;
    var _max_factor = variable_struct_exists(params, "max_speed_factor") ? params.max_speed_factor : 3.0;
    var _min_speed  = variable_struct_exists(params, "min_move_speed") ? params.min_move_speed : 0.1;
    var _pct        = variable_struct_exists(params, "heal_pct_per_sec") ? params.heal_pct_per_sec : 0.8;

    if (_speed_ref <= 0) _speed_ref = 1;

    // ===== 1. 必须真的在移动 =====
    // ★ 用"本帧实际位移"判断，比读输入更可靠（敌人推、墙挡都算得准）
    if (!variable_instance_exists(owner, "_wt_last_x")) {
        owner._wt_last_x = owner.x;
        owner._wt_last_y = owner.y;
        return;
    }
    var _dx = owner.x - owner._wt_last_x;
    var _dy = owner.y - owner._wt_last_y;
    owner._wt_last_x = owner.x;
    owner._wt_last_y = owner.y;

    var _moved = point_distance(0, 0, _dx, _dy);
    if (_moved < _min_speed) return;

    // ===== 2. 面朝方向 = 鼠标方向（用户定案）=====
    var _facing = point_direction(owner.x, owner.y, mouse_x, mouse_y);

    // ===== 3. 移动方向 =====
    var _move_dir = point_direction(0, 0, _dx, _dy);

    // ===== 4. 夹角判定（处理 360 环绕）=====
    var _diff = abs(angle_difference(_facing, _move_dir));   // 返回 -180~180
    if (abs(_diff) > _tol) return;

    // ===== 5. 强度系数 = 移速 / 基准（有上限）=====
    var _speed = variable_instance_exists(owner, "move_speed") ? owner.move_speed : 5;
    var _factor = clamp(_speed / _speed_ref, 0, _max_factor);

    var _qmult = data_relic_passive_get_quality_mult("relic_wind_turbine", qi);
    var _per_frame = owner.max_hp * (_pct / 100) * _factor * _qmult / 60;

    if (!variable_instance_exists(owner, "_wt_accum")) owner._wt_accum = 0;
    owner._wt_accum += _per_frame;
    if (owner._wt_accum >= 0.05) {
        scr_relic_passive_heal(owner, owner._wt_accum);
        owner._wt_accum = 0;
    }
}

// ------------------------------------------------------------
// 过载电容：攻击时消耗电量换伤害（可叠加）
// ------------------------------------------------------------
// ★ 这个遗物不改每帧状态，而是**攻击时注入**。
//   active_script 保留（数据表统一），但每帧不做任何事。
/// @function scr_relic_passive_overload_capacitor(owner, count, params, qi)
function scr_relic_passive_overload_capacitor(owner, count, params, qi) {
    // 每帧无事可做 —— 实际逻辑在 scr_relic_passive_overload_on_attack()
}

/// @function scr_relic_passive_overload_on_attack(owner)
/// @description ★ 攻击时调用：判断能否攻击 + 扣电 + 返回伤害加成倍率
/// @returns {struct} { allowed: bool, damage_mult: real, cost: real }
function scr_relic_passive_overload_on_attack(owner) {
    var _result = { allowed: true, damage_mult: 1.0, cost: 0 };
    if (!instance_exists(owner)) return _result;

    var _count = scr_relic_passive_get_count(owner, "relic_overload_capacitor");
    if (_count <= 0) return _result;

    var _data = data_relic_passive_get("relic_overload_capacitor");
    if (_data == undefined) return _result;
    var _params = _data.params;

    var _base_cost = variable_struct_exists(_params, "hp_cost_per_attack") ? _params.hp_cost_per_attack : 1.0;
    var _bonus_pct = variable_struct_exists(_params, "damage_bonus_pct_per_cost") ? _params.damage_bonus_pct_per_cost : 1.5;
    var _min_hp    = variable_struct_exists(_params, "min_hp_to_attack") ? _params.min_hp_to_attack : 0;
    var _cost_scale = variable_struct_exists(_params, "cost_scales_with_stack") ? _params.cost_scales_with_stack : false;

    // 品质索引（从池里取）
    var _qi = 0;
    var _idx = scr_relic_passive_find_index(owner, "relic_overload_capacitor");
    if (_idx >= 0) _qi = owner.relic_pool[_idx].quality_index;
    var _qmult = data_relic_passive_get_quality_mult("relic_overload_capacitor", _qi);

    // ★ 消耗：默认固定；也可随层数增加
    var _cost = _cost_scale ? (_base_cost * _count) : _base_cost;

    // ★ 电量不足 → 禁止攻击
    if (_min_hp > 0 && owner.hp <= _min_hp) {
        _result.allowed = false;
        return _result;
    }
    // 扣了会死也不允许（电量归零会死）
    if (owner.hp - _cost <= 0) {
        _result.allowed = false;
        return _result;
    }

    // ===== 扣电 =====
    owner.hp -= _cost;
    scr_combat_mark_action(owner);      // 攻击算战斗行为

    // ===== 伤害加成 = 消耗 × 每点加成% × 层数 × 品质 =====
    var _bonus = (_cost * _bonus_pct / 100) * _count * _qmult;
    _result.cost = _cost;
    _result.damage_mult = 1.0 + _bonus;
    return _result;
}

// ------------------------------------------------------------
// 动能回收器：被迫位移 → 回收电量（可叠加）
// ------------------------------------------------------------
/// @function scr_relic_passive_kinetic_recovery(owner, count, params, qi)
function scr_relic_passive_kinetic_recovery(owner, count, params, qi) {
    // 每帧无事可做 —— 实际逻辑在 scr_relic_passive_kinetic_on_shift()
}

/// @function scr_relic_passive_kinetic_on_shift(owner, distance, source)
/// @description ★ 发生位移时调用（只统计"被迫"位移）
/// @param {string} source "knockback" | "recoil" | "dash" | "rush" | "other"
/// @param {real} event_id 事件标识（可选）。同一次连续位移用同一个 id，
///                         不同次（如两次挨打）用不同 id → 自动重置额度。
///                         不传则退回"按 source 变化重置"的弱判定。
/// @returns {real} 实际回收的电量
function scr_relic_passive_kinetic_on_shift(owner, distance, source = "other", event_id = undefined) {
    if (!instance_exists(owner)) return 0;
    if (distance <= 0) return 0;

    var _count = scr_relic_passive_get_count(owner, "relic_kinetic_recovery");
    if (_count <= 0) return 0;

    var _data = data_relic_passive_get("relic_kinetic_recovery");
    if (_data == undefined) return 0;
    var _params = _data.params;

    // ★ 按来源过滤：自主位移不算（身法闪避明确排除）
    if (source == "knockback" && !(variable_struct_exists(_params, "count_knockback") && _params.count_knockback)) return 0;
    if (source == "recoil"    && !(variable_struct_exists(_params, "count_recoil") && _params.count_recoil)) return 0;
    if (source == "dash"      && !(variable_struct_exists(_params, "count_dash") && _params.count_dash)) return 0;
    if (source == "rush"      && !(variable_struct_exists(_params, "count_rush") && _params.count_rush)) return 0;

    var _per_hp  = variable_struct_exists(_params, "pixels_per_hp") ? _params.pixels_per_hp : 120;
    var _max_evt = variable_struct_exists(_params, "max_hp_per_event") ? _params.max_hp_per_event : 5;
    if (_per_hp <= 0) _per_hp = 1;

    var _qi = 0;
    var _idx = scr_relic_passive_find_index(owner, "relic_kinetic_recovery");
    if (_idx >= 0) _qi = owner.relic_pool[_idx].quality_index;
    var _qmult = data_relic_passive_get_quality_mult("relic_kinetic_recovery", _qi);

    // ★★ 关键修正：一次位移"事件"必须整体结算，不能逐帧各算一次。
    //   原因：后坐力是**逐帧**推进的（榴弹 120px / 25 帧 = 4.8px/帧），
    //   如果每帧都当成独立事件，max_hp_per_event 上限会被绕过 25 倍
    //   （设计意图"单次最多回 5 血"实际变成 125 血）。
    //
    //   做法：把位移**累积**，按 per_hp 换算应得血量，只在**上限内**发放；
    //   同一次连续位移复用同一个 event_id，事件结束（id 变了）就重新计额度。
    if (!variable_instance_exists(owner, "_kinetic_pending_dist")) {
        owner._kinetic_pending_dist = 0;
        owner._kinetic_paid_hp = 0;
        owner._kinetic_event_id = undefined;
    }

    // ★ 事件切换判定：
    //   显式传了 event_id → 按 id 比较（最准，推荐）
    //   没传 → 退回"按 source 变化"（同 source 连续多次击退会共用额度，属于已知弱点）
    var _is_new_event = false;
    if (event_id != undefined) {
        _is_new_event = (owner._kinetic_event_id == undefined) || (owner._kinetic_event_id != event_id);
        if (_is_new_event) owner._kinetic_event_id = event_id;
    } else {
        if (!variable_instance_exists(owner, "_kinetic_last_source")) {
            owner._kinetic_last_source = source;
            _is_new_event = true;
        } else if (owner._kinetic_last_source != source) {
            owner._kinetic_last_source = source;
            _is_new_event = true;
        }
    }

    if (_is_new_event) {
        owner._kinetic_pending_dist = 0;
        owner._kinetic_paid_hp = 0;
    }

    owner._kinetic_pending_dist += distance;

    // 本事件"理论上应得"的血量（受上限约束）
    var _earned = (owner._kinetic_pending_dist / _per_hp) * _count * _qmult;
    _earned = min(_earned, _max_evt);

    // 本次能发放 = 应得 - 已发放（只增不减，绝不回收）
    var _gain = _earned - owner._kinetic_paid_hp;
    if (_gain <= 0) return 0;

    var _healed = scr_relic_passive_heal(owner, _gain);
    // ★ 记账用"发放量"而不是"实际回血量"：
    //   血量满时 heal 返回 0，但那部分额度不该攒着以后白送。
    owner._kinetic_paid_hp += _gain;

    return _healed;
}

/// @function scr_relic_passive_kinetic_reset_event(owner)
/// @description 手动结束"被迫位移事件"（例如后坐力计时器归零时调用）
/// @note 不调也能工作（事件 id 变了会自动重置），但显式调用语义更清晰
function scr_relic_passive_kinetic_reset_event(owner) {
    if (!instance_exists(owner)) return;
    owner._kinetic_pending_dist = 0;
    owner._kinetic_paid_hp = 0;
    owner._kinetic_event_id = undefined;
    owner._kinetic_last_source = "";
}

// ------------------------------------------------------------
// 超频颗粒：冷却中扣血强行释放（可叠加）
// ------------------------------------------------------------
/// @function scr_relic_passive_overclock_particle(owner, count, params, qi)
function scr_relic_passive_overclock_particle(owner, count, params, qi) {
    // 每帧无事可做 —— 实际逻辑在下面两个函数
}

/// @function scr_relic_passive_overclock_can_pay(owner, kind)
/// @description ★ 检查能否扣血强放（先检查、能放才扣 —— 用户定案）
/// @param {string} kind "skill" | "agility"
/// @returns {struct} { can: bool, cost: real }
function scr_relic_passive_overclock_can_pay(owner, kind = "skill") {
    var _res = { can: false, cost: 0 };
    if (!instance_exists(owner)) return _res;

    var _count = scr_relic_passive_get_count(owner, "relic_overclock_particle");
    if (_count <= 0) return _res;

    var _data = data_relic_passive_get("relic_overclock_particle");
    if (_data == undefined) return _res;
    var _params = _data.params;

    // 类型开关
    if (kind == "skill"   && !(variable_struct_exists(_params, "allow_skill")   && _params.allow_skill))   return _res;
    if (kind == "agility" && !(variable_struct_exists(_params, "allow_agility") && _params.allow_agility)) return _res;

    var _base    = variable_struct_exists(_params, "hp_cost") ? _params.hp_cost : 8;
    var _div     = variable_struct_exists(_params, "cost_div_by_stack") ? _params.cost_div_by_stack : false;
    var _min_c   = variable_struct_exists(_params, "min_hp_cost") ? _params.min_hp_cost : 1;
    var _min_req = variable_struct_exists(_params, "min_hp_required") ? _params.min_hp_required : 10;

    var _cost = _div ? max(_base / _count, _min_c) : _base;

    // ★ 不变量：门槛必须高于消耗，否则会出现"扣完必死"→ 永远放不出
    //   （数据表配错时自动纠正，不让玩家陷入"有遗物但永远用不了"的状态）
    if (_min_req <= _cost) _min_req = _cost + 1;

    if (owner.hp - _cost <= 0) return _res;      // 扣了会死
    if (owner.hp < _min_req) return _res;        // 电量不够门槛

    _res.can = true;
    _res.cost = _cost;
    return _res;
}

/// @function scr_relic_passive_overclock_pay(owner, kind)
/// @description ★ 支付超频代价（确认能放之后再调）
/// @returns {real} 实际扣的血量（0 = 没扣）
function scr_relic_passive_overclock_pay(owner, kind = "skill") {
    var _chk = scr_relic_passive_overclock_can_pay(owner, kind);
    if (!_chk.can) return 0;

    owner.hp -= _chk.cost;
    if (owner.hp < 1) owner.hp = 1;      // 兜底：超频不能把自己扣死

    // 视觉反馈：扣血闪一下（复用现有受击闪白）
    if (variable_instance_exists(owner, "is_hit_flashing")) {
        owner.is_hit_flashing = true;
        owner.hit_flash_timer = max(owner.hit_flash_timer, 6);
    }

    show_debug_message("[超频颗粒] 扣血 " + string(_chk.cost) + " 强放 " + string(kind));
    return _chk.cost;
}

// ------------------------------------------------------------
// ★ 超频颗粒 × 附件型武技（榴弹炮）—— 补一发弹药，不动装填进度
// ------------------------------------------------------------
/// @function scr_relic_passive_overclock_can_refill(owner)
/// @description 检查能否"扣血换一发能打的榴弹"
/// @returns {struct} { can: bool, cost: real, need_refill: bool }
/// @note ★ 两种子情况（都必须支持，否则玩家会卡死）：
///       1) 弹 没满 且 装填中 → 补一发 + 放行
///       2) 弹 已满 但 装填计时未走完 → **不补弹**，只放行
///          （这种状态是真实存在的：装填判定用 floor(_progress*ammo_max)
///            会先把弹数补上来，而 cooldown_timer 还在走）
function scr_relic_passive_overclock_can_refill(owner) {
    var _res = { can: false, cost: 0, need_refill: false };
    if (!instance_exists(owner)) return _res;

    // 必须有附件型武技
    if (!instance_exists(owner.skill_instance)) return _res;
    var _sk = owner.skill_instance;

    var _is_attachment = variable_instance_exists(_sk, "type") && _sk.type == "附件";
    if (!_is_attachment) return _res;

    // 数据表开关：附件型是否允许超频补弹
    var _oc_data = data_relic_passive_get("relic_overclock_particle");
    if (_oc_data != undefined && variable_struct_exists(_oc_data, "params")) {
        var _p = _oc_data.params;
        if (variable_struct_exists(_p, "allow_attachment_refill") && !_p.allow_attachment_refill) return _res;
    }

    if (!variable_instance_exists(_sk, "ammo_current") || !variable_instance_exists(_sk, "ammo_max")) return _res;

    var _ammo_full    = (_sk.ammo_current >= _sk.ammo_max);
    var _cd_pending   = (variable_instance_exists(_sk, "cooldown_timer") && _sk.cooldown_timer > 0);

    // ★ 已经满弹且装填也完成了 → 本来就能打，不需要超频（别白扣血）
    if (_ammo_full && !_cd_pending) return _res;

    // 已经有通行证了 → 不用再买
    if (variable_instance_exists(owner, "_oc_ready_shot") && owner._oc_ready_shot) return _res;

    // 走统一的超频检查（层数 / 门槛 / 电量）
    var _chk = scr_relic_passive_overclock_can_pay(owner, "skill");
    if (!_chk.can) return _res;

    _res.can = true;
    _res.cost = _chk.cost;
    _res.need_refill = !_ammo_full;      // 弹没满才需要补
    return _res;
}

/// @function scr_relic_passive_overclock_refill(owner)
/// @description ★ 扣血补一发弹药（不走冷却），并标记"本发已放行"
/// @returns {real} 实际扣的血量（0 = 没扣）
/// @note ★ 为什么用 _oc_ready_shot 放行标记，而不是 cooldown_timer = 0：
///       附件的 cooldown_timer 同时被**装填判定**使用
///       （scr_character_state_update: floor(_progress * ammo_max) 重算弹数）。
///       直接清零 → _elapsed 变成 _total → _should_have = ammo_max → 弹数被算错，
///       而且"装填完成闪烁/装满"逻辑会提前触发。
///       所以：**不动计时器**，只给玩家一张"这一发现在能打"的通行证。
function scr_relic_passive_overclock_refill(owner) {
    var _chk = scr_relic_passive_overclock_can_refill(owner);
    if (!_chk.can) return 0;

    var _sk = owner.skill_instance;

    // 扣血（复用统一支付逻辑，保证数值口径一致）
    var _paid = scr_relic_passive_overclock_pay(owner, "skill");
    if (_paid <= 0) return 0;

    // 补一发（★ 只动 ammo_current，绝不碰 cooldown_timer）
    // ★ 弹已满时（装填判定已把弹补上来、但计时没走完）不再加弹，只买放行
    if (_chk.need_refill) {
        _sk.ammo_current = min(_sk.ammo_current + 1, _sk.ammo_max);
    }

    // ★ 放行标记：下一发射击允许无视"装填未完成"
    //   用完即清（见 scr_attachment_try_skill）
    //   ★ 同时记一个时长上限，避免"买了不打"导致通行证永久挂在身上
    owner._oc_ready_shot = true;
    owner._oc_ready_shot_timer = 300;      // 5 秒内有效

    var _msg = _chk.need_refill
        ? ("补弹 → " + string(_sk.ammo_current) + "/" + string(_sk.ammo_max) + "（本发已放行）")
        : ("弹已满，直接放行（装填未完成也可发射）");
    show_debug_message("[超频颗粒] " + _msg);
    return _paid;
}

// ============================================================
// 六、拾取链路（被动遗物不建对象，直接转成池数据）
// ============================================================

/// @function scr_relic_passive_pickup_from_item(player, item)
/// @description 从"地面上的被动遗物物品"转成池数据并销毁物品
/// @returns {bool} 是否拾取成功
/// @note ★ 被动遗物是纯数据，拾取 = 读数据 → 写池 → 销毁地面物品
function scr_relic_passive_pickup_from_item(player, item) {
    if (!instance_exists(player)) return false;
    if (!instance_exists(item)) return false;
    if (!item.is_on_ground) return false;

    var _relic_id = variable_instance_exists(item, "relic_id") ? item.relic_id : "";
    if (_relic_id == "") return false;

    var _data = data_relic_passive_get(_relic_id);
    if (_data == undefined) return false;

    var _display_name = variable_struct_exists(_data, "display_name") ? _data.display_name : "未知遗物";
    var _rarity = variable_instance_exists(item, "rarity") ? item.rarity : "common";
    var _qi = variable_instance_exists(item, "quality_index") ? item.quality_index : 0;

    // ===== 满格 / 到上限 检查（先查再删，避免东西没了）=====
    var _result = scr_relic_passive_add(player, _relic_id, _rarity, _qi);

    if (_result == "full") {
        scr_show_hint(player, "被动遗物栏已满");
        return false;
    }
    if (_result == "max_stack") {
        scr_show_hint(player, _display_name + " 已达上限");
        return false;
    }
    if (_result == "invalid") {
        return false;
    }

    // ===== 成功 → 销毁地面物品 =====
    if (instance_exists(item.glow_ref)) {
        with (item.glow_ref) instance_destroy();
        item.glow_ref = noone;
    }
    instance_destroy(item);

    // ===== 提示 =====
    var _count = scr_relic_passive_get_count(player, _relic_id);
    if (_result == "stacked") {
        scr_show_hint(player, _display_name + " ×" + string(_count));
    } else {
        scr_show_hint(player, "获得 " + _display_name);
    }

    return true;
}

// ============================================================
// 七、UI 查询接口（HUD / 背包栏共用）
// ============================================================

/// @function scr_relic_passive_get_display_list(owner)
/// @description 取用于显示的遗物列表（含派生数据），HUD 和背包栏都调这个
/// @returns {array<struct>} [{ id, count, name, color, sprite, description }, ...]
function scr_relic_passive_get_display_list(owner) {
    var _list = [];
    if (!instance_exists(owner)) return _list;
    if (!variable_instance_exists(owner, "relic_pool")) return _list;

    for (var i = 0; i < array_length(owner.relic_pool); i++) {
        var _entry = owner.relic_pool[i];
        if (_entry == undefined) continue;

        var _data = data_relic_passive_get(_entry.id);
        if (_data == undefined) continue;

        var _color = c_white;
        if (variable_struct_exists(_data, "icon_color")) {
            _color = scr_get_color_from_hex(_data.icon_color);
        }

        // ★ 品质色（用于框背景/边框，与其它槽位一致）
        var _rarity = variable_instance_exists(owner, "relic_pool") ? _entry.rarity : "common";
        if (_rarity == undefined || _rarity == "") _rarity = "common";
        var _rarity_color = scr_get_rarity_color(_rarity);

        array_push(_list, {
            id:           _entry.id,
            count:        _entry.count,
            name:         variable_struct_exists(_data, "display_name") ? _data.display_name : "未知",
            description:  variable_struct_exists(_data, "description") ? _data.description : "",
            color:        _color,              // 遗物主题色（图标占位/描边用）
            rarity_color: _rarity_color,       // ★ 品质色（框背景用）
            sprite:       (variable_struct_exists(_data, "sprite") && _data.sprite != noone) ? _data.sprite : -1,
            rarity:       _rarity,
            stackable:    data_relic_passive_is_stackable(_entry.id),
        });
    }
    return _list;
}

/// @function scr_relic_passive_slot_count(owner)
/// @returns {real} 当前已解锁的被动遗物格数
function scr_relic_passive_slot_count(owner) {
    if (!instance_exists(owner)) return 0;
    if (!variable_instance_exists(owner, "passive_relic_slots_unlocked")) return 0;
    return owner.passive_relic_slots_unlocked;
}

/// @function scr_relic_passive_unlock_slot(owner, amount)
/// @description 解锁被动遗物格（密钥/升级用）
/// @returns {real} 解锁后的格数
function scr_relic_passive_unlock_slot(owner, amount = 1) {
    if (!instance_exists(owner)) return 0;
    scr_relic_passive_init(owner);

    owner.passive_relic_slots_unlocked = min(
        owner.passive_relic_slots_unlocked + amount,
        owner.passive_relic_slots
    );
    return owner.passive_relic_slots_unlocked;
}

// ============================================================
// 八、开发用：直接发放（测试入口）
// ============================================================

/// @function scr_relic_passive_debug_grant(owner, relic_id, count)
/// @description 测试用：直接给 owner 加 N 层遗物（跳过拾取流程）
function scr_relic_passive_debug_grant(owner, relic_id, count = 1) {
    if (!instance_exists(owner)) return;
    for (var i = 0; i < count; i++) {
        var _r = scr_relic_passive_add(owner, relic_id, "common", 0);
        if (_r == "full") {
            scr_show_hint(owner, "被动遗物栏已满");
            return;
        }
        if (_r == "max_stack") {
            scr_show_hint(owner, "已达叠加上限");
            return;
        }
    }
    scr_show_hint(owner, "获得 " + string(relic_id) + " ×" + string(count));
}

// ============================================================
// 九、工厂（被动遗物地面物品）
// ============================================================
/// @function scr_factory_relic_passive_create(relic_id, rarity_id, spawn_x, spawn_y)
/// @description 创建被动遗物的地面物品（★ 复用 obj_relic_base 承载，靠 pool 字段区分）
/// @returns {id} 地面物品实例
/// @note 被动遗物本体不建对象（纯数据），但"掉在地上"需要一个可见载体，
///       所以复用 obj_relic_base。拾取时由 scr_relic_passive_pickup_from_item
///       转成池数据并销毁本实例。
function scr_factory_relic_passive_create(relic_id, rarity_id, spawn_x, spawn_y) {
    var _data = data_relic_passive_get(relic_id);
    if (_data == undefined) {
        show_debug_message("[被动遗物工厂] 数据不存在: " + string(relic_id));
        return noone;
    }

    var _rarity_data = data_rarity_get(rarity_id);
    if (_rarity_data == undefined) {
        rarity_id = "common";
        _rarity_data = data_rarity_get("common");
        if (_rarity_data == undefined) return noone;
    }

    var inst = instance_create_layer(spawn_x, spawn_y, "Instances", obj_relic_base);
    if (!instance_exists(inst)) return noone;

    inst.relic_id = relic_id;
    inst.rarity = rarity_id;
    inst.entity_data = _data;
    inst.rarity_data = _rarity_data;
    inst.display_name = variable_struct_exists(_data, "display_name") ? _data.display_name : "";
    inst.owner_id = noone;
    inst.is_on_ground = true;
    inst.quality_index = clamp(_rarity_data.tier - 1, 0, 6);

    // ★ 标记为被动遗物（拾取时据此分流）
    if (variable_instance_exists(inst, "is_passive")) {
        inst.is_passive = true;
    }

    if (variable_struct_exists(_data, "sprite") && _data.sprite != undefined && _data.sprite != noone) {
        inst.sprite_index = _data.sprite;
    }
    inst.rarity_color = scr_get_rarity_color(rarity_id);

    // 地上 → 挂光晕
    scr_glow_attach(inst);

    // 被动遗物不需要主动冷却
    inst.cooldown_timer = 0;
    inst.is_active = false;
    inst.active_timer = 0;

    show_debug_message("[被动遗物工厂] 创建: " + relic_id + " (" + string(rarity_id) + ")");
    return inst;
}
