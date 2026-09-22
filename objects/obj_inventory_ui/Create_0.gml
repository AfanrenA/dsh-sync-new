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

// ★ 被动遗物栏（在背包右边；背包 4×80+3×10 = 350 宽，收于 1300）
ui_passive_x = 1340;
ui_passive_y = 150;

// ===== ★ 被动遗物栏交互状态 =====
selected_passive = -1;        // 左键选中的被动遗物格下标（-1 = 未选）
hover_passive = -1;           // 悬浮的格下标

// ===== ★ 被动遗物拆卸确认框 =====
//   流程（用户定案）：
//     阶段0 警告「是否拆卸？」[是][否]
//        └ 是 → count>1 进阶段1；count==1 直接拆
//     阶段1 数量选择 [单个][指定][全部]  ← 选中哪个按钮只是"选模式"
//        └ ★ 还要再点一次 [是] 才真正执行（用户要求：防误操作）
//          数量用**鼠标滚轮**调整（上滚+1 / 下滚-1）
pd_active       = false;      // 拆卸确认框是否开启
pd_stage        = 0;          // 0 = 警告  1 = 数量选择
pd_relic_id     = "";         // 待拆卸的遗物 ID
pd_relic_name   = "";         // 显示名
pd_relic_color  = c_white;    // 品质色
pd_max_count    = 0;          // 当前持有层数（"全部"的上限）
pd_chosen_count = 1;          // 「指定」模式下的数量（滚轮调）
pd_mode         = 1;          // ★ 0=单个  1=指定  2=全部（选中的模式）

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