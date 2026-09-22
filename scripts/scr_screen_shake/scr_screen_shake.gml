// scr_screen_shake.gml
function scr_screen_shake(intensity, duration) {
    if (global.screen_shake == undefined) {
        global.screen_shake = { intensity: 0, duration: 0 };
    }
    if (intensity > global.screen_shake.intensity) {
        global.screen_shake.intensity = intensity;
        global.screen_shake.duration = duration;
    }
}