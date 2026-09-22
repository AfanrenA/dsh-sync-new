// scr_agility_dash.gml
// 闪避：朝鼠标方向瞬移，路径留残影（残影数 = 品阶数 1~7）
function scr_agility_dash(owner, _data) {
    if (!object_is_ancestor(owner.object_index, obj_player_base)) return false;
    if (!instance_exists(owner.agility_instance)) return false;
    if (owner.agility_instance.cooldown_timer > 0) return false;
    if (owner.is_dashing) return false;
    
    // ===== 中断普攻 =====
    if (owner.is_attacking) {
        owner.is_attacking = false;
        owner.attack_timer = 0;
    }
    
    // ===== 中断技能蓄力 =====
    if (instance_exists(owner.current_weapon)) {
        var _w = owner.current_weapon;
        if (_w.skill_charging) {
            _w.skill_charging = false;
            _w.skill_charge = 0;
        }
    }
    
    // ===== 品质倍率 =====
    var _qi = 0;
    if (instance_exists(owner.agility_instance) && owner.agility_instance.quality_index != undefined) {
        _qi = owner.agility_instance.quality_index;
    }
    
    var _distance = _data.distance * data_agility_get_quality_mult("dash", _qi, "quality_distance_mult");
    
    // ★ 遗物：身法冷却倍率（雷霆万钧 = 0.5）
    var _relic_cd = 1.0;
    if (variable_instance_exists(owner, "relic_agility_cd_mult")) {
        _relic_cd = owner.relic_agility_cd_mult;
    }
    var _cooldown = _data.cooldown * data_agility_get_quality_mult("dash", _qi, "quality_cooldown_mult") * _relic_cd;
    
    // ★ 残影总数 = 品阶数（1~7）；起点算 1 个，路径撒（总数-1）个
    var _ghost_total = clamp(_qi + 1, 1, 7);
    var _ghost_path  = max(_ghost_total - 1, 0);
    
    // ===== 计算方向 =====
    var _dir = point_direction(owner.x, owner.y, mouse_x, mouse_y);
    if (_data.direction_mode == "away") {
        _dir += 180;
    }
    
    var _dx = lengthdir_x(1, _dir);
    var _dy = lengthdir_y(1, _dir);
    
    // ★ 品质色
    var _outline_col = c_white;
    if (instance_exists(owner.agility_instance) && owner.agility_instance.rarity != undefined) {
        _outline_col = scr_get_rarity_color(owner.agility_instance.rarity);
    }
    
    // ===== 起点残影（永远 1 个）=====
    var _ghost = instance_create_layer(owner.x, owner.y, "Instances", obj_afterimage);
    if (instance_exists(_ghost)) {
        _ghost.snapshot_sprite  = owner.sprite_index;
        _ghost.snapshot_index   = owner.image_index;
        _ghost.snapshot_xscale  = owner.image_xscale;
        _ghost.snapshot_yscale  = owner.image_yscale;
        _ghost.snapshot_angle   = owner.image_angle;
        _ghost.snapshot_color   = c_white;
        _ghost.outline_color    = _outline_col;
    }
    
    // ===== ★ 雷霆万钧：创建尾迹对象（全程 1 个，往里塞点）=====
    var _trail = noone;
    var _trail_data = undefined;
    if (variable_instance_exists(owner, "is_thunder_active") && owner.is_thunder_active) {
        _trail_data = data_relic_get("relic_thunder");
        if (_trail_data != undefined && variable_struct_exists(_trail_data, "trail")) {
            if (_trail_data.trail.lightning_enabled) {
                _trail = instance_create_layer(owner.x, owner.y, "Instances", obj_relic_lightning_trail);
                if (instance_exists(_trail)) {
                    _trail.owner_ref     = owner;
                    _trail.life          = irandom_range(_trail_data.trail.node_life_min, _trail_data.trail.node_life_max);
                    _trail.max_life      = _trail.life;
                    _trail.point_max_age = _trail.life;      // ★ 点寿命 = 尾迹寿命
                    _trail.damage        = _trail_data.trail.node_damage;
                    _trail.damage_radius = _trail_data.trail.node_radius;
                    array_push(_trail.points, [owner.x, owner.y, 0]);   // 起点（x, y, age）
                }
            }
        }
    }
    
    // ===== 逐步推进 + 路径残影（均匀分布）=====
    var _step = 4;
    var _traveled = 0;
    var _ghost_index = 0;
    
    while (_traveled < _distance) {
        var _nx = owner.x + _dx * _step;
        var _ny = owner.y + _dy * _step;
        
        if (place_meeting(_nx, _ny, obj_wall_base)) break;
        
        owner.x = _nx;
        owner.y = _ny;
        _traveled += _step;
        
        // ★ 路径残影：按"应撒数量"均匀分布
        if (_ghost_path > 0 && _ghost_index < _ghost_path) {
            var _threshold = _distance * (_ghost_index + 1) / (_ghost_path + 1);
            if (_traveled >= _threshold) {
                var _ghost2 = instance_create_layer(owner.x, owner.y, "Instances", obj_afterimage);
                if (instance_exists(_ghost2)) {
                    _ghost2.snapshot_sprite  = owner.sprite_index;
                    _ghost2.snapshot_index   = owner.image_index;
                    _ghost2.snapshot_xscale  = owner.image_xscale;
                    _ghost2.snapshot_yscale  = owner.image_yscale;
                    _ghost2.snapshot_angle   = owner.image_angle;
                    _ghost2.snapshot_color   = c_white;
                    _ghost2.outline_color    = _outline_col;
                }
                _ghost_index += 1;
            }
        }
        
        // ===== ★ 雷霆万钧：每 12 像素追加一个轨迹点 =====
        if (instance_exists(_trail) && array_length(_trail.points) > 0) {
            var _last_i  = array_length(_trail.points) - 1;
            var _last_px = _trail.points[_last_i][0];
            var _last_py = _trail.points[_last_i][1];
            var _seg_dist = point_distance(_last_px, _last_py, owner.x, owner.y);
            
            if (_seg_dist >= 12) {
                array_push(_trail.points, [owner.x, owner.y, 0]);   // ★ 带 age
            }
        }
    }
    
    // ===== ★ 雷霆万钧：补最后一个点（终点）=====
    if (instance_exists(_trail)) {
        var _n = array_length(_trail.points);
        if (_n > 0) {
            var _end_px = _trail.points[_n - 1][0];
            var _end_py = _trail.points[_n - 1][1];
            if (point_distance(_end_px, _end_py, owner.x, owner.y) > 1) {
                array_push(_trail.points, [owner.x, owner.y, 0]);   // ★ 带 age
            }
        }
        _trail.is_sealed = true;   // 标记：不再追加点
    }
    
    // ===== 无敌 =====
    owner.is_invincible = true;
    owner.invincible_timer = max(owner.invincible_timer, _data.invincible_frames);
    
    // ===== 闪避状态 =====
    owner.is_dashing = true;
    owner.dash_timer = _data.invincible_frames;
    
    // ===== 冷却 =====
    owner.agility_instance.cooldown_timer = _cooldown;
    owner.dash_lockout_timer = _data.invincible_frames;
    
       // ===== ★ 雷霆万钧：闪避时爆发一次 =====
    if (variable_instance_exists(owner, "is_thunder_active") && owner.is_thunder_active) {
        var _burst_data = data_relic_get("relic_thunder");
        if (_burst_data != undefined) {
            scr_relic_thunder_burst(owner, _burst_data);
        }
    }
    
    return true;
}