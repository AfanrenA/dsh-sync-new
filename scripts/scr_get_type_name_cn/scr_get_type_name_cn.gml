/// @function scr_get_type_name_cn(type_key)
/// @param {string} type_key 英文类型键
/// @returns {string} 中文类型名
function scr_get_type_name_cn(type_key) {
    var _map = {
        // 武器类型
        "melee": "剑",
        "hack": "重兵器",
        "ranged": "远程",
        "thrown": "投掷",
        
        // 武技槽
        "skill": "武技",
        "agility": "身法",
        
        // 品质
        "common": "普通",
        "rare": "稀有",
        "elite": "精英",
        "epic": "史诗",
        "legendary": "传说",
        "mythic": "神话",
        "divine": "神圣",
    };
    
    if (variable_struct_exists(_map, type_key)) {
        return _map[$ type_key];
    }
    return type_key;   // 找不到就返回原值
}