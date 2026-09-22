/// @description 绘制信息卡片（武器/遗物/武技/身法）
/// @param {id} _player 玩家实例

function scr_draw_ui_infocards(_player) {
    if (!instance_exists(_player)) return;
    
    // ====================================================================
    // 1. 获取数据
    // ====================================================================
    
    // ---- 武器数据 ----
    var _display_name = "赤手空拳";
    var _weapon_color = c_white;
    if (instance_exists(_player.current_weapon)) {
        var _w = _player.current_weapon;
        var _weapon_data = data_weapon_get(_w.weapon_id);
        if (_weapon_data != undefined) {
            _display_name = _weapon_data.display_name != undefined ? _weapon_data.display_name : "未知武器";
        }
        var _rarity = _w.rarity != undefined ? _w.rarity : "common";
        _weapon_color = scr_get_rarity_color(_rarity);
    }
    
    // ---- 遗物数据 ----
    // ★ 修正：原来读 _player.relics[0]（该变量在工程里根本不存在），
    //   实际单槽字段是 _player.relic_slot；名字字段是 display_name（不是 relic_name）
    var _relic_name = "身无长物";
    var _relic_border_color = c_white;
    var _relic_text_color = c_white;
    var _relic_cooldown = 1;
    var _relic_ready = false;
    var _relic_equipped = false;

    if (variable_instance_exists(_player, "relic_slot") && instance_exists(_player.relic_slot)) {
        var _r = _player.relic_slot;
        var _relic_id = variable_instance_exists(_r, "relic_id") ? _r.relic_id : "";
        var _relic_data = data_relic_get(_relic_id);

        if (_relic_data != undefined) {
            _relic_equipped = true;
            _relic_name = (_relic_data.display_name != undefined) ? _relic_data.display_name : "未知遗物";

            var _relic_rarity = variable_instance_exists(_r, "rarity") ? _r.rarity : "common";
            var _relic_color = scr_get_rarity_color(_relic_rarity);

            // ★ 遗物不做武器兼容判断，直接显示品质色（与身法一致）
            _relic_border_color = _relic_color;
            _relic_text_color = _relic_color;

            // ★ 冷却：与武技/身法同算法（品质冷却倍率 × 基础冷却）
            var _relic_qi = variable_instance_exists(_r, "quality_index") ? _r.quality_index : 0;
            var _relic_cd_mult = data_relic_get_quality_mult(_relic_id, _relic_qi, "quality_cooldown_mult");
            var _relic_cd_max = (_relic_data.cooldown != undefined ? _relic_data.cooldown : 60) * 60 * _relic_cd_mult;

            if (variable_instance_exists(_r, "cooldown_timer") && _r.cooldown_timer > 0 && _relic_cd_max > 0) {
                _relic_cooldown = 1 - (_r.cooldown_timer / _relic_cd_max);
                _relic_cooldown = clamp(_relic_cooldown, 0, 1);
                _relic_ready = false;
            } else {
                _relic_cooldown = 1;
                _relic_ready = true;
            }
        }
    }
    
    // ---- 武技数据 ----
    var _skill_name = "一无所长";
    var _skill_border_color = c_white;
    var _skill_text_color = c_white;
    var _skill_cooldown = 1;
    var _skill_ready = false;
    var _skill_equipped = false;
    
    if (_player.skill_slot != noone && _player.skill_slot != "") {
        _skill_equipped = true;
        var _skill_data = data_skill_get(_player.skill_slot);
        if (_skill_data != undefined) {
            _skill_name = _skill_data.display_name != undefined ? _skill_data.display_name : "未知武技";
            var _rarity = _player.skill_instance.rarity != undefined ? _player.skill_instance.rarity : "common";
            var _color = scr_get_rarity_color(_rarity);
            
            var _compatible = scr_skill_is_compatible(_player.skill_slot, _player.current_weapon);
            if (_compatible) {
                _skill_border_color = _color;
                _skill_text_color = _color;
            } else {
                _skill_border_color = c_gray;
                _skill_text_color = _color;
            }
            
            var _cooldown_max = (_skill_data.base_cooldown != undefined ? _skill_data.base_cooldown : 3) * 60;
            if (instance_exists(_player.skill_instance) && _player.skill_instance.cooldown_timer > 0) {
    _skill_cooldown = 1 - (_player.skill_instance.cooldown_timer / _cooldown_max);
                _skill_cooldown = clamp(_skill_cooldown, 0, 1);
                _skill_ready = false;
            } else {
                _skill_cooldown = 1;
                _skill_ready = true;
            }
        }
    }
    
        // ---- 身法数据 ----
    var _agility_name = "凡夫俗子";
    var _agility_border_color = c_white;
    var _agility_text_color = c_white;
    var _agility_cooldown = 1;
    var _agility_ready = false;
    var _agility_equipped = false;
    
    if (_player.agility_slot != noone && _player.agility_slot != "") {
        _agility_equipped = true;
        var _agility_data = data_agility_get(_player.agility_slot);
        if (_agility_data != undefined) {
            _agility_name = _agility_data.display_name != undefined ? _agility_data.display_name : "未知身法";
            var _agility_rarity = (instance_exists(_player.agility_instance) && _player.agility_instance.rarity != undefined) ? _player.agility_instance.rarity : "common";
            var _color = scr_get_rarity_color(_agility_rarity);
            
            // ★ 身法不做武器兼容判断，直接显示品质色
            _agility_border_color = _color;
            _agility_text_color = _color;
            
            var _cooldown_max = (_agility_data.cooldown != undefined ? _agility_data.cooldown : 120);
            if (instance_exists(_player.agility_instance) && _player.agility_instance.cooldown_timer > 0) {
                _agility_cooldown = 1 - (_player.agility_instance.cooldown_timer / _cooldown_max);
                _agility_cooldown = clamp(_agility_cooldown, 0, 1);
                _agility_ready = false;
            } else {
                _agility_cooldown = 1;
                _agility_ready = true;
            }
        }
    }
    
    // ====================================================================
    // 2. 配置UI位置
    // ====================================================================
    
    var _x = 20;
    var _y = 68;
    var _w = 95;
    var _h = 24;
    var _gap = 6;
    
    // ====================================================================
    // 3. 绘制4张卡片（传入 flash_timer）
    // ====================================================================
    
    // 武器（不允许闪烁）
    scr_draw_ui_card(_x + 0 * (_w + _gap), _y, _w, _h, _display_name, _weapon_color, _weapon_color, 1, 0, false);
    // 遗物（允许闪烁 + 显示冷却，与武技/身法一致；passive 槽没有 flash_timer 时兜底 0）
    var _relic_flash = variable_instance_exists(_player, "relic_flash_timer") ? _player.relic_flash_timer : 0;
    scr_draw_ui_card(_x + 1 * (_w + _gap), _y, _w, _h, _relic_name, _relic_border_color, _relic_text_color, _relic_cooldown, _relic_flash, true);
    // 武技（允许闪烁，传入 flash_timer）
    scr_draw_ui_card(_x + 2 * (_w + _gap), _y, _w, _h, _skill_name, _skill_border_color, _skill_text_color, _skill_cooldown, _player.skill_flash_timer, true);
    // 身法（允许闪烁，传入 flash_timer）
    scr_draw_ui_card(_x + 3 * (_w + _gap), _y, _w, _h, _agility_name, _agility_border_color, _agility_text_color, _agility_cooldown, _player.agility_flash_timer, true);
}