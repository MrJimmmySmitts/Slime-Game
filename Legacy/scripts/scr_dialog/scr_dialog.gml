// ====================================================================
// scr_dialog.gml 
// Description: Message and Dialog Functionality
// Author: James Smith
// ====================================================================

// ====================================================================
// Name: dialogInit
// Description: Initialise global dialogue state and queue. Call at boot.
// Usage: ???
// ====================================================================
function dialogInit() {
    global.dialogQueue = [];
    global.dialogVisible = false;
    global.dialogCurrent = "";
    global.dialogType = "";
    global.dialogCbRetry = undefined;
    global.dialogCbQuit  = undefined;
    global.dialogCbOk    = undefined;
    global.dialogCbMenu  = undefined;
}

// ====================================================================
// Name: dialogQueuePush
// Description: Push a message onto the dialogue queue to be shown later.
// ====================================================================
function dialogQueuePush(_text, _ok_cb) {

    if (argument_count < 2) _ok_cb = undefined;

    if (!variable_global_exists("dialogQueue") || !is_array(global.dialogQueue)) dialogInit();
    array_push(global.dialogQueue, {
        text    : string(_text),
        type    : "ok",
        ok_cb   : _ok_cb,
        retry_cb: undefined,
        quit_cb : undefined
    });

}

// ====================================================================
// Name: dialogQueuePushQuestion
// Description: Queue a question dialog with Retry and Quit callbacks.
// ====================================================================
function dialogQueuePushQuestion(_text, _retry_cb, _quit_cb) {

    if (!variable_global_exists("dialogQueue") || !is_array(global.dialogQueue)) dialogInit();

    array_push(global.dialogQueue, {
        text: string(_text),
        type: "question",
        retry_cb: _retry_cb,
        quit_cb: _quit_cb
    });
}
// ====================================================================
// Name: dialogQueuePushQuestion
// Description: Queue a question dialog with Retry and Quit callbacks.
// ====================================================================
function dialogQueuePushWin(_text, _menu_cb, _restart_cb, _quit_cb) {

    if (!variable_global_exists("dialogQueue") || !is_array(global.dialogQueue)) dialogInit();

    array_push(global.dialogQueue, {
        text: string(_text),
        type: "win",
        menu_cb: _menu_cb,
        retry_cb: _restart_cb,
        quit_cb: _quit_cb
    });
}

