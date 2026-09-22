//obj_inventory_ui 的 Create

// ===== 布局 =====
ui_left_x = 100;         // 角色属性
ui_left_y = 150;
ui_left_w = 400;
ui_left_h = 700;

ui_equip_x = 650;        // 装备栏
ui_equip_y = 150;

ui_right_x = 950;        // 背包
ui_right_y = 150;

// ===== 格子 =====
slot_size = 80;
slot_gap = 10;
// ===== 背包开关状态 =====
is_open = false;         // 由 Step 从 player.inventory_ui_open 同步
// ===== 背包网格 =====
inventory_cols = 4;
inventory_rows = 6;
inventory_per_page = 24;
inventory_page = 0;      // 当前页
inventory_max_page = 1;   // 总页数（未来扩展）

// ===== 交互状态 =====
selected_slot = -1;
selected_inventory = -1;
hover_inventory = -1;
hover_slot = -1;
preview_item = noone;    // 点击预览的物品

// ===== 双击检测 =====
_last_click_time = 0;
_last_click_index = -1;
_double_click_timer = 0;
DOUBLE_CLICK_TIME = 20;

// ===== 双击替换的框闪烁 =====
flash_inventory_index = -1;    // 哪个背包格在闪
flash_inventory_timer = 0;     // 剩余帧数
flash_slot_index = -1;         // 哪个装备槽在闪
flash_slot_timer = 0;          // 剩余帧数

// 解锁弹窗列表
unlock_popups = [];   // [{ item, name, rarity_color, life_timer, fade_start, bob_timer, pulse_timer }]

// ===== 确认框 =====
confirm_active = false;
confirm_action = "";
confirm_inv_index = -1;
confirm_slot = -1;
confirm_item_name = "";
confirm_item_rarity_color = c_white;