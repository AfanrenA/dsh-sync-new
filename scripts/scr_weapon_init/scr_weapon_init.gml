/// @description 武器初始化工厂函数（只负责赋值，不负责声明）
/// @param {instance} _weapon 武器实例
function scr_weapon_init(_weapon) {
    show_debug_message("🔧 scr_weapon_init 被调用，weapon_id = " + string(_weapon.weapon_id));
    // ============================================================
    // 1. 防御性检查
    // ============================================================
    if (!instance_exists(_weapon)) {
        show_debug_message("❌ scr_weapon_init: 武器实例不存在");
        return;
    }
    
    if (!variable_instance_exists(_weapon, "weapon_id") || _weapon.weapon_id == "") {
        show_debug_message("❌ scr_weapon_init: weapon_id 未设置");
        return;
    }
    
    // ============================================================
    // 2. 从数据表读取武器数据
    // ============================================================
    var _data = data_weapon_get(_weapon.weapon_id);
    if (_data == undefined) {
        show_debug_message("❌ scr_weapon_init: 武器数据不存在: " + string(_weapon.weapon_id));
        return;
    }
    
    // ============================================================
    // 3. 给实例赋值所有变量（数据驱动）
    // ============================================================
    
    // ---- 3.1 基础属性 ----
_weapon.weapon_name = _data.name;
_weapon.weapon_type = _data.type;
_weapon.damage = _data.damage;
_weapon.cooldown = _data.cooldown;

// ★★★ 修复：保留正在进行的冷却，不要重置 ★★★
// 只有 attack_cooldown 不存在或已经归零时才重置
if (!variable_instance_exists(_weapon, "attack_cooldown") || _weapon.attack_cooldown <= 0) {
    _weapon.attack_cooldown = 0;
}
// 如果 attack_cooldown > 0，保持原值（武器正在冷却中）
    
    // ---- 3.2 品质参数 ----
    _weapon.quality_base = _data.quality_base;
    _weapon.quality_offset = _data.quality_offset;
    
    // ---- 3.3 近战参数 ----
    _weapon.swing_total_frames = struct_exists(_data, "swing_total_frames") ? _data.swing_total_frames : 10;
    _weapon.swing_angle_range = struct_exists(_data, "swing_angle_range") ? _data.swing_angle_range : 60;
    _weapon.swing_distance = struct_exists(_data, "swing_distance") ? _data.swing_distance : 25;
    
    // ---- 3.4 剑气参数 ----
    _weapon.slash_sprite = struct_exists(_data, "slash_sprite") ? _data.slash_sprite : noone;
    _weapon.slash_speed = struct_exists(_data, "slash_speed") ? _data.slash_speed : 8;
    _weapon.slash_life = struct_exists(_data, "slash_life") ? _data.slash_life : 30;
    _weapon.slash_scale_start = struct_exists(_data, "slash_scale_start") ? _data.slash_scale_start : 0.5;
    _weapon.slash_scale_end = struct_exists(_data, "slash_scale_end") ? _data.slash_scale_end : 2.0;
    
    // ---- 3.5 碰撞盒参数 ----
    _weapon.hitbox_life = struct_exists(_data, "hitbox_life") ? _data.hitbox_life : 12;
    _weapon.hitbox_radius = struct_exists(_data, "hitbox_radius") ? _data.hitbox_radius : 25;
    _weapon.can_deflect = struct_exists(_data, "can_deflect") ? _data.can_deflect : false;
    _weapon.hitbox_offset_x = struct_exists(_data, "hitbox_offset_x") ? _data.hitbox_offset_x : 0;
    _weapon.hitbox_offset_y = struct_exists(_data, "hitbox_offset_y") ? _data.hitbox_offset_y : 0;
    
    // ---- 3.6 远程参数 ----
    _weapon.bullet_sprite = struct_exists(_data, "bullet_sprite") ? _data.bullet_sprite : noone;
    _weapon.bullet_speed = struct_exists(_data, "bullet_speed") ? _data.bullet_speed : 12;
    _weapon.bullet_life = struct_exists(_data, "bullet_life") ? _data.bullet_life : 60;
    _weapon.visual_recoil = struct_exists(_data, "visual_recoil") ? _data.visual_recoil : 0;
    _weapon.physical_recoil = struct_exists(_data, "physical_recoil") ? _data.physical_recoil : 0;
    _weapon.recoil_strength = struct_exists(_data, "recoil_strength") ? _data.recoil_strength : 0;
    
    // ---- 3.6.2 弹匣参数 ----
    if (struct_exists(_data, "burst_max")) {
        _weapon.burst_max = _data.burst_max;
        _weapon.magazine_max = _data.burst_max;
        _weapon.magazine_current = _data.burst_max;
    } else {
        _weapon.burst_max = 0;
        _weapon.magazine_max = 0;
        _weapon.magazine_current = 0;
    }
    _weapon.burst_interval = struct_exists(_data, "burst_interval") ? _data.burst_interval : 3;
    _weapon.burst_cooldown = struct_exists(_data, "burst_cooldown") ? _data.burst_cooldown : 60;
    
    // ---- 3.7 投掷参数 ----
    _weapon.throw_speed = struct_exists(_data, "throw_speed") ? _data.throw_speed : 8;
    _weapon.throw_gravity = struct_exists(_data, "throw_gravity") ? _data.throw_gravity : 0.15;
    _weapon.throw_life = struct_exists(_data, "throw_life") ? _data.throw_life : 60;
    _weapon.projectile_obj = struct_exists(_data, "projectile_obj") ? _data.projectile_obj : noone;
    
    // ---- 元素 ----
    _weapon.element = struct_exists(_data, "element") ? _data.element : "";
    _weapon.element_dot_damage = struct_exists(_data, "element_dot_damage") ? _data.element_dot_damage : 0;
    _weapon.element_dot_duration = struct_exists(_data, "element_dot_duration") ? _data.element_dot_duration : 0;
    _weapon.element_damage = struct_exists(_data, "element_damage") ? _data.element_damage : 0;
    _weapon.trail_color = struct_exists(_data, "trail_color") ? _data.trail_color : c_white;
    _weapon.stick_duration = struct_exists(_data, "stick_duration") ? _data.stick_duration : 600;
    
    // ---- 爆炸 ----
    _weapon.is_explosive = struct_exists(_data, "is_explosive") ? _data.is_explosive : false;
    _weapon.explosion_delay = struct_exists(_data, "explosion_delay") ? _data.explosion_delay : 30;
    _weapon.explosion_radius = struct_exists(_data, "explosion_radius") ? _data.explosion_radius : 80;
    _weapon.explosion_damage = struct_exists(_data, "explosion_damage") ? _data.explosion_damage : 20;
    _weapon.warning_radius = struct_exists(_data, "warning_radius") ? _data.warning_radius : 120;
    _weapon.warning_duration = struct_exists(_data, "warning_duration") ? _data.warning_duration : 90;
    _weapon.warning_alpha = struct_exists(_data, "warning_alpha") ? _data.warning_alpha : 0.25;
    _weapon.warning_scale_start = struct_exists(_data, "warning_scale_start") ? _data.warning_scale_start : 0.3;
    
    // ---- 流血 ----
    _weapon.bleed_damage = struct_exists(_data, "bleed_damage") ? _data.bleed_damage : 0;
    _weapon.bleed_duration = struct_exists(_data, "bleed_duration") ? _data.bleed_duration : 0;
    _weapon.bleed_interval = struct_exists(_data, "bleed_interval") ? _data.bleed_interval : 15;
    _weapon.pierce = struct_exists(_data, "pierce") ? _data.pierce : false;
    
    // ============================================================
    // 4. 生成品质
    // ============================================================
    if (_weapon.rarity == "" || _weapon.rarity == "common") {
        _weapon.rarity = generate_weapon_rarity(_weapon.weapon_id);
        show_debug_message("   🎲 生成品质: " + string(_weapon.rarity));
    } else {
        show_debug_message("   📌 使用外部指定品质: " + string(_weapon.rarity));
    }
    
    var _cfg = data_rarity_get(_weapon.rarity);
    _weapon.rarity_color = (_cfg != undefined) ? _cfg.ui_color : c_white;
    if (_cfg == undefined) {
        show_debug_message("⚠️ 品质配置不存在: " + string(_weapon.rarity));
    }
    
    // ============================================================
    // 5. 绑定攻击行为（脚本引用）
    // ============================================================
    var _attack_map = {
        "melee": scr_attack_melee,
        "hack": scr_attack_hack,
        "ranged": scr_attack_ranged,
        "thrown": scr_attack_thrown
    };
    _weapon.attack_behavior = _attack_map[$ _weapon.weapon_type];
    
    if (!script_exists(_weapon.attack_behavior)) {
        show_debug_message("⚠️ 未知攻击类型: " + string(_weapon.weapon_type) + "，使用默认近战");
        _weapon.attack_behavior = scr_attack_melee;
    } else {
        show_debug_message("   🔗 攻击行为: " + script_get_name(_weapon.attack_behavior));
    }
    
    // ============================================================
    // 6. ★★★ 按武器类型绑定方法集 ★★★
    // ============================================================
    switch (_weapon.weapon_type) {
        case "melee":
        case "hack":
            scr_weapon_methods_melee(_weapon);
            break;
            
        case "ranged":
            scr_weapon_methods_ranged(_weapon);
            break;
            
        case "thrown":
            scr_weapon_methods_thrown(_weapon);
            break;
            
        default:
            // 未知类型：默认使用近战方法集
            show_debug_message("⚠️ 未知武器类型: " + string(_weapon.weapon_type) + "，使用近战方法集");
            scr_weapon_methods_melee(_weapon);
            break;
    }
    
    // ============================================================
    // 7. 地图武器自动初始化
    // ============================================================
    if (_weapon.owner == noone && !_weapon.is_dropped) {
        _weapon.is_dropped = true;
        scr_weapon_create_glow(_weapon);
        show_debug_message("📍 地图武器自动初始化: " + string(_weapon.weapon_name) + 
                           " (" + string(_weapon.rarity) + ")");
    }
    
    // ============================================================
    // 8. 最终日志
    // ============================================================
    show_debug_message("🏹 武器创建完成: " + string(_weapon.weapon_name) + 
                       " (" + string(_weapon.rarity) + ") [类型: " + string(_weapon.weapon_type) + "]");
}