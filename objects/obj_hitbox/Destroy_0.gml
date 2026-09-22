// obj_hitbox - Destroy 事件

// 检查 hit_list 是否是有效的 ds_list
// 用 ds_list_size 检查，如果 hit_list 是 noone 或无效，会返回 0 或报错
// 所以先检查是否为 noone
if (hit_list != noone) {
    ds_list_destroy(hit_list);
    hit_list = noone;
}