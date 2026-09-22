// 武器初始化函数
function scr_factory_weapon_init(weapon_inst) {
    // ===== 先获取数据 =====
    var _data = weapon_inst.entity_data;
    if (_data == undefined) {
        show_debug_message("[FACTORY INIT] 错误：entity_data 是 undefined");
        return;
    }
    
    // ===== 基础变量 =====
    weapon_inst.cooldown_timer = 0;
    weapon_inst.can_attack = true;
    weapon_inst.is_swinging = false;
    weapon_inst.swing_timer = 0;
    weapon_inst.slash_pending = false;
    weapon_inst.slash_delay_frames = 0;
    weapon_inst.pickup_hint_visible = false;
    
    // ===== 持有者 =====
    weapon_inst._owner = weapon_inst.owner_id ?? noone;
    
    // ===== 攻击脚本（从数据表读取） =====
    weapon_inst.attack_script = _data.attack_behavior;
    
    // ===== 挥砍参数（近战专属，用 variable_struct_exists 兜底） =====
    weapon_inst.swing_total_frames = variable_struct_exists(_data, "swing_total_frames") ? _data.swing_total_frames : 15;
    weapon_inst.swing_angle_range = variable_struct_exists(_data, "swing_angle_range") ? _data.swing_angle_range : 60;
    
    // ===== ★ 远程武器专属初始化（有 max_ammo 字段才执行） =====
    if (variable_struct_exists(_data, "max_ammo")) {
        weapon_inst.max_ammo = _data.max_ammo;
        weapon_inst.current_ammo = _data.max_ammo;
        weapon_inst.is_reloading = false;
        weapon_inst.reload_progress = 0;
        weapon_inst.reload_timer = 0;
        weapon_inst.reload_time_per_bullet = variable_struct_exists(_data, "reload_time_per_bullet") ? _data.reload_time_per_bullet : 30;
        weapon_inst.fire_mode = variable_struct_exists(_data, "fire_mode") ? _data.fire_mode : "auto";
        weapon_inst.recoil_timer = 0;
        weapon_inst.recoil_offset = 0;
        weapon_inst.recoil_angle = 0;
    }
    
    show_debug_message("[FACTORY INIT] 武器初始化完成: " + weapon_inst.weapon_id + " | 攻击脚本: " + _data.attack_behavior);
}