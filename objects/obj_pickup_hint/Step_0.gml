// 如果目标不存在，销毁
if (!instance_exists(target_item)) {
    instance_destroy();
    exit;
}

// ===== 用 bbox 计算武器精灵的实际中心 =====
var _center_x = (target_item.bbox_left + target_item.bbox_right) / 2;
var _center_y = (target_item.bbox_top + target_item.bbox_bottom) / 2;

x = _center_x;
y = _center_y - 60;   // 武器上方 60 像素