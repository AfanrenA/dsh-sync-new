/// @description 游戏退出清理
if (variable_global_exists("dropped_weapons") && global.dropped_weapons != 0) {
    ds_list_destroy(global.dropped_weapons);
    show_debug_message("🧹 global.dropped_weapons 已清理");
}