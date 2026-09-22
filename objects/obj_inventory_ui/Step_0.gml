// obj_inventory_ui Step 事件

// ===== 1. 跟随玩家 =====
var _player_tmp = instance_find(obj_player_base, 0);
if (instance_exists(_player_tmp)) {
    is_open = _player_tmp.inventory_ui_open;
} else {
    is_open = false;
}

// ===== 2. 更新解锁弹窗（不管背包开不开） =====
for (var i = array_length(unlock_popups) - 1; i >= 0; i--) {
    var _popup = unlock_popups[i];
    _popup.life_timer -= 1;
    _popup.bob_timer += 0.05;
    _popup.pulse_timer += 0.1;
    
    if (_popup.life_timer <= 0) {
        array_delete(unlock_popups, i, 1);
    }
}

// ===== 3. 左键 / ESC 取消弹窗 =====
if (array_length(unlock_popups) > 0) {
    if (mouse_check_button_pressed(mb_left) || keyboard_check_pressed(vk_escape)) {
        unlock_popups = [];
    }
}

// ===== 4. 背包没打开，跳过背包逻辑 =====
// ===== ★ 排序按钮点击检测 =====
if (is_open) {
    var _sbtn_w = 80;
    var _sbtn_h = 28;
    var _sbtn_x = ui_right_x + inventory_cols * (slot_size + slot_gap) - _sbtn_w;
    var _sbtn_y = ui_right_y - 30 - _sbtn_h * 0.5;
    
    var _smx = device_mouse_x_to_gui(0);
    var _smy = device_mouse_y_to_gui(0);
    var _sbtn_hover = (_smx >= _sbtn_x && _smx <= _sbtn_x + _sbtn_w &&
                       _smy >= _sbtn_y && _smy <= _sbtn_y + _sbtn_h);
    
    if (_sbtn_hover && mouse_check_button_pressed(mb_left)) {
        scr_inventory_sort(_player_tmp);
        selected_inventory = -1;
        hover_inventory = -1;
        exit;
    }
}
if (!is_open) exit;

// ===== 5. 更新鼠标悬浮 =====
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

hover_inventory = -1;
hover_slot = -1;

// 检测悬浮槽
for (var i = 0; i < 6; i++) {
    var _sx = ui_equip_x;
    var _sy = ui_equip_y + i * (slot_size + slot_gap);
    if (_mx >= _sx && _mx <= _sx + slot_size && _my >= _sy && _my <= _sy + slot_size) {
        hover_slot = i;
        break;
    }
}

// 检测悬浮背包格
for (var row = 0; row < inventory_rows; row++) {
    for (var col = 0; col < inventory_cols; col++) {
        var _index = row * inventory_cols + col;
        var _ix = ui_right_x + col * (slot_size + slot_gap);
        var _iy = ui_right_y + row * (slot_size + slot_gap);
        if (_mx >= _ix && _mx <= _ix + slot_size && _my >= _iy && _my <= _iy + slot_size) {
            hover_inventory = _index;
            break;
        }
    }
}

if (_double_click_timer > 0) _double_click_timer -= 1;

// ===== 6. 取玩家实例 =====
var _player = instance_find(obj_player_base, 0);
if (!instance_exists(_player)) exit;