/*
* Name: dialogShowNext
* Description: Show the next message from the queue, pausing gameplay.
*/
function dialogShowNext() {
    if (array_length(global.dialogQueue) <= 0) return;
    var _entry = global.dialogQueue[0];
    global.dialogQueue = array_delete(global.dialogQueue, 0, 1);

    global.dialogCurrent = _entry.text;
    global.dialogType    = _entry.type;


    if (variable_struct_exists(_entry, "ok_cb")) {
        global.dialogCbOk = _entry.ok_cb;
    } else {
        global.dialogCbOk = undefined;
    }

    if (variable_struct_exists(_entry, "menu_cb")) {
        global.dialogCbMenu = _entry.menu_cb;
    } else {
        global.dialogCbMenu = undefined;
    }

    if (variable_struct_exists(_entry, "retry_cb")) {
        global.dialogCbRetry = _entry.retry_cb;
    } else {
        global.dialogCbRetry = undefined;
    }

    if (variable_struct_exists(_entry, "quit_cb")) {
        global.dialogCbQuit = _entry.quit_cb;
    } else {
        global.dialogCbQuit = undefined;
    }


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
    global.dialogType = "";
    global.dialogCbRetry = undefined;
    global.dialogCbQuit  = undefined;
    global.dialogCbOk    = undefined;
    global.dialogCbMenu  = undefined;
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
* Description: Handle input for visible dialogues, including OK or Retry/Quit buttons.
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

    var _pad = 16;
    var _btn_w = 96;
    var _btn_h = 28;
    var _btn_y = _box_y + _box_h - _btn_h - _pad;

    if (global.dialogType == "question") {
        var _btn_x_quit  = _box_x + _box_w - _btn_w - _pad;
        var _btn_x_retry = _btn_x_quit - _btn_w - _pad;

        var _hover_retry = (_mx >= _btn_x_retry && _mx <= _btn_x_retry + _btn_w && _my >= _btn_y && _my <= _btn_y + _btn_h);
        var _hover_quit  = (_mx >= _btn_x_quit  && _mx <= _btn_x_quit  + _btn_w && _my >= _btn_y && _my <= _btn_y + _btn_h);

        if (keyboard_check_pressed(ord("R")) || (mouse_check_button_pressed(mb_left) && _hover_retry)) {
            if (!is_undefined(global.dialogCbRetry)) global.dialogCbRetry();
            dialogHide();
            return;
        }
        if (keyboard_check_pressed(ord("Q")) || (mouse_check_button_pressed(mb_left) && _hover_quit)) {
            if (!is_undefined(global.dialogCbQuit)) global.dialogCbQuit();
            dialogHide();
            return;
        }
    } else if (global.dialogType == "win") {
        var _btn_x_quit    = _box_x + _box_w - _btn_w - _pad;
        var _btn_x_restart = _box_x + (_box_w - _btn_w) * 0.5;
        var _btn_x_menu    = _box_x + _pad;

        var _hover_menu    = (_mx >= _btn_x_menu    && _mx <= _btn_x_menu    + _btn_w && _my >= _btn_y && _my <= _btn_y + _btn_h);
        var _hover_restart = (_mx >= _btn_x_restart && _mx <= _btn_x_restart + _btn_w && _my >= _btn_y && _my <= _btn_y + _btn_h);
        var _hover_quit    = (_mx >= _btn_x_quit    && _mx <= _btn_x_quit    + _btn_w && _my >= _btn_y && _my <= _btn_y + _btn_h);

        if (keyboard_check_pressed(ord("M")) || (mouse_check_button_pressed(mb_left) && _hover_menu)) {
            if (!is_undefined(global.dialogCbMenu)) global.dialogCbMenu();
            dialogHide();
            return;
        }
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("R")) || (mouse_check_button_pressed(mb_left) && _hover_restart)) {
            if (!is_undefined(global.dialogCbRetry)) global.dialogCbRetry();
            dialogHide();
            return;
        }
        if (keyboard_check_pressed(ord("Q")) || (mouse_check_button_pressed(mb_left) && _hover_quit)) {
            if (!is_undefined(global.dialogCbQuit)) global.dialogCbQuit();
            dialogHide();
            return;
        }
    } else {
        var _btn_x = _box_x + _box_w - _btn_w - _pad;
        var _hover_ok = (_mx >= _btn_x && _mx <= _btn_x + _btn_w && _my >= _btn_y && _my <= _btn_y + _btn_h);

        if (keyboard_check_pressed(vk_enter)) {
            if (!is_undefined(global.dialogCbOk)) global.dialogCbOk();
            dialogHide();
            return;
        }
        if (mouse_check_button_pressed(mb_left) && _hover_ok) {
            if (!is_undefined(global.dialogCbOk)) global.dialogCbOk();
            dialogHide();
            return;
        }
    }
}

