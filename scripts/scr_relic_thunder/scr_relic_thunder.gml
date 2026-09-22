/// @description 雷霆万钧 —— 主动效果脚本
/// @param {id} owner 持有者
/// @param {id} relic 遗物实例
function scr_relic_thunder(owner, relic) {
    if (!instance_exists(owner)) return;
    if (!instance_exists(relic)) return;

    var _data = relic.entity_data;
    if (_data == undefined) return;

    // ===== 1. 爆发闪电 =====
    scr_relic_thunder_burst(owner, _data);

    // ===== 2. 标记：闪避要留尾迹 =====
    owner.is_thunder_active = true;

    // ===== 3. 视觉反馈 =====
    if (instance_exists(owner.current_weapon)) {
        owner.current_weapon.flash_timer = 12;
    }

    show_debug_message("[遗物] 雷霆万钧 生效");
}

/// @description 爆发闪电（按 R 时 + 每次闪避时调用）
/// @param {id} owner 持有者
/// @param {struct} _data 遗物数据
function scr_relic_thunder_burst(owner, _data) {
    if (!instance_exists(owner)) return;
    if (_data == undefined) return;

    var _burst = _data.burst;
    if (_burst == undefined) return;

    var _count     = _burst.bolt_count;
    var _range_min = _burst.bolt_range_min;
    var _range_max = _burst.bolt_range_max;
    var _life      = _burst.burst_life;
    var _damage    = _burst.burst_damage;
    var _radius    = _burst.burst_radius;

    for (var i = 0; i < _count; i++) {
        var _bolt = instance_create_layer(owner.x, owner.y, "Instances", obj_relic_lightning_bolt);
        if (!instance_exists(_bolt)) continue;

        // ===== 方向：均匀分布 + 扰动 =====
        var _dir = (i / _count) * 360 + random_range(-25, 25);
        var _len = random_range(_range_min, _range_max);

        // ★ 跟随玩家
        _bolt.follow_ref = owner;
        _bolt.follow_offset_x = 0;
        _bolt.follow_offset_y = 0;

        _bolt.life     = _life;
        _bolt.max_life = _life;
        _bolt.damage   = _damage;
        _bolt.damage_radius = _radius;
        _bolt.owner_ref = owner;

        // ===== 生成折线点（★ 相对坐标）=====
        var _seg = _bolt.segment_count;
        var _pts = [];
        for (var s = 0; s <= _seg; s++) {
            var _t = s / _seg;
            var _px = lengthdir_x(_len * _t, _dir);
            var _py = lengthdir_y(_len * _t, _dir);

            // 首尾不抖动
            if (s > 0 && s < _seg) {
                var _jitter = random_range(-20, 20);
                _px += lengthdir_x(_jitter, _dir + 90);
                _py += lengthdir_y(_jitter, _dir + 90);
            }
            array_push(_pts, [_px, _py]);
        }
        _bolt.points = _pts;
    }
}