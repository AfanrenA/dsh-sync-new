// scr_factory_agility_init.gml
function scr_factory_agility_init(agility_inst) {
    var _data = agility_inst.entity_data;
    if (_data == undefined) return;
    
    agility_inst.rarity_color = scr_get_rarity_color(agility_inst.rarity);
    
    var _rarity_levels = ["common", "rare", "elite", "epic", "legendary", "mythic", "divine"];
    agility_inst.quality_index = 0;
    for (var i = 0; i < array_length(_rarity_levels); i++) {
        if (_rarity_levels[i] == agility_inst.rarity) {
            agility_inst.quality_index = i;
            break;
        }
    }
    
    // ★ 安全读 sprite（结构体无此键也不崩）
    if (variable_struct_exists(_data, "sprite") && _data.sprite != undefined && _data.sprite != noone) {
        agility_inst.sprite_index = _data.sprite;
    }
    // ★ 无 sprite 时保留对象自带 sprite_index，不覆盖
    
    if (agility_inst.is_on_ground) {
        scr_glow_attach(agility_inst);
    }
    
    show_debug_message("[AGILITY INIT] 身法初始化完成: " + agility_inst.agility_id);
}