/*
* Name: dialogDraw
* Description: Draw the dialogue box, text and buttons in GUI space.
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

    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    if (global.dialogType == "question") {
        var _btn_w = 96;
        var _btn_h = 28;
        var _btn_y = _box_y + _box_h - _btn_h - _pad;
        var _btn_x_quit  = _box_x + _box_w - _btn_w - _pad;
        var _btn_x_retry = _btn_x_quit - _btn_w - _pad;

        var _hover_retry = (_mx >= _btn_x_retry && _mx <= _btn_x_retry + _btn_w && _my >= _btn_y && _my <= _btn_y + _btn_h);
        var _hover_quit  = (_mx >= _btn_x_quit  && _mx <= _btn_x_quit  + _btn_w && _my >= _btn_y && _my <= _btn_y + _btn_h);

        // Retry button
        draw_set_color(_hover_retry ? make_color_rgb(80, 160, 80) : make_color_rgb(64, 128, 64));
        draw_rectangle(_btn_x_retry, _btn_y, _btn_x_retry + _btn_w, _btn_y + _btn_h, false);
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(_btn_x_retry + _btn_w * 0.5, _btn_y + _btn_h * 0.5, "Retry");

        // Quit button
        draw_set_color(_hover_quit ? make_color_rgb(160, 80, 80) : make_color_rgb(128, 64, 64));
        draw_rectangle(_btn_x_quit, _btn_y, _btn_x_quit + _btn_w, _btn_y + _btn_h, false);
        draw_set_color(c_white);
        draw_text(_btn_x_quit + _btn_w * 0.5, _btn_y + _btn_h * 0.5, "Quit");
    } else if (global.dialogType == "win") {
        var _btn_w = 96;
        var _btn_h = 28;
        var _btn_y = _box_y + _box_h - _btn_h - _pad;
        var _btn_x_menu    = _box_x + _pad;
        var _btn_x_restart = _box_x + (_box_w - _btn_w) * 0.5;
        var _btn_x_quit    = _box_x + _box_w - _btn_w - _pad;

        var _hover_menu    = (_mx >= _btn_x_menu    && _mx <= _btn_x_menu    + _btn_w && _my >= _btn_y && _my <= _btn_y + _btn_h);
        var _hover_restart = (_mx >= _btn_x_restart && _mx <= _btn_x_restart + _btn_w && _my >= _btn_y && _my <= _btn_y + _btn_h);
        var _hover_quit    = (_mx >= _btn_x_quit    && _mx <= _btn_x_quit    + _btn_w && _my >= _btn_y && _my <= _btn_y + _btn_h);

        // Menu button
        draw_set_color(_hover_menu ? make_color_rgb(80, 120, 200) : make_color_rgb(64, 96, 168));
        draw_rectangle(_btn_x_menu, _btn_y, _btn_x_menu + _btn_w, _btn_y + _btn_h, false);
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(_btn_x_menu + _btn_w * 0.5, _btn_y + _btn_h * 0.5, "Menu");

        // Restart button
        draw_set_color(_hover_restart ? make_color_rgb(80, 160, 80) : make_color_rgb(64, 128, 64));
        draw_rectangle(_btn_x_restart, _btn_y, _btn_x_restart + _btn_w, _btn_y + _btn_h, false);
        draw_set_color(c_white);
        draw_text(_btn_x_restart + _btn_w * 0.5, _btn_y + _btn_h * 0.5, "Restart");

        // Quit button
        draw_set_color(_hover_quit ? make_color_rgb(160, 80, 80) : make_color_rgb(128, 64, 64));
        draw_rectangle(_btn_x_quit, _btn_y, _btn_x_quit + _btn_w, _btn_y + _btn_h, false);
        draw_set_color(c_white);
        draw_text(_btn_x_quit + _btn_w * 0.5, _btn_y + _btn_h * 0.5, "Quit");
    } else {
        // OK button
        var _btn_w = 96;
        var _btn_h = 28;
        var _btn_x = _box_x + _box_w - _btn_w - _pad;
        var _btn_y = _box_y + _box_h - _btn_h - _pad;

        var _hover_ok = (_mx >= _btn_x && _mx <= _btn_x + _btn_w && _my >= _btn_y && _my <= _btn_y + _btn_h);

        draw_set_color(_hover_ok ? make_color_rgb(80, 160, 80) : make_color_rgb(64, 128, 64));
        draw_rectangle(_btn_x, _btn_y, _btn_x + _btn_w, _btn_y + _btn_h, false);
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(_btn_x + _btn_w * 0.5, _btn_y + _btn_h * 0.5, "OK");
    }
}
