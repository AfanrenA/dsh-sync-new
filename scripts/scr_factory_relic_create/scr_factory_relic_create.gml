// scr_factory_relic_create.gml
/// @description 创建本命遗物实例（对齐 scr_factory_skill_create 写法）
/// @param {string} relic_id 遗物 ID
/// @param {string} rarity_id 品质 ID
/// @param {real} spawn_x X 坐标
/// @param {real} spawn_y Y 坐标
/// @param {id} owner_id 持有者（noone = 掉在地上）
/// @returns {id} 遗物实例
function scr_factory_relic_create(relic_id, rarity_id, spawn_x, spawn_y, owner_id = noone) {
    var _data = data_relic_get(relic_id);
    if (_data == undefined) {
        show_debug_message("[RELIC FACTORY] 遗物数据不存在: " + relic_id);
        return noone;
    }

    // ===== 品质校验（无效则回退 common）=====
    var _rarity_data = data_rarity_get(rarity_id);
    if (_rarity_data == undefined) {
        show_debug_message("[RELIC FACTORY] 品质数据不存在: " + string(rarity_id) + "，回退 common");
        rarity_id = "common";
        _rarity_data = data_rarity_get("common");
        if (_rarity_data == undefined) return noone;
    }

    // ===== 从数据表读对象 =====
    var _obj = obj_relic_base;
    if (variable_struct_exists(_data, "object") && _data.object != undefined) {
        _obj = _data.object;
    }

    var inst = instance_create_layer(spawn_x, spawn_y, "Instances", _obj);
    if (!instance_exists(inst)) return noone;

    // ===== 基础字段（对齐 skill / agility 工厂）=====
    inst.relic_id = relic_id;
    inst.rarity = rarity_id;
    inst.entity_data = _data;
    inst.rarity_data = _rarity_data;
    inst.display_name = _data.display_name;
    inst.owner_id = owner_id;
    inst.is_on_ground = (owner_id == noone || owner_id == -4);

    // ===== 品质索引（0~6，对齐 rarity tier - 1）=====
    inst.quality_index = clamp(_rarity_data.tier - 1, 0, 6);

    // ===== 主动脚本名（从数据表拷到实例，方便读取）=====
    inst.active_script = variable_struct_exists(_data, "active_script") ? _data.active_script : "";

    // ===== 精灵 =====
    if (variable_struct_exists(_data, "sprite") && _data.sprite != undefined && _data.sprite != noone) {
        inst.sprite_index = _data.sprite;
    }

    // ===== 品质颜色 =====
    inst.rarity_color = scr_get_rarity_color(rarity_id);

    // ===== 地上 → 挂光晕 =====
    if (inst.is_on_ground) {
        scr_glow_attach(inst);
    }

    show_debug_message("[RELIC FACTORY] 创建: " + relic_id + " | 品质: " + rarity_id + " | 对象: " + object_get_name(_obj));
    return inst;
}