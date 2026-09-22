/// @description 装备本命遗物到槽（交换：旧遗物放回背包）
/// @param {id} owner 持有者（玩家/敌人通用）
/// @param {id} relic_inst 遗物实例
/// @returns {bool} 是否装备成功
/// @note ★ 通用形态：不判断 owner 是玩家还是敌人
function scr_relic_equip(owner, relic_inst) {
    if (!instance_exists(owner)) return false;
    if (!instance_exists(relic_inst)) return false;

    // ★ 防御：owner 必须有 relic_slot 槽
    if (!variable_instance_exists(owner, "relic_slot")) {
        show_debug_message("[遗物] owner 没有 relic_slot 槽，无法装备");
        return false;
    }

    // ===== 0. 先从背包移除新遗物（腾格子）=====
    scr_inventory_remove(owner, relic_inst);

    // ===== 1. 旧遗物：关闭效果 → 放回背包 =====
    if (instance_exists(owner.relic_slot)) {
        var _old = owner.relic_slot;

        // ★ 关键：先关闭效果，防止倍率残留
        scr_relic_deactivate(owner, _old);

        // ★ 背包满 → 中止，把新遗物放回去
        if (variable_instance_exists(owner, "inventory") && variable_instance_exists(owner, "inventory_size")) {
            if (array_length(owner.inventory) >= owner.inventory_size) {
                scr_show_hint(owner, "背包已满");
                scr_inventory_add(owner, relic_inst);   // 新遗物放回去
                return false;
            }
        }

        // 旧遗物回背包
        if (variable_instance_exists(owner, "inventory")) {
            scr_inventory_add(owner, _old);
        }
        _old.visible = false;
        _old.is_on_ground = false;
        _old.owner_id = owner;

        owner.relic_slot = noone;
    }

    // ===== 2. 新遗物入槽 =====
    owner.relic_slot = relic_inst;

    if (variable_instance_exists(owner, "relic_slot_id")) {
        owner.relic_slot_id = relic_inst.relic_id;
    }

    // ===== 3. 状态初始化 =====
    relic_inst.cooldown_timer = 0;
    relic_inst.is_active = false;
    relic_inst.active_timer = 0;
    relic_inst.owner_id = owner;
    relic_inst.is_on_ground = false;
    relic_inst.visible = false;

    // ===== 4. 从地面移除光晕 =====
    if (instance_exists(relic_inst.glow_ref)) {
        with (relic_inst.glow_ref) instance_destroy();
        relic_inst.glow_ref = noone;
    }

    show_debug_message("[遗物] 装备: " + string(relic_inst.relic_id));
    return true;
}