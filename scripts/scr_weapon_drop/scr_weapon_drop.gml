// ======================================================================
// scr_weapon_drop.gml
// V3 武器掉落系统 - 数据驱动 + 组合式碰撞组件
// ======================================================================
// 
// 架构变更说明（V2 → V3）：
//   ❌ V2 方式：依赖 obj_solid + place_meeting + obj_weapon_blocker
//   ✅ V3 方式：碰撞组件（COLLISION_LAYER.PICKUP）+ 独立光晕对象
//
// 核心原则：
//   1. 不依赖任何 solid 对象（性能杀手 + 逻辑黑箱）
//   2. 使用碰撞组件（组合优于继承）
//   3. 品质光晕是独立视觉对象（与碰撞完全解耦）
//   4. 拾取检测在玩家端，武器只负责"被检测"
//   5. 全局状态在游戏启动时初始化（obj_game），此处不再检查
// ======================================================================


// ============================================================
// scr_weapon_drop - 将已有武器丢到地面
// ============================================================
/// @description 将武器放置到地面，挂载碰撞组件和光晕
/// @param {instance} _weapon 要掉落的武器实例
/// @param {real} drop_x 掉落位置 X
/// @param {real} drop_y 掉落位置 Y
function scr_weapon_drop(_weapon, drop_x, drop_y) {
    
    // ============================================================
    // 1. 防御性检查
    // ============================================================
    if (!instance_exists(_weapon)) {
        show_debug_message("❌ scr_weapon_drop: 武器实例不存在");
        return;
    }
    
    // ============================================================
    // 2. 解除原主人绑定
    // ============================================================
    if (_weapon.owner != noone) {
        if (instance_exists(_weapon.owner)) {
            if (_weapon.owner.current_weapon == _weapon) {
                _weapon.owner.current_weapon = noone;
            }
        }
        _weapon.owner = noone;
    }
    
    // ============================================================
    // 3. 重置武器状态（回到"地上"状态）
    // ============================================================
    _weapon.x = drop_x;
    _weapon.y = drop_y;
    _weapon.is_dropped = true;          // 标记为掉落状态
    _weapon.is_swinging = false;        // 停止挥砍
    _weapon.image_angle = 0;            // 重置旋转角度
    _weapon.swing_timer = 0;            // 重置挥砍计时器
    _weapon.pickup_cooldown = 10;       // 10帧冷却（防止瞬移拾取）
    _weapon.visible = true;             // 确保可见
    
    // 销毁残留的 hitbox（如果有）
    if (instance_exists(_weapon.hitbox_ref)) {
        instance_destroy(_weapon.hitbox_ref);
        _weapon.hitbox_ref = noone;
    }
    
    // ============================================================
    // 4. 品质处理（数据驱动）
    // ============================================================
    // 如果武器还没有品质，自动生成一个
    if (_weapon.rarity == undefined || _weapon.rarity == "") {
        _weapon.rarity = generate_weapon_rarity(_weapon.weapon_id);
        var _cfg = data_rarity_get(_weapon.rarity);
        _weapon.rarity_color = _cfg.ui_color;
    }
    
    // ============================================================
    // 5. 挂载碰撞组件（触发器模式，不阻挡移动）
    // ============================================================
    var _pickup_radius = 25;  // 拾取检测半径
    
    // 设置碰撞变量（继承自 obj_collision_base）
    _weapon.collision_mask = COLLISION_LAYER.PICKUP;
    _weapon.collision_width = _pickup_radius * 2;
    _weapon.collision_height = _pickup_radius * 2;
    _weapon.collision_offset_x = 0;
    _weapon.collision_offset_y = 0;
    
    // 创建碰撞组件（is_trigger = true 表示只检测不阻挡）
    _weapon.collision_comp = scr_component_collision_create(
        _weapon,
        _weapon.collision_mask,
        _weapon.collision_width,
        _weapon.collision_height
    );
    _weapon.collision_comp.is_trigger = true;   // ★ 关键：不阻挡玩家移动
    _weapon.collision_comp.offset_x = 0;
    _weapon.collision_comp.offset_y = 0;
    
    // ============================================================
    // 6. 创建品质光晕
    // ============================================================
    scr_weapon_create_glow(_weapon);
    
    // ============================================================
    // 7. 添加到全局掉落列表（用于快速查找和清理）
    // ============================================================
    // ★ 注意：global.dropped_weapons 由 obj_game 在启动时初始化
    // 如果未初始化，此处会报错 → 请确保 obj_game 已在房间中
    var _index = ds_list_find_index(global.dropped_weapons, _weapon);
    if (_index == -1) {
        ds_list_add(global.dropped_weapons, _weapon);
    }
    
    // ============================================================
    // 8. 调试日志
    // ============================================================
    show_debug_message("✅ 武器掉落: " + string(_weapon.weapon_name) + 
                       " (" + string(_weapon.rarity) + ") 位置: (" + 
                       string(_weapon.x) + ", " + string(_weapon.y) + ")");
}

