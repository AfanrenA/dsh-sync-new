// ======================================================================
// data_rarity.gml
// 品质（稀有度）系统 - 数据配置
// ======================================================================
// V3 数据驱动原则：
//   1. 所有品质定义集中管理
//   2. 7种品质对应7种UI颜色
//   3. 权重用于随机抽取
// ======================================================================

// ============================================================
// 1. 等级 → 品质名称 转换函数
// ============================================================
// 等级 1-7 对应 7 个品质，数字越大越稀有
// 1=普通, 2=稀有, 3=精英, 4=史诗, 5=传说, 6=神话, 7=神圣
// ============================================================

/// @description 将等级（1-7）转换为品质名称
/// @param {real} _level 等级（1-7）
/// @returns {string} 品质名称（如 "epic"）
function get_quality_name(_level) {
    var _safe_level = clamp(_level, 1, 7);
    
    switch (_safe_level) {
        case 1: return "common";
        case 2: return "rare";
        case 3: return "elite";
        case 4: return "epic";
        case 5: return "legendary";
        case 6: return "mythic";
        case 7: return "divine";
        default: return "common";
    }
}

// ============================================================
// 2. 品质定义表（7种品质，7种颜色）
// ============================================================
// 每个品质包含：
//   - name: 显示名称（中文）
//   - ui_color: UI显示颜色（GameMaker颜色常量）
//   - weight: 权重（值越大出现概率越高）
// ============================================================

/// @description 根据品质名称获取品质配置
/// @param {string} _quality 品质名称（如 "epic"）
/// @returns {struct} 品质配置对象
function data_rarity_get(_quality) {
    // ★ 7种品质，7种颜色 ★
    var _data = {
        common:   { name: "普通",   ui_color: c_gray,   weight: 100 },
        rare:     { name: "稀有",   ui_color: c_lime,   weight: 60 },
        elite:    { name: "精英",   ui_color: c_blue,   weight: 30 },
        epic:     { name: "史诗",   ui_color: c_purple, weight: 15 },
        legendary:{ name: "传说",   ui_color: c_orange, weight: 5 },
        mythic:   { name: "神话",   ui_color: c_red,    weight: 2 },
        divine:   { name: "神圣",   ui_color: c_aqua,   weight: 1 }
    };

    var _result = _data[$ _quality];
    if (is_undefined(_result)) {
        show_debug_message("⚠️ 品质未定义: " + string(_quality) + "，使用默认值 common");
        return _data[$ "common"];
    }
    return _result;
}

// ============================================================
// 3. 品质生成函数
// ============================================================
// 每把武器在 data_weapon.gml 中定义：
//   - quality_base: 基础等级（1-7）
//   - quality_offset: 偏移量
// 最终品质范围 = [base - offset, base + offset]
// ============================================================

/// @description 根据武器ID生成随机品质
/// @param {string} _weapon_id 武器ID（如 "sword"）
/// @returns {string} 品质名称
function generate_weapon_rarity(_weapon_id) {
    // 1. 获取武器数据
    var _data = data_weapon_get(_weapon_id);
    if (_data == undefined) {
        show_debug_message("⚠️ generate_weapon_rarity: 武器数据不存在: " + string(_weapon_id));
        return "common";
    }

    // 2. 读取品质参数
    var _base = real(_data.quality_base);
    var _offset = real(_data.quality_offset);

    // 3. 验证参数有效性
    if (is_nan(_base) || _base <= 0) {
        _base = 2;
        show_debug_message("   quality_base 无效，使用默认值: 2");
    }
    if (is_nan(_offset) || _offset < 0) {
        _offset = 1;
        show_debug_message("   quality_offset 无效，使用默认值: 1");
    }

    // 限制范围
    _base = clamp(_base, 1, 7);
    _offset = clamp(_offset, 0, 6);

    // 4. 计算等级范围并随机抽取
    var _min = max(1, _base - _offset);
    var _max = min(7, _base + _offset);
    var _level = irandom_range(_min, _max);

    // 5. 转换为品质名称
    var _result = get_quality_name(_level);
    show_debug_message("   🎲 生成品质: " + string(_result) + " (等级: " + string(_level) + ")");
    return _result;
}

// ============================================================
// 4. 快捷工具函数
// ============================================================

/// @description 根据品质名称获取UI颜色
function get_rarity_color(_quality) {
    var _cfg = data_rarity_get(_quality);
    return _cfg.ui_color;
}

/// @description 根据品质名称获取显示名称（中文）
function get_rarity_name(_quality) {
    var _cfg = data_rarity_get(_quality);
    return _cfg.name;
}