// ===== 7. 确认框交互（最优先，打开时屏蔽其他交互） =====
if (confirm_active) {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _cw = 400;
    var _ch = 200;
    var _cx = _gw / 2 - _cw / 2;
    var _cy = _gh / 2 - _ch / 2;
    var _btn_w = 100;
    var _btn_h = 40;
    var _btn_y = _cy + _ch - 60;
    var _confirm_x = _cx + _cw / 2 - _btn_w - 10;
    var _cancel_x = _cx + _cw / 2 + 10;
    
    // 鼠标点击
    if (mouse_check_button_pressed(mb_left)) {
        if (_mx >= _confirm_x && _mx <= _confirm_x + _btn_w && _my >= _btn_y && _my <= _btn_y + _btn_h) {
            scr_inventory_ui_confirm_yes(self);
        }
        if (_mx >= _cancel_x && _mx <= _cancel_x + _btn_w && _my >= _btn_y && _my <= _btn_y + _btn_h) {
            scr_inventory_ui_confirm_no(self);
        }
    }
    
    // ★ 键盘快捷键：Q 或 回车 → 确认
    if (keyboard_check_pressed(ord("Q")) || keyboard_check_pressed(vk_enter)) {
        scr_inventory_ui_confirm_yes(self);
    }
    
    // ESC → 取消
    if (keyboard_check_pressed(vk_escape)) {
        scr_inventory_ui_confirm_no(self);
    }
    
    // 框闪烁计时
    if (flash_inventory_timer > 0) flash_inventory_timer -= 1;
    if (flash_slot_timer > 0) flash_slot_timer -= 1;
    
    exit;   // 屏蔽其他交互
}

// ===== 8. 处理点击 =====
// ★ 被动遗物拆卸确认框优先：开着时屏蔽其它一切输入
if (scr_passive_dismantle_dialog_update(self, _player)) {
    if (flash_inventory_timer > 0) flash_inventory_timer -= 1;
    if (flash_slot_timer > 0) flash_slot_timer -= 1;
    exit;
}

// ★ 被动遗物栏先处理（它在背包右侧，X 范围与其它面板不重叠）
//   放在这里是为了让"选中/拆卸"先于通用点击逻辑拿到鼠标事件
scr_passive_relic_panel_update(self, _player);

scr_inventory_ui_click(self);

// ===== 9. E 键装备（只在背包格上生效） =====
if (keyboard_check_pressed(ord("E"))) {
    if (hover_inventory >= 0 && hover_inventory < array_length(_player.inventory)) {
        scr_inventory_ui_equip_auto(self, hover_inventory);
    }
}

// ===== 10. Q 键：装备槽卸下 / 背包格丢弃 =====
// ★ 鼠标在被动遗物栏上时，Q 归 scr_passive_relic_panel_update 管（拆卸），这里跳过
var _mouse_on_passive = (_mx >= ui_passive_x && _mx <= ui_passive_x + slot_size);

if (keyboard_check_pressed(ord("Q")) && !_mouse_on_passive) {
    if (hover_slot >= 0 && hover_slot < 6) {
        // 鼠标在装备槽 → 卸下
        scr_inventory_ui_try_unequip(self, hover_slot);
    } else if (hover_inventory >= 0 && hover_inventory < array_length(_player.inventory)) {
        // 鼠标在背包格 → 丢弃（走确认框）
        scr_inventory_ui_try_drop(self, hover_inventory);
    }
}

// ===== 11. 右键检测 =====
if (mouse_check_button_pressed(mb_right) && !_mouse_on_passive) {
    // 检测装备槽
    for (var i = 0; i < 6; i++) {
        var _sx = ui_equip_x;
        var _sy = ui_equip_y + i * (slot_size + slot_gap);
        if (_mx >= _sx && _mx <= _sx + slot_size && _my >= _sy && _my <= _sy + slot_size) {
            scr_inventory_ui_try_unequip(self, i);
            break;
        }
    }
    
    // 检测背包格
    var _start = inventory_page * inventory_per_page;
    for (var row = 0; row < inventory_rows; row++) {
        for (var col = 0; col < inventory_cols; col++) {
            var _index = _start + row * inventory_cols + col;
            var _ix = ui_right_x + col * (slot_size + slot_gap);
            var _iy = ui_right_y + row * (slot_size + slot_gap);
            if (_mx >= _ix && _mx <= _ix + slot_size && _my >= _iy && _my <= _iy + slot_size) {
                scr_inventory_ui_try_drop(self, _index);
                break;
            }
        }
    }
}

// ===== 12. 框闪烁计时 =====
if (flash_inventory_timer > 0) flash_inventory_timer -= 1;
if (flash_slot_timer > 0) flash_slot_timer -= 1;