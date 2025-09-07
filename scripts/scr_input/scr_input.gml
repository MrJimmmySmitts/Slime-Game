// ====================================================================
// scr_input.gml — keyboard mapping in one place
// ====================================================================

/*
* Name: input_get_move
* Description: Returns a normalised {dx, dy} from WASD (and arrows as backup).
*/
function input_get_move()
{
    var mv_dx = (keyboard_check(ord("D")) - keyboard_check(ord("A")));
    if (mv_dx == 0) mv_dx = (keyboard_check(vk_right) - keyboard_check(vk_left));

    var mv_dy = (keyboard_check(ord("S")) - keyboard_check(ord("W")));
    if (mv_dy == 0) mv_dy = (keyboard_check(vk_down) - keyboard_check(vk_up));

    var n = vec2_norm(mv_dx, mv_dy);
    return { dx: n[0], dy: n[1] };
}

/*
* Name: input_get_aim_held
* Description: Returns a normalised {dx, dy} vector from IJKL held down.
*/
function input_get_aim_held()
{
    var aim_dx = (keyboard_check(ord("L")) - keyboard_check(ord("J")));
    var aim_dy = (keyboard_check(ord("K")) - keyboard_check(ord("I")));
    var n = vec2_norm(aim_dx, aim_dy);
    return { dx: n[0], dy: n[1] };
}

/*
* Name: input_get_aim_pressed
* Description: Returns a unit {dx, dy} for the *pressed this step* I/J/K/L key.
*              Priority order: I, J, K, L (up, left, down, right).
*/
function input_get_aim_pressed()
{
    if (keyboard_check_pressed(ord("I"))) return { dx:  0, dy: -1 };
    if (keyboard_check_pressed(ord("J"))) return { dx: -1, dy:  0 };
    if (keyboard_check_pressed(ord("K"))) return { dx:  0, dy:  1 };
    if (keyboard_check_pressed(ord("L"))) return { dx:  1, dy:  0 };
    return { dx: 0, dy: 0 };
}

/*
* Name: input_fire_pressed
* Description: Returns true if a fire trigger was pressed this step. Supports mouse or Ctrl as alternates.
*/
function input_fire_pressed()
{
    return keyboard_check_pressed(vk_control) || mouse_check_button_pressed(mb_left);
}

/*
* Name: input_fire_held
* Description: Returns true if a fire trigger is held down. Supports mouse or Ctrl as alternates.
*/
function input_fire_held()
{
    return keyboard_check(vk_control) || mouse_check_button(mb_left);
}

/*
* Name: input_dash_pressed
* Description: Returns true if Space is pressed this step.
*/
function input_dash_pressed()
{
    return keyboard_check_pressed(vk_space);
}
/*
* Name: input_get_aim_axis
* Description: Returns a 2-element array [dx, dy] for current aim.
*              Uses IJKL (held) if pressed; otherwise falls back to the instance's facing_x/facing_y.
*/
function input_get_aim_axis()
{
    var held = input_get_aim_held(); // {dx, dy}
    if (held.dx != 0 || held.dy != 0) return [held.dx, held.dy];

    // Fallback to facing if available on the calling instance
    if (variable_instance_exists(id, "facing_x") && variable_instance_exists(id, "facing_y"))
        return [facing_x, facing_y];

    // Final fallback: aim right
    return [1, 0];
}
