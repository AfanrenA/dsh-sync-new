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

// ============================================================
// CJK 安全折行（放在本文件里，避免新增资源导致 .yyp 未登记 → 编译找不到函数）
// ============================================================
/// @function scr_text_wrap_cjk(text, max_width, respect_spaces)
/// @description CJK 安全的按宽度折行（把文本拆成多行数组）
/// @param {string} text        原始文本（可含 \n 手动换行）
/// @param {real}   max_width   可用像素宽度
/// @param {bool}   respect_spaces  true=英文按空格断词优先（不切断单词）
/// @returns {array<string>}    折行后的行数组
///
/// ★ 为什么需要这个：GameMaker 的 draw_text_ext / string_height_ext 自动换行
///   **只按空格断词**（官方 issue YoYoGames/GameMaker-Bugs #11569）。
///   中文描述没有空格 → 整段找不到断点 → 一个字都不换 → 溢出框。
///   所以中文必须自己按"逐字累加宽度"来折行。
///
/// 用法：
///   var _lines = scr_text_wrap_cjk(_desc, _desc_w, false);
///   for (var i = 0; i < array_length(_lines); i++)
///       draw_text(_x, _y + i * _line_h, _lines[i]);
function scr_text_wrap_cjk(text, max_width, respect_spaces = false) {
    var _lines = [];

    if (text == undefined || !is_string(text)) return _lines;
    if (max_width <= 0) return [text];

    // 先处理手动换行（数据表里可能写 "\n"）
    var _paragraphs = string_split(text, "\n");

    for (var p = 0; p < array_length(_paragraphs); p++) {
        var _para = _paragraphs[p];

        if (string_length(_para) <= 0) {
            array_push(_lines, "");
            continue;
        }

        // 整段就放得下 → 直接一行
        if (string_width(_para) <= max_width) {
            array_push(_lines, _para);
            continue;
        }

        var _cur = "";          // 当前累积的行
        var _len = string_length(_para);

        for (var i = 1; i <= _len; i++) {
            var _ch = string_char_at(_para, i);
            var _candidate = _cur + _ch;

            if (string_width(_candidate) > max_width) {
                // 放不下了 → 收行
                if (respect_spaces && string_length(_cur) > 0) {
                    // 英文模式：回退到最后一个空格，把半个单词挪到下一行
                    var _last_space = 0;
                    for (var k = string_length(_cur); k >= 1; k--) {
                        if (string_char_at(_cur, k) == " ") {
                            _last_space = k;
                            break;
                        }
                    }
                    if (_last_space > 1) {
                        var _keep  = string_copy(_cur, 1, _last_space - 1);
                        var _carry = string_copy(_cur, _last_space + 1, string_length(_cur) - _last_space);
                        if (string_length(_keep) > 0) {
                            array_push(_lines, _keep);
                            _cur = _carry + _ch;
                        } else {
                            array_push(_lines, _cur);
                            _cur = _ch;
                        }
                    } else {
                        array_push(_lines, _cur);
                        _cur = _ch;
                    }
                } else {
                    // ★ 中文模式：逐字断行（CJK 可以在任意字之间断）
                    array_push(_lines, _cur);
                    _cur = _ch;
                }
            } else {
                _cur = _candidate;
            }
        }

        if (string_length(_cur) > 0) {
            array_push(_lines, _cur);
        }
    }

    return _lines;
}