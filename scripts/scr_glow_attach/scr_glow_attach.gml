/// @function scr_glow_attach(item_ref)
/// @param {id} item_ref - 武器或技能实例
/// @description 为地面物品挂载品质光晕

function scr_glow_attach(item_ref) {
    if (!instance_exists(item_ref)) return;
    if (!item_ref.is_on_ground) return;
    
    var _rarity = item_ref.rarity;
    if (_rarity == undefined || _rarity == "") return;
    
    var _color = scr_get_rarity_color(_rarity);
    if (_color == noone || _color == undefined) {
        _color = c_white;
    }
    item_ref.rarity_color = _color;
    
    // 如果已有光晕，先销毁
    if (instance_exists(item_ref.glow_ref)) {
        with (item_ref.glow_ref) {
            instance_destroy();
        }
        item_ref.glow_ref = noone;
    }
    
    if (!layer_exists("Effects")) {
        layer_create(-1, "Effects");
    }
    
    var _glow = instance_create_layer(item_ref.x, item_ref.y, "Effects", obj_weapon_glow);
    if (instance_exists(_glow)) {
        _glow.parent_weapon = item_ref;
        
        // ★★★ 关键：把光晕引用赋值给物品 ★★★
        item_ref.glow_ref = _glow;
        
        var _rarity_levels = {
            common: 0, rare: 1, elite: 2, epic: 3, legendary: 4, mythic: 5, divine: 6
        };
        var _level = _rarity_levels[$ _rarity] != undefined ? _rarity_levels[$ _rarity] : 0;
        _glow.glow_radius = 28 + _level * 4;
        _glow.depth = 110;
        _glow.pulse_timer = random(6.28);
        
        show_debug_message("[GLOW] 光晕已挂载，glow_ref = " + string(_glow));
    }
}