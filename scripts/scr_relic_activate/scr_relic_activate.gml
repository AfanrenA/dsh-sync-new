/// @description 激活本命遗物：应用倍率 + 执行主动效果脚本
/// @param {id} owner 持有者
/// @param {id} relic_inst 遗物实例
/// @returns {bool} 是否激活成功
/// @note ★ 通用形态：不判断 owner 类型，只做"数据驱动 + 倍率应用"
function scr_relic_activate(owner, relic_inst) {
    if (!instance_exists(owner)) return false;
    if (!instance_exists(relic_inst)) return false;

    var _data = relic_inst.entity_data;
    if (_data == undefined) return false;

    // ===== 1. 先还原（防止上一个遗物的残留倍率）=====
    scr_relic_deactivate(owner, relic_inst);

    // ===== 2. 算持续时间 =====
    var _qi = 0;
    if (variable_instance_exists(relic_inst, "quality_index")) {
        _qi = relic_inst.quality_index;
    }
    var _duration_mult = data_relic_get_quality_mult(relic_inst.relic_id, _qi, "quality_duration_mult");
    var _duration_frames = _data.duration * 60 * _duration_mult;

    // ===== 3. 应用倍率（数据驱动，不写死）=====
    if (variable_struct_exists(_data, "effect")) {
        var _eff = _data.effect;

        if (variable_struct_exists(_eff, "move_line_mult")) {
            owner.relic_move_mult = _eff.move_line_mult;
        }
        if (variable_struct_exists(_eff, "move_diag_mult")) {
            owner.relic_move_diag_mult = _eff.move_diag_mult;
        }
        if (variable_struct_exists(_eff, "shield_mult")) {
            owner.relic_shield_mult = _eff.shield_mult;

            // ★ 护盾：上限放大，当前值**按原比例**同步放大
            //
            // 为什么要记比例而不是直接拉满：
            //   原来写的是 `owner.shield = owner.max_shield`（拉满），
            //   会把玩家蟹化前的真实盾值丢弃 —— 蟹化一开白送满盾，
            //   结束后又还原成"满盾"，导致"被打碎的盾蟹化结束又回来了"。
            //
            // 正确语义：蟹化是"护盾变厚 ×3"，不是"护盾回满"。
            //   蟹化前 30/100 → 蟹化中 90/300（比例不变）→ 结束回 30/100
            //   蟹化中被打碎（0/300）→ 结束仍是 0/100（盾确实没了）
            var _sm = _eff.shield_mult;
            if (_sm != 1.0) {
                if (variable_instance_exists(owner, "max_shield")) {
                    owner.relic_base_max_shield = owner.max_shield;   // 存上限基准

                    // 记录蟹化前的"盾值比例"（0~1），用于结束时还原
                    var _ratio = (owner.max_shield > 0) ? (owner.shield / owner.max_shield) : 0;
                    owner.relic_shield_ratio = clamp(_ratio, 0, 1);

                    owner.max_shield = owner.max_shield * _sm;
                    owner.shield     = owner.max_shield * owner.relic_shield_ratio;
                }
            }
        }
        if (variable_struct_exists(_eff, "damage_mult")) {
            owner.relic_damage_mult = _eff.damage_mult;
        }
        if (variable_struct_exists(_eff, "attack_cooldown_mult")) {
            owner.relic_attack_cd_mult = _eff.attack_cooldown_mult;
        }
        if (variable_struct_exists(_eff, "agility_cd_mult")) {
            owner.relic_agility_cd_mult = _eff.agility_cd_mult;
        }
    }

    // ===== 4. 进生效状态 =====
    relic_inst.is_active = true;
    relic_inst.active_timer = _duration_frames;

    // ===== 5. 执行主动效果脚本（数据表指定）=====
    // ★ 对齐 scr_skill_cast 的 cast_script 写法
    if (variable_struct_exists(_data, "active_script") && _data.active_script != "") {
        var _script = asset_get_index(_data.active_script);
        if (_script != -1) {
            script_execute(_script, owner, relic_inst);
        } else {
            show_debug_message("[遗物] 主动脚本不存在: " + _data.active_script);
        }
    }

    show_debug_message("[遗物] 激活: " + string(relic_inst.relic_id) + " | 持续: " + string(_duration_frames) + " 帧");
    return true;
}