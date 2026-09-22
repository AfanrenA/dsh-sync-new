// scr_projectile_move.gml
// 投射物基础飞行 - 纯函数
// ★ 用 move_speed / move_dir，不用内置 speed/direction（否则 GM 会重复位移）

function scr_projectile_move(projectile_inst) {
    projectile_inst.x += lengthdir_x(projectile_inst.move_speed, projectile_inst.move_dir);
    projectile_inst.y += lengthdir_y(projectile_inst.move_speed, projectile_inst.move_dir);
    projectile_inst.image_angle = projectile_inst.move_dir;
}