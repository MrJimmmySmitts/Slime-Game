/*
* Name: menuGetLayout
* Description: Return menu layout in GUI space for hit-testing and drawing.
*/
function menuGetLayout() {
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    return {
        cx:       _gui_w * 0.5,
        start_y:  _gui_h * 0.40, // MUST match Draw layout
        gap:      28,            // MUST match Draw spacing
        item_w:   360,           // clickable width (centered on cx)
        item_h:   26             // clickable height
    };
}

/*
* Name: menuItemBounds
* Description: Clickable rect for item index (GUI space) → [left, top, right, bottom].
*/
function menuItemBounds(_index) {
    var _L      = menuGetLayout();
    var _cx     = _L.cx;
    var _base_y = _L.start_y + _index * _L.gap;
    var _iw     = _L.item_w;
    var _ih     = _L.item_h;
    return [_cx - _iw * 0.5, _base_y - _ih * 0.5, _cx + _iw * 0.5, _base_y + _ih * 0.5];
}

/*
* Name: menuIndexAt
* Description: Menu index under the GUI-space point, or -1 if none.
*/
function menuIndexAt(_mx, _my) {
    if (!is_array(menu_items)) return -1;
    var _n = array_length(menu_items);
    for (var _i = 0; _i < _n; _i++) {
        var _b = menuItemBounds(_i);
        if (_mx >= _b[0] && _mx <= _b[2] && _my >= _b[1] && _my <= _b[3]) return _i;
    }
    return -1;
}

/*
* Name: menuActivateSelection
* Description: Perform the currently selected action (same as pressing Enter).
*/
function menuActivateSelection() {
    if (!is_array(menu_items)) return;
    if (sel < 0 || sel >= array_length(menu_items)) return;

    var _choice = menu_items[sel];

    if (_choice == "New") {
        dialogQueuePush("Welcome to the world of slime, there is too much non-slime around, you should fix that.");
        menuHide();
        room_goto(rm_game);
    }
    else if (_choice == "Continue") {
        dialogQueuePush("Welcome back to the world of slime. You know what to do.");
        menuHide();
        room_goto(rm_game);
    }
    else if (_choice == "Load")      { 
            // TODO  
        }
    else if (_choice == "Settings")  { 
         // TODO 
    }
    else if (_choice == "Quit")      { 
        game_end(); 
    }
}


/*
* Name: menuMouseUpdate
* Description: When menu is visible, hover to select and click (LMB) to activate.
*/
function menuMouseUpdate() {
    if (!global.menuVisible) return;

    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    var _idx = menuIndexAt(_mx, _my);
    if (_idx != -1) sel = _idx;

    if (mouse_check_button_pressed(mb_left) && _idx != -1) {
        menuActivateSelection();
    }
}
