function scr_show_hint(owner, text) {
    // ★ 同一时刻只保留一条提示（用户要求："新的出现，旧的就直接消失"）
    //
    // 原因：原来每次都新建 obj_hint，多个实例叠在同一个坐标（100/150）上，
    //       连续操作几次就糊成一团看不清。
    //
    // 做法：新建前先把场上已有的 obj_hint 全部销毁。
    //   注意：用 instance_number + instance_find 倒序销毁，
    //   不要在 with 里销毁自己（GM 会跳过元素）。
    var _n = instance_number(obj_hint);
    for (var i = _n - 1; i >= 0; i--) {
        var _old = instance_find(obj_hint, i);
        if (instance_exists(_old)) instance_destroy(_old);
    }

    var _hint = instance_create_depth(0, 0, -15000, obj_hint);
    _hint.text = text;
}
