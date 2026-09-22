/// @description UI 管理器 - Draw GUI 事件
draw_set_font(fnt_chinese);
// ===== 2. 获取玩家引用 =====
var _player = instance_find(obj_player, 0);
if (!instance_exists(_player)) exit;

// ===== 3. 绘制各 UI 元素 =====
draw_ui_hpbar(_player);        // 血量条
draw_ui_infocards(_player);    // 武器/遗物/技能卡片（新增）
draw_ui_statspanel(_player);   // 属性面板（左下角）