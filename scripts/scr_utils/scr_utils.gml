// ====================================================================
// scr_utils.gml — small helpers & no-op hooks
// ====================================================================

/*
* Name: approx_zero
* Description: Returns true if |v| <= eps.
*/
function approx_zero(v, eps) { return abs(v) <= eps; }

/*
* Name: vec2_len
* Description: Returns Euclidean length of (vx, vy).
*/
function vec2_len(vx, vy) { return sqrt(vx*vx + vy*vy); }

/*
* Name: vec2_norm
* Description: Normalises (vx, vy); returns (nx, ny). If zero, returns (0,0).
*/
function vec2_norm(vx, vy)
{
    var mag = vec2_len(vx, vy);
    if (mag <= 0.00001) return [0, 0];
    return [vx / mag, vy / mag];
}

/*
* Name: keep_last_nonzero_vec
* Description: If (vx,vy) != (0,0) returns it; otherwise returns last stored pair.
*/
function keep_last_nonzero_vec(vx, vy, last_x, last_y)
{
    if (!approx_zero(vx, 0.00001) || !approx_zero(vy, 0.00001)) return [vx, vy];
    return [last_x, last_y];
}

/*
* Name: clampf
* Description: Clamp a value to [a,b] as float.
*/
function clampf(v, a, b) { return max(a, min(b, v)); }

/*
* Name: sign_nonzero
* Description: Returns sign(v) but treats 0 as 0.
*/
function sign_nonzero(v) { return (v > 0) - (v < 0); }
/*
* Name: game_get_state
* Description: Returns current game state; defaults safely to Playing.
*/
function game_get_state()
{
    return variable_global_exists("game_state") ? global.game_state : GameState.Playing;
}

/*
* Name: game_set_state
* Description: Sets the current game state.
*/
function game_set_state(_state)
{
    global.game_state = _state;
}

/*
* Name: game_is_paused
* Description: True if gameplay should halt (Paused or Inventory).
*/
function game_is_paused()
{
    var s = game_get_state();
    return (s == GameState.Paused) || (s == GameState.Inventory);
}

/*
* Name: on_pause_exit
* Description: Return true when the game is paused so callers can early-exit Step.
*/
function on_pause_exit() {
    return variable_global_exists("is_paused") && global.is_paused;
}

/*
* Name: inventory_is_open
* Description: Returns true if the global game state is Inventory.
*/
function inventory_is_open()
{
    return (game_get_state() == GameState.Inventory);
}

/*
* Name: recompute_pause_state
* Description: Recompute global pause from inventory/menu visibility.
*/
function recompute_pause_state() {
    global.is_paused = (global.inv_visible || global.menu_visible);
}

/*
* Name: menu_show
* Description: Show pause menu and recompute pause.
*/
function menu_show() {
    global.menu_visible = true;
    recompute_pause_state();
}

/*
* Name: menu_hide
* Description: Hide pause menu and recompute pause.
*/
function menu_hide() {
    global.menu_visible = false;
    recompute_pause_state();
}

/*
* Name: menu_toggle
* Description: Toggle pause menu and recompute pause.
*/
function menu_toggle() {
    if (global.menu_visible) menu_hide(); else menu_show();
}
