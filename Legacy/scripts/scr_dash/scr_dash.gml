// ====================================================================
// Name: scr_dash.gml 
// Description: Player Dash Functionality
// Author: James Smith
// ====================================================================

// ==================================================================== 
// Name: dashInit
// Description:  Initialise dash state on the instance.
// ====================================================================
function dashInit() {
    dash_active        = false;
    dash_time_left     = 0;
    dash_cooldown_left = 0;
    dash_vx            = 0;
    dash_vy            = 0;
}

// ==================================================================== 
// Name: dashStart
// Description: Starts a dash in direction [fx, fy] if available.
// ==================================================================== 
function dashStart(fx, fy) {
    if (!dash_active && dash_cooldown_left <= 0) {
        var n = vec2Norm(fx, fy);
        var nx = n[0], ny = n[1];
        if (nx == 0 && ny == 0) { nx = 1; ny = 0; } // default right
        dash_vx = nx * PLAYER_DASH_DISTANCE;
        dash_vy = ny * PLAYER_DASH_DISTANCE;
        dash_time_left = PLAYER_DASH_TIME;
        dash_active = true;
    }
}

// ==================================================================== 
// Name: dashStep 
// Description: Advances dash motion/timers. Returns true if dashing this step.
// ==================================================================== 
function dashStep(col_w, col_h, tilemap) {
    if (dash_active) {
        pMoveAxis(dash_vx, dash_vy, col_w, col_h, tilemap);
        dash_time_left -= 1;
        if (dash_time_left <= 0) {
            dash_active = false;
            dash_cooldown_left = PLAYER_DASH_TIME;
        }
        return true;
    } 
    else if (dash_cooldown_left > 0) {
        dash_cooldown_left -= 1;
    }
    return false;
}
