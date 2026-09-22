/// @description 尝试激活本命遗物（按 R 调用）
/// @param {id} owner 持有者
/// @returns {bool} 是否成功激活
/// @note ★ 通用形态：玩家/敌人都能调，冷却字段统一用 relic_slot.cooldown_timer
function scr_relic_try_activate(owner) {
    if (!instance_exists(owner)) return false;

    // ===== 1. 槽位检查 =====
    if (!variable_instance_exists(owner, "relic_slot")) return false;
    if (!instance_exists(owner.relic_slot)) return false;

    var _relic = owner.relic_slot;
    var _data = _relic.entity_data;
    if (_data == undefined) return false;

    // ===== 2. 冷却检查 =====
    if (_relic.cooldown_timer > 0) {
        // 提示（只有有 skill_hint_cooldown 的角色才提示，避免敌人刷屏）
        if (variable_instance_exists(owner, "skill_hint_cooldown")) {
            if (owner.skill_hint_cooldown <= 0) {
                scr_show_hint(owner, "遗物冷却中");
                owner.skill_hint_cooldown = 60;
            }
        }
        return false;
    }

    // ===== 3. 激活 =====
    var _ok = scr_relic_activate(owner, _relic);
    if (!_ok) return false;

    // ===== 4. 写冷却 =====
    var _qi = 0;
    if (variable_instance_exists(_relic, "quality_index")) {
        _qi = _relic.quality_index;
    }
    var _cd_mult = data_relic_get_quality_mult(_relic.relic_id, _qi, "quality_cooldown_mult");
    _relic.cooldown_timer = _data.cooldown * 60 * _cd_mult;

    return true;
}