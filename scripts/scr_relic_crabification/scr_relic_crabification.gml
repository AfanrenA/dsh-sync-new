/// @description 蟹化 —— 主动效果脚本
///              由 scr_relic_activate 通过 data_relic.active_script 调用
/// @param {id} owner 持有者
/// @param {id} relic 遗物实例
/// @note 倍率部分已由 scr_relic_activate 统一应用，这里只做"视觉 + 特有逻辑"
function scr_relic_crabification(owner, relic) {
    if (!instance_exists(owner)) return;
    if (!instance_exists(relic)) return;

    var _data = relic.entity_data;
    if (_data == undefined) return;

    // ============================================================
    // 1. 视觉：蟹化外观
    // ============================================================
    // ★ 做法 C（占位）：代码变形，不需要美术资源
    //    将来画好 spr_player_crab 后，把 _use_sprite 设为 true 即可
    var _use_sprite = false;                  // ← 有螃蟹精灵后改 true
    var _crab_sprite = -1;                    // ← 填 spr_player_crab

    // 记录原始外观（用于还原）
    if (!variable_instance_exists(owner, "_crab_orig_sprite")) {
        owner._crab_orig_sprite     = owner.sprite_index;
        owner._crab_orig_xscale     = owner.image_xscale;
        owner._crab_orig_yscale     = owner.image_yscale;
        owner._crab_orig_blend      = owner.image_blend;
        owner._crab_orig_alpha      = owner.image_alpha;
    }

    if (_use_sprite && _crab_sprite != -1) {
        // 做法 A：换精灵
        owner.sprite_index = _crab_sprite;
    } else {
        // 做法 C：代码变形（压扁 + 偏红 + 轻微不透明加深）
        owner.image_yscale = owner._crab_orig_yscale * 0.85;   // 压扁
        owner.image_blend  = make_color_rgb(255, 150, 120);    // 偏蟹红
    }

    // ============================================================
    // 2. 状态标记（供其他系统查询）
    // ============================================================
    owner.is_crabbed = true;

    // ============================================================
    // 3. 重新拉满护盾（蟹化瞬间立刻享受 3 倍盾）
    // ============================================================
    if (variable_instance_exists(owner, "max_shield")) {
        owner.shield = owner.max_shield;
    }

    // ============================================================
    // 4. 屏幕/粒子反馈
    // ============================================================
    scr_hit_effect_trigger(owner.x, owner.y, "shield_break");

    if (variable_instance_exists(owner, "flash_timer")) {
        // 玩家没有 flash_timer（那是武器上的），用武器闪光兜底
    }
    if (instance_exists(owner.current_weapon)) {
        owner.current_weapon.flash_timer = 12;
    }

    show_debug_message("[遗物] 蟹化 生效");
}