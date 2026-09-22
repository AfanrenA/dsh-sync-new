// scr_hitbox_check_collision.gml
function scr_hitbox_check_collision(_hitbox) {
    // ===== 获取武器数据 =====
    var _weapon = _hitbox.weapon_ref;
    if (!instance_exists(_weapon)) return;
    
    var _data = _weapon.entity_data;
    if (_data == undefined) return;
    
    // ===== 判断是否使用分段控制 =====
    var _has_up = (_data.swing_up_frames != undefined && _data.swing_up_frames > 0);
    var _has_down = (_data.swing_down_frames != undefined && _data.swing_down_frames > 0);
    
    if (_has_up && _has_down) {
        // ===== 分段控制：只有下劈阶段才触发伤害 =====
        if (_weapon.swing_timer > _data.swing_down_frames) {
            return;
        }
    } else {
        // ===== 没有分段控制（向后兼容） =====
        var _total = _weapon.swing_total_frames;
        if (_weapon.swing_timer > _total * 0.5) {
            return;
        }
    }
    
    // ===== 检测目标 =====
    var _target = collision_circle(_hitbox.x, _hitbox.y, _hitbox.hit_radius, _hitbox.target_object, false, true);
    
    // ===== Hack 特殊行为：检测飞行物 =====
    if (_hitbox.hitbox_behavior == "destroy_projectiles") {
        var _projectile = collision_circle(_hitbox.x, _hitbox.y, _hitbox.hit_radius, obj_projectile_base, false, true);
        if (_projectile != noone) {
            instance_destroy(_projectile);
        }
    }
    
    if (_target == noone || _target == _hitbox.owner_id) return;
    if (!_target.is_alive || _target.is_dead) return;
    if (!_hitbox.owner_id.is_alive || _hitbox.owner_id.is_dead) return;
    
    // ===== 检查是否已伤害过 =====
    for (var i = 0; i < array_length(_hitbox.hit_targets); i++) {
        if (_hitbox.hit_targets[i] == _target) {
            return;
        }
    }
    
    // ★ 一行搞定：伤害+护盾+扣血+死亡+反馈
    // 击退/硬直从武器数据读（不传覆盖值）
    var _pkt = scr_damage_packet_create(_hitbox.damage);
var _src_weapon = _hitbox.owner_id.current_weapon;   // 或 _hitbox.weapon_ref
if (instance_exists(_src_weapon)) {
    scr_damage_packet_from_weapon(_pkt, _src_weapon.entity_data);
}
scr_damage_apply(_target, _pkt, _hitbox.owner_id);
    
    // ===== 记录已伤害目标 =====
    array_push(_hitbox.hit_targets, _target);
}