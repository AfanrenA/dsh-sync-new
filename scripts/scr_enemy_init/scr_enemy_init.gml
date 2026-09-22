// ============================================================
// scr_enemy_init - 敌人统一初始化（V3 数据驱动）
// ============================================================

function scr_enemy_init(_inst, _type, _quality = "common", _level_scale = 1.0) {
    if (!instance_exists(_inst)) return;
    
    var _data = data_enemy_get(_type);
    if (_data == undefined) {
        show_debug_message("⚠️ 敌人类型不存在: " + string(_type));
        return;
    }
    
    with (_inst) {
        // ---- 基础属性 ----
        enemy_type = _type;
        enemy_data = _data;
        hp = _data.hp * _level_scale;
        max_hp = hp;
        move_speed = _data.speed;
        
        // ---- AI 参数 ----
        aggro_range = _data.aggro_range;
        attack_range = _data.attack_range;
        retreat_range = _data.retreat_range;
        ai_decision_interval = _data.decision_interval;
        ai_decision_timer = 0;
        ai_state = "idle";
        ai_target = noone;
        
        // ---- ★★★ 创建武器 ★★★ ----
var _weapon_id = _data.weapon_id;
if (_weapon_id != undefined) {
   current_weapon = instance_create_layer(x, y, "Instances", obj_weapon_base);
current_weapon.is_dropped = false;
current_weapon.owner = noone;
current_weapon.weapon_id = _weapon_id;
scr_weapon_init(current_weapon);
current_weapon.owner = id;

// ★ 设置武器精灵
var _wdata = data_weapon_get(_weapon_id);
if (_wdata != undefined && variable_struct_exists(_wdata, "sprite") && _wdata.sprite != noone) {
    current_weapon.sprite_index = _wdata.sprite;
    current_weapon.visible = true;
} else {
    // ★ 如果没有配置武器精灵，使用敌人自己的精灵（或者隐藏武器）
    current_weapon.sprite_index = -1;
    current_weapon.visible = false;  // 没有精灵就隐藏
}
    show_debug_message("🗡️ 武器创建: " + string(_weapon_id));
}
        
        // ---- 其他 ----
        drop_table = _data.drop_table;
        exp_reward = _data.exp_reward * _level_scale;
        who = _data.who;
        
        show_debug_message("👾 敌人生成: " + string(_data.label) + " HP: " + string(hp));
    }
}