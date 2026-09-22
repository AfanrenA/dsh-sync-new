/// @description 关闭本命遗物：还原所有倍率，清空状态
/// @param {id} owner 持有者
/// @param {id} relic_inst 遗物实例（可选，不传则关 owner 当前的）
/// @note ★ 必须幂等：重复调用不能出错，不能累乘
function scr_relic_deactivate(owner, relic_inst = noone) {
    // ===== 0. 防御：无效实例直接退出 =====
    if (owner == noone || owner == undefined) return;
    if (!instance_exists(owner)) return;
    if (!variable_instance_exists(owner, "x")) return;

    if (relic_inst == undefined) relic_inst = noone;

    // ===== 1. 清遗物自身状态 =====
    if (relic_inst != noone && instance_exists(relic_inst)) {
        relic_inst.is_active = false;
        relic_inst.active_timer = 0;
    }

    // ===== 2. 还原所有倍率 =====
    // ★ 直接赋 1.0，不做除法 —— 避免反复开关产生浮点误差累积
    if (variable_instance_exists(owner, "relic_move_mult"))       owner.relic_move_mult = 1.0;
    if (variable_instance_exists(owner, "relic_move_diag_mult"))  owner.relic_move_diag_mult = 1.0;
    if (variable_instance_exists(owner, "relic_shield_mult"))     owner.relic_shield_mult = 1.0;
    if (variable_instance_exists(owner, "relic_damage_mult"))     owner.relic_damage_mult = 1.0;
    if (variable_instance_exists(owner, "relic_attack_cd_mult"))  owner.relic_attack_cd_mult = 1.0;
    if (variable_instance_exists(owner, "relic_agility_cd_mult")) owner.relic_agility_cd_mult = 1.0;

    // ===== 3. 还原护盾上限（蟹化专用：存了基准值就还原）=====
    // ★ 关键修正：不能只夹紧"超上限"的情况，必须**按比例还原当前值**。
    //
    //   旧代码：if (owner.shield > owner.max_shield) owner.shield = owner.max_shield;
    //     → 蟹化中盾被打碎（shield=0）时，0 > 100 不成立 → 什么都不做
    //     → 玩家看到"蟹化结束，被打碎的盾又回来了"（其实是满血再生把盾充回了旧上限）
    //
    //   新语义：还原上限后，把当前盾**按蟹化期间的剩余比例**折算回去。
    //     蟹化中 90/300（比例 0.3）→ 结束 30/100
    //     蟹化中 0/300 （比例 0）  → 结束 0/100（盾确实碎了）
    if (variable_instance_exists(owner, "relic_base_max_shield")) {
        if (owner.relic_base_max_shield > 0) {
            // 先算比例（用**放大后**的上限做分母），再还原上限
            var _ratio = 0;
            if (owner.max_shield > 0) {
                _ratio = clamp(owner.shield / owner.max_shield, 0, 1);
            }

            owner.max_shield = owner.relic_base_max_shield;
            owner.shield     = owner.max_shield * _ratio;

            // 兜底：绝不超过上限
            if (owner.shield > owner.max_shield) owner.shield = owner.max_shield;
            if (owner.shield < 0) owner.shield = 0;
        }
        owner.relic_base_max_shield = 0;
    }
    if (variable_instance_exists(owner, "relic_shield_ratio")) {
        owner.relic_shield_ratio = 0;
    }

    // ===== 4. 还原移动速度（如果用倍率覆盖过）=====
    if (variable_instance_exists(owner, "relic_base_move_speed")) {
        if (owner.relic_base_move_speed > 0) {
            owner.move_speed = owner.relic_base_move_speed;
        }
        owner.relic_base_move_speed = 0;
    }

    // ===== 5. 还原蟹化外观 =====
    if (variable_instance_exists(owner, "_crab_orig_sprite")) {
        if (owner._crab_orig_sprite != -1) {
            owner.sprite_index = owner._crab_orig_sprite;
        }

        // ★ 保留朝向符号（朝左是负值），只还原绝对值
        var _sign_x = sign(owner.image_xscale);
        if (_sign_x == 0) _sign_x = 1;
        owner.image_xscale = _sign_x * abs(owner._crab_orig_xscale);

        var _sign_y = sign(owner.image_yscale);
        if (_sign_y == 0) _sign_y = 1;
        owner.image_yscale = _sign_y * abs(owner._crab_orig_yscale);

        owner.image_blend = owner._crab_orig_blend;
        owner.image_alpha = owner._crab_orig_alpha;

        // 清掉记录（下次蟹化重新记录当前外观）
        owner._crab_orig_sprite = -1;
        owner._crab_orig_xscale = 1;
        owner._crab_orig_yscale = 1;
        owner._crab_orig_blend  = c_white;
        owner._crab_orig_alpha  = 1;
    }

    // ===== 6. 清状态标记 =====
    if (variable_instance_exists(owner, "is_crabbed")) {
        owner.is_crabbed = false;
    }
	    // ===== 7. 清雷霆万钧标记 =====
    if (variable_instance_exists(owner, "is_thunder_active")) {
        owner.is_thunder_active = false;
    }
}