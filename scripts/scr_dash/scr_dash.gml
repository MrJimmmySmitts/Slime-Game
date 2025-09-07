/*
* Name: dash_init
* Description: Initialise dash state on the instance.
*/
function dash_init() {
    dash_active        = false;
    dash_time_left     = 0;
    dash_cooldown_left = 0;
    dash_vx            = 0;
    dash_vy            = 0;
}

/*
* Name: dash_try_start
* Description: Starts a dash in direction [fx, fy] if available.
*/
function dash_try_start(fx, fy) {
    if (!dash_active && dash_cooldown_left <= 0) {
        var n = vec2_normalize(fx, fy);
        var nx = n[0], ny = n[1];
        if (nx == 0 && ny == 0) { nx = 1; ny = 0; } // default right
        dash_vx = nx * DASH_SPEED;
        dash_vy = ny * DASH_SPEED;
        dash_time_left = DASH_DURATION_STEPS;
        dash_active = true;
    }
}

/*
* Name: dash_step
* Description: Advances dash motion/timers. Returns true if dashing this step.
*/
function dash_step(col_w, col_h, tilemap) {
    if (dash_active) {
        pmove_step_axis(dash_vx, dash_vy, col_w, col_h, tilemap);
        dash_time_left -= 1;
        if (dash_time_left <= 0) {
            dash_active = false;
            dash_cooldown_left = DASH_COOLDOWN_STEPS;
        }
        return true;
    } else if (dash_cooldown_left > 0) {
        dash_cooldown_left -= 1;
    }
    return false;
}
