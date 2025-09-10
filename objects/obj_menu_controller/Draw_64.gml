/*
* Name: obj_menu_controller.Draw
* Description: Draw title/pause menu only when visible, aligned with menuGetLayout().
*/
if (!global.menuVisible) exit;

var _W = display_get_gui_width();
var _H = display_get_gui_height();

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(_W * 0.5, _H * 0.25, "PLOP");

// Use the same layout as hit-testing so clicks line up exactly
var _L = menuGetLayout();
var _n = is_array(menu_items) ? array_length(menu_items) : 0;

for (var _i = 0; _i < _n; _i++) {
    var _y     = _L.start_y + _i * _L.gap;
    var _label = string(menu_items[_i]);
    if (_i == sel) _label = "> " + _label + " <";
    draw_text(_L.cx, _y, _label);
}

