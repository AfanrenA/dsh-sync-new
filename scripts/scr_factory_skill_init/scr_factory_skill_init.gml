// scr_factory_skill_init.gml
function scr_factory_skill_init(skill_inst) {
    var _data = skill_inst.entity_data;
    if (_data == undefined) {
        show_debug_message("[SKILL INIT] 错误：entity_data 是 undefined");
        return;
    }
    
    skill_inst.rarity_color = scr_get_rarity_color(skill_inst.rarity);
    
    var _rarity_levels = ["common", "rare", "elite", "epic", "legendary", "mythic", "divine"];
    skill_inst.quality_index = 0;
    for (var i = 0; i < array_length(_rarity_levels); i++) {
        if (_rarity_levels[i] == skill_inst.rarity) {
            skill_inst.quality_index = i;
            break;
        }
    }
    
    if (variable_struct_exists(_data, "sprite") && _data.sprite != undefined && _data.sprite != noone) {
    skill_inst.sprite_index = _data.sprite;
    } else {
        skill_inst.sprite_index = noone;
    }
    
    if (skill_inst.is_on_ground) {
        scr_glow_attach(skill_inst);  // ★ 修复这里
    }
    
    show_debug_message("[SKILL INIT] 武技初始化完成: " + skill_inst.skill_id);
}