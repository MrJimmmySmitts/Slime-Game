// ====================================================================
// scr_input.gml — keyboard mapping in one place
// ====================================================================

/*
* Name: inputGetMove
* Description: Returns a normalised {dx, dy} from WASD (and arrows as backup).
*/
function inputGetMove()
{
    var mv_dx = (keyboard_check(ord("D")) - keyboard_check(ord("A")));
    if (mv_dx == 0) mv_dx = (keyboard_check(vk_right) - keyboard_check(vk_left));

    var mv_dy = (keyboard_check(ord("S")) - keyboard_check(ord("W")));
    if (mv_dy == 0) mv_dy = (keyboard_check(vk_down) - keyboard_check(vk_up));

    var n = vec2Norm(mv_dx, mv_dy);
    return { dx: n[0], dy: n[1] };
}

/*
* Name: inputGetAimHeld
* Description: Returns a normalised {dx, dy} vector from IJKL held down.
*/
function inputGetAimHeld()
{
    var aim_dx = (keyboard_check(ord("L")) - keyboard_check(ord("J")));
    var aim_dy = (keyboard_check(ord("K")) - keyboard_check(ord("I")));
    var n = vec2Norm(aim_dx, aim_dy);
    return { dx: n[0], dy: n[1] };
}

/*
* Name: inputGetAimPressed
* Description: Returns a unit {dx, dy} for the *pressed this step* I/J/K/L key.
*              Priority order: I, J, K, L (up, left, down, right).
*/
function inputGetAimPressed()
{
    if (keyboard_check_pressed(ord("I"))) return { dx:  0, dy: -1 };
    if (keyboard_check_pressed(ord("J"))) return { dx: -1, dy:  0 };
    if (keyboard_check_pressed(ord("K"))) return { dx:  0, dy:  1 };
    if (keyboard_check_pressed(ord("L"))) return { dx:  1, dy:  0 };
    return { dx: 0, dy: 0 };
}
/*
* Name: inputDashPressed
* Description: Returns true if Space is pressed this step.
*/
function inputDashPressed()
{
    return keyboard_check_pressed(vk_space);
}
/*
* Name: inputGetAimAxis
* Description: Returns a 2-element array [dx, dy] for current aim.
*              Uses IJKL (held) if pressed; otherwise falls back to the instance's facing_x/facing_y.
*/
function inputGetAimAxis()
{
    var held = inputGetAimHeld(); // {dx, dy}
    if (held.dx != 0 || held.dy != 0) return [held.dx, held.dy];

    // Fallback to facing if available on the calling instance
    if (variable_instance_exists(id, "facing_x") && variable_instance_exists(id, "facing_y"))
        return [facing_x, facing_y];

    // Final fallback: aim right
    return [1, 0];
}
/*
* Name: inputFirePressed
* Description: True on the frame primary fire is pressed AND input isn't locked.
*/
function inputFirePressed() {
    var _locked = variable_instance_exists(id, "input_locked") && input_locked;
    if (_locked) return false;
    return mouse_check_button_pressed(mb_left);
}

/*
* Name: inputFireHeld
* Description: True while primary fire is held AND input isn't locked.
*/
function inputFireHeld() {
    var _locked = variable_instance_exists(id, "input_locked") && input_locked;
    if (_locked) return false;
    return mouse_check_button(mb_left);
}