// ============================================================
// scr_weapon_create_glow - 创建品质光晕（纯视觉）
// ============================================================
/// @description 为掉落的武器创建品质光晕（独立于碰撞系统）
/// @param {instance} _weapon 武器实例
function scr_weapon_create_glow(_weapon) {
	show_debug_message("🔍 scr_weapon_create_glow 被调用");
    show_debug_message("  武器: " + string(_weapon.weapon_name));
    show_debug_message("  is_dropped: " + string(_weapon.is_dropped));
    show_debug_message("  owner: " + string(_weapon.owner));
    show_debug_message("  ⚠️ 请检查调用位置: scr_weapon_drop / scr_weapon_init / 其他");
    // ----- 1. 防御性检查 -----
    if (!instance_exists(_weapon)) return;
    
    // ----- 2. 销毁旧光晕（如果有）-----
    if (instance_exists(_weapon.glow_ref)) {
        instance_destroy(_weapon.glow_ref);
        _weapon.glow_ref = noone;
    }
    
    // ----- 3. 获取品质颜色 -----
    var _color = _weapon.rarity_color;
    if (is_undefined(_color)) {
        var _cfg = data_rarity_get(_weapon.rarity);
        _color = _cfg.ui_color;
    }
    
    // ----- 4. 确定目标图层（支持全局配置，有兜底）-----
    var _layer = "Effects";
    if (variable_global_exists("effects_layer")) {
        _layer = global.effects_layer;
    }
    // 如果图层不存在，自动创建
    if (!layer_exists(_layer)) {
        _layer = layer_create(-1, _layer);
        show_debug_message("✅ 自动创建图层: " + string(_layer));
    }
    
    // ----- 5. 准备数据（在 with 外部缓存，避免作用域问题）-----
    var _parent = _weapon;
    var _rarity = _weapon.rarity;
    
    // ----- 6. 创建光晕实例 -----
    _weapon.glow_ref = instance_create_layer(_weapon.x, _weapon.y, _layer, obj_weapon_glow);
    
    if (_weapon.glow_ref != noone) {
        with (_weapon.glow_ref) {
            // 绑定到父武器
            parent_weapon = _parent;
            
            // 品质颜色
            image_blend = _color;
            image_alpha = 0.3;
            blend_mode = bm_add;
            depth = 10;  // 渲染在武器上方（数字越小越靠上）
            
            // ★ 设置光晕基础半径（Draw 事件会根据品质调整大小）★
            // 根据品质等级调整半径
            var _quality_level = 0;
            switch (_rarity) {
                case "common":    _quality_level = 0; break;
                case "uncommon":  _quality_level = 1; break;
                case "rare":      _quality_level = 2; break;
                case "epic":      _quality_level = 3; break;
                case "legendary": _quality_level = 4; break;
                case "mythic":    _quality_level = 5; break;
                case "divine":    _quality_level = 6; break;
                default:          _quality_level = 0; break;
            }
            // 基础半径 28 + 品质加成（每级 +4）
            glow_radius = 28 + _quality_level * 4;
            
            show_debug_message("   ✨ 光晕已创建 (品质: " + string(_rarity) + ", 半径: " + string(glow_radius) + ")");
        }
    } else {
        show_debug_message("⚠️ 光晕创建失败");
    }
}


// ============================================================
// spawn_weapon_drop - 便捷函数：创建新武器并掉落
// ============================================================
/// @description 创建新武器并直接丢到地上（一键生成+掉落）
/// @param {real} _x 掉落位置 X
/// @param {real} _y 掉落位置 Y
/// @param {string} _weapon_id 武器 ID（如 "sword"）
/// @returns {instance} 创建的武器实例
function spawn_weapon_drop(_x, _y, _weapon_id) {
    
    // ----- 1. 从工厂获取武器对象 -----
    var _weapon_obj = scr_weapon_get_object_from_id(_weapon_id);
    if (_weapon_obj == noone) {
        show_debug_message("❌ spawn_weapon_drop: 找不到武器对象 '" + string(_weapon_id) + "'");
        return noone;
    }
    
    // ----- 2. 创建武器实例 -----
    var _weapon = instance_create_layer(_x, _y, "Instances", _weapon_obj);
    if (_weapon == noone) {
        show_debug_message("❌ spawn_weapon_drop: 武器实例创建失败");
        return noone;
    }
    
    // ----- 3. 调用掉落函数 -----
    scr_weapon_drop(_weapon, _x, _y);
    return _weapon;
}