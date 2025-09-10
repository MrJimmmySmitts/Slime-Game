/*
* Name: dialogInit
* Description: Initialise global dialogue state and queue. Call at boot.
*/
function dialogInit() {
    if (!variable_global_exists("dialogQueue")) global.dialogQueue = [];
    global.dialogVisible = false;
    global.dialogCurrent = "";
}

/*
* Name: dialogQueuePush
* Description: Push a message onto the dialogue queue to be shown later.
*/
function dialogQueuePush(_text) {
    array_push(global.dialogQueue, string(_text));
}

/*
* Name: dialogShowNext
* Description: Show the next message from the queue, pausing gameplay.
*/
function dialogShowNext() {
    if (array_length(global.dialogQueue) <= 0) return;
    global.dialogCurrent = global.dialogQueue[0];
    global.dialogQueue = array_delete(global.dialogQueue, 0, 1);
    global.dialogVisible = true;
    recomputePauseState(); // pause while visible
}

/*
* Name: dialogHide
* Description: Hide current dialogue and unpause (recompute). Also locks player input briefly to absorb the click.
*/
function dialogHide() {
    global.dialogVisible = false;
    global.dialogCurrent = "";
    recomputePauseState(); // unpause if nothing else visible

    // Absorb the dismiss click so the player doesn’t fire accidentally
    with (obj_player) {
        if (variable_instance_exists(id, "input_locked")) {
            input_locked = true;
            alarm[0] = max(alarm[0], 6); // ~0.1s at 60fps
        }
    }
}

/*
* Name: dialogIsActive
* Description: Returns true if a dialogue is currently visible.
*/
function dialogIsActive() {
    return global.dialogVisible;
}

/*
* Name: dialogStep
* Description: When a dialogue is visible, accept Enter or mouse click on the OK button to dismiss.
*/
function dialogStep() {
    if (!global.dialogVisible) {
        // if nothing visible but queued, auto-show next
        if (array_length(global.dialogQueue) > 0) dialogShowNext();
        return;
    }

    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    // Layout must match dialogDraw()
    var _W = display_get_gui_width();
    var _H = display_get_gui_height();

    var _box_w = min(_W * 0.8, 520);
    var _box_h = 160;
    var _box_x = (_W - _box_w) * 0.5;
    var _box_y = _H * 0.70 - _box_h * 0.5;

    var _btn_w = 96;
    var _btn_h = 28;
    var _btn_x = _box_x + _box_w - _btn_w - 16;
    var _btn_y = _box_y + _box_h - _btn_h - 16;

    var _hover_ok = (_mx >= _btn_x && _mx <= _btn_x + _btn_w && _my >= _btn_y && _my <= _btn_y + _btn_h);

    if (keyboard_check_pressed(vk_enter)) {
        dialogHide();
        return;
    }
    if (mouse_check_button_pressed(mb_left) && _hover_ok) {
        dialogHide();
        return;
    }
}

/*
* Name: dialogDraw
* Description: Draw the dialogue box, text and OK button in GUI space.
*/
function dialogDraw() {
    if (!global.dialogVisible) return;

    var _W = display_get_gui_width();
    var _H = display_get_gui_height();

    var _box_w = min(_W * 0.8, 520);
    var _box_h = 160;
    var _box_x = (_W - _box_w) * 0.5;
    var _box_y = _H * 0.70 - _box_h * 0.5;

    // Background
    draw_set_alpha(0.35);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _W, _H, false);
    draw_set_alpha(1);

    // Panel
    draw_set_color(make_color_rgb(32, 32, 48));
    draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, false);
    draw_set_color(c_white);

    // Text
    var _pad = 16;
    var _tx = _box_x + _pad;
    var _ty = _box_y + _pad;
    var _tw = _box_w - _pad * 2;

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text_ext(_tx, _ty, global.dialogCurrent, 20, _tw);

    // OK button
    var _btn_w = 96;
    var _btn_h = 28;
    var _btn_x = _box_x + _box_w - _btn_w - _pad;
    var _btn_y = _box_y + _box_h - _btn_h - _pad;

    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _hover_ok = (_mx >= _btn_x && _mx <= _btn_x + _btn_w && _my >= _btn_y && _my <= _btn_y + _btn_h);

    draw_set_color(_hover_ok ? make_color_rgb(80, 160, 80) : make_color_rgb(64, 128, 64));
    draw_rectangle(_btn_x, _btn_y, _btn_x + _btn_w, _btn_y + _btn_h, false);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_btn_x + _btn_w * 0.5, _btn_y + _btn_h * 0.5, "OK");
}
