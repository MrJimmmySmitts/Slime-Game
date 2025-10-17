// ====================================================================
// scr_utils.gml — small helpers & no-op hooks
// ====================================================================

/*
* Name: approxZero
* Description: Returns true if |v| <= eps.
*/
function approxZero(v, eps) { return abs(v) <= eps; }

/*
* Name: vec2Len
* Description: Returns Euclidean length of (vx, vy).
*/
function vec2Len(vx, vy) { return sqrt(vx*vx + vy*vy); }

/*
* Name: vec2Norm
* Description: Normalises (vx, vy); returns (nx, ny). If zero, returns (0,0).
*/
function vec2Norm(vx, vy)
{
    var mag = vec2Len(vx, vy);
    if (mag <= 0.00001) return [0, 0];
    return [vx / mag, vy / mag];
}

/*
* Name: keepLastNonzeroVec
* Description: If (vx,vy) != (0,0) returns it; otherwise returns last stored pair.
*/
function keepLastNonzeroVec(vx, vy, last_x, last_y)
{
    if (!approxZero(vx, 0.00001) || !approxZero(vy, 0.00001)) return [vx, vy];
    return [last_x, last_y];
}

/*
* Name: clampf
* Description: Clamp a value to [a,b] as float.
*/
function clampf(v, a, b) { return max(a, min(b, v)); }

/*
* Name: signNonzero
* Description: Returns sign(v) but treats 0 as 0.
*/
function signNonzero(v) { return (v > 0) - (v < 0); }
/*
* Name: gameGetState
* Description: Returns current game state; defaults safely to Playing.
*/
function gameGetState()
{
    return variable_global_exists("gameState") ? global.gameState : GameState.Playing;
}

/*
* Name: gameSetState
* Description: Sets the current game state.
*/
function gameSetState(_state)
{
    global.gameState = _state;
}

/*
* Name: gameIsPaused
* Description: True if gameplay should halt (Paused or Inventory).
*/
function gameIsPaused()
{
    var s = gameGetState();
    return (s == GameState.Paused) || (s == GameState.Inventory);
}

/*
* Name: onPauseExit
* Description: Return true when the game is paused so callers can early-exit Step.
*/
function onPauseExit() {
    return variable_global_exists("isPaused") && global.isPaused;
}

/*
* Name: inventoryIsOpen
* Description: Returns true if the global game state is Inventory.
*/
function inventoryIsOpen()
{
    return (gameGetState() == GameState.Inventory);
}
/*
* Name: recomputePauseState
* Description: Recompute global pause from inventory/menu/dialogue visibility.
*/
function recomputePauseState() {
    global.isPaused = (global.invVisible || global.menuVisible || global.dialogVisible);
}
/*
* Name: menuShow
* Description: Show pause menu and recompute pause.
*/
function menuShow() {
    global.menuVisible = true;
    recomputePauseState();
}

/*
* Name: menuHide
* Description: Hide pause menu and recompute pause.
*/
function menuHide() {
    global.menuVisible = false;
    recomputePauseState();
}

/*
* Name: menuToggle
* Description: Toggle pause menu and recompute pause.
*/
function menuToggle() {
    if (global.menuVisible) menuHide(); else menuShow();
}
