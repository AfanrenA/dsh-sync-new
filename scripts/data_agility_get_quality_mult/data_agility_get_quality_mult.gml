function data_agility_get_quality_mult(agility_id, quality_index, stat_name) {
    var _data = data_agility_get(agility_id);
    if (_data == undefined) return 1.0;
    
    var _arr = _data[$ stat_name];
    if (_arr == undefined) return 1.0;
    
    if (quality_index < 0) quality_index = 0;
    if (quality_index >= array_length(_arr)) quality_index = array_length(_arr) - 1;
    
    return _arr[quality_index];
} 