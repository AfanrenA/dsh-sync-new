// save_player.gml
// 玩家存档系统：默认结构、读取、更新

/// @description 返回默认的玩家存档数据结构
function save_player_default() {
    var _save = {
        // ===== 玩家状态 =====
        hp: 100,
        max_hp: 100,
        defense: 0,
        attack_power: 10,
        attack_speed: 1.0,
        
        // ===== 位置 =====
        x: 480,
        y: 350,
        current_room: "room_test",
        
        // ===== 武器 =====
        current_weapon: "sword",
        unlocked_weapons: ["sword"],
        
        // ===== 遗物和进度 =====
        relics: [],          // ★ 删除了重复定义
        skills: [],
        progress: {
            cleared_levels: [],
            defeated_bosses: []
        }
    };
    return _save;
}

/// @description 从全局存档中读取玩家数据
function save_player_get() {
    if (!variable_global_exists("save_data") || global.save_data == undefined) {
        show_debug_message("[WARNING] 存档数据不存在，使用默认值");
        return save_player_default();
    }
    return global.save_data;
}

/// @description 从玩家对象更新存档数据
function save_player_update() {
    // 初始化全局存档
    if (!variable_global_exists("save_data") || global.save_data == undefined) {
        global.save_data = save_player_default();
    }
    
    // ★ 使用 instance_exists 配合 obj_player 直接访问 ★
    // 注意：如果有多个玩家实例，需要使用其他方式获取
    var _player = obj_player;
    if (!instance_exists(_player)) {
        show_debug_message("[WARNING] save_player_update: 玩家对象不存在");
        return;
    }
    
    // ===== 更新玩家状态 =====
    global.save_data.hp = _player.hp;
    global.save_data.max_hp = _player.max_hp;
    global.save_data.defense = _player.defense;
    global.save_data.attack_power = _player.attack_power;
    global.save_data.attack_speed = _player.attack_speed;
    
    // ===== 更新位置 =====
    global.save_data.x = _player.x;
    global.save_data.y = _player.y;
    global.save_data.current_room = room_get_name(room);
    
    // ===== ★ 安全更新武器（处理 undefined 情况）★ =====
    if (_player.current_weapon != undefined && instance_exists(_player.current_weapon)) {
        global.save_data.current_weapon = _player.current_weapon.weapon_id;
    } else {
        // 如果没有武器，保留默认值
        if (global.save_data.current_weapon == undefined) {
            global.save_data.current_weapon = "sword";
        }
    }
    
    show_debug_message("[DEBUG] 存档已更新: HP=" + string(global.save_data.hp) + 
                       " 防御=" + string(global.save_data.defense) +
                       " 位置=(" + string(global.save_data.x) + ", " + string(global.save_data.y) + ")");
}