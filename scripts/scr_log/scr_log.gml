// ======================================================================
// 简单日志系统
// 用法：
//   log_info("消息")      - 普通信息（白色）
//   log_warning("消息")   - 警告信息（黄色）
//   log_error("消息")     - 错误信息（红色）
//   log_debug("消息")     - 调试信息（灰色，发布前可以全部注释掉）
// ======================================================================

/// @description 普通信息日志
/// @param {string} _msg 要输出的消息
function log_info(_msg) {
    show_debug_message("[INFO] " + string(_msg));
}

/// @description 警告日志（需要关注但非致命的问题）
/// @param {string} _msg 要输出的消息
function log_warning(_msg) {
    show_debug_message("[WARNING] " + string(_msg));
}

/// @description 错误日志（需要立即修复的问题）
/// @param {string} _msg 要输出的消息
function log_error(_msg) {
    show_debug_message("[ERROR] " + string(_msg));
}

/// @description 调试日志（开发过程中用来追踪细节，发布前可以注释掉）
/// @param {string} _msg 要输出的消息
function log_debug(_msg) {
    show_debug_message("[DEBUG] " + string(_msg));
}