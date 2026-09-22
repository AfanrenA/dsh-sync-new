// ============================================================
// scr_enemy_create_weapon - 敌人武器创建（V3 数据驱动）
// ============================================================

function scr_enemy_create_weapon(_inst) {
    show_debug_message("🔧 [1] scr_enemy_create_weapon 被调用，实例: " + string(_inst));
    
    if (!instance_exists(_inst)) {
        show_debug_message("❌ [2] 实例不存在");
        return;
    }
    if (_inst.enemy_data == undefined) {
        show_debug_message("❌ [3] enemy_data 为空");
        return;
    }
    
    var _weapon_id = _inst.enemy_data.weapon_id;
    show_debug_message("🔍 [4] weapon_id: " + string(_weapon_id));
    
    if (_weapon_id == undefined) {
        show_debug_message("❌ [5] weapon_id 未定义");
        return;
    }
    
    show_debug_message("🔧 [6] 开始创建武器实例...");
    _inst.current_weapon = instance_create_layer(_inst.x, _inst.y, "Instances", obj_weapon_base);
    
    if (!instance_exists(_inst.current_weapon)) {
        show_debug_message("❌ [7] 武器实例创建失败");
        return;
    }
    show_debug_message("✅ [8] 武器实例创建成功: " + string(_inst.current_weapon));
    
    _inst.current_weapon.weapon_id = _weapon_id;
    show_debug_message("🔧 [9] weapon_id 已设置，调用 scr_weapon_init...");
    
    scr_weapon_init(_inst.current_weapon);
    show_debug_message("✅ [10] scr_weapon_init 完成");
    
    _inst.current_weapon.owner = _inst;
    show_debug_message("✅ [11] owner 已设置");
    
    // ★ 安全显示武器精灵
    var _wdata = data_weapon_get(_weapon_id);
    show_debug_message("🔍 [12] data_weapon_get 返回: " + string(_wdata));
    
    // ★ 修复：检查 _wdata 是否有 sprite 字段
    if (_wdata != undefined && variable_struct_exists(_wdata, "sprite") && _wdata.sprite != noone) {
        _inst.current_weapon.sprite_index = _wdata.sprite;
        _inst.current_weapon.visible = true;
        show_debug_message("✅ [13] 武器精灵已设置: " + string(_wdata.sprite));
    } else {
        show_debug_message("⚠️ [14] 武器没有配置精灵: " + string(_weapon_id));
    }
    
    show_debug_message("✅ [15] scr_enemy_create_weapon 执行完成");
}