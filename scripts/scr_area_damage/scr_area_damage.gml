// ============================================================
// scr_area_damage - 统一范围伤害
// 检测范围内的所有目标 + 造成伤害 + 受击反馈
// 一步到位，所有爆炸/范围攻击共用
// 
// V3 原则：
// - 模块化 ✅ 独立脚本
// - 可复用 ✅ 所有爆炸/AOE共用
// - 单一职责 ✅ 只做"范围伤害"这一件事
// ============================================================

/// @description 对范围内所有角色造成伤害
/// @param {real} _x 爆炸中心X
/// @param {real} _y 爆炸中心Y
/// @param {real} _radius 爆炸半径
/// @param {real} _damage 伤害值
/// @param {instance} _source 伤害来源（攻击者）
/// @param {bool} _hit_player 是否伤害玩家（默认true）
/// @param {bool} _hit_enemy 是否伤害敌人（默认true）
function scr_area_damage(_x, _y, _radius, _damage, _source = noone, _hit_player = true, _hit_enemy = true) {
    // ===== 安全检查 =====
    if (_damage <= 0) return;
    if (_radius <= 0) return;
    
    var _list = ds_list_create();
    
    // ===== 检测敌人 =====
    if (_hit_enemy) {
        collision_circle_list(_x, _y, _radius, obj_enemy_base, false, true, _list, false);
    }
    
    // ===== 检测玩家 =====
    if (_hit_player) {
        collision_circle_list(_x, _y, _radius, obj_player_base, false, true, _list, false);
    }
    
    // ===== 遍历所有目标 =====
    for (var i = 0; i < ds_list_size(_list); i++) {
        var _target = _list[| i];
        if (_target == _source) continue;
        if (!instance_exists(_target)) continue;
        if (_target.hp <= 0) continue;
        
        // ★ 调用统一伤害函数 ★
        scr_apply_damage(_target, _damage, _source);
    }
    
    ds_list_destroy(_list);
}