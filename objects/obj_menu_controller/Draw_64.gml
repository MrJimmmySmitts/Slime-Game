/*
* Name: obj_menu_controller.Draw
* Description: Draw title/pause menu only when visible, aligned with menuGetLayout().
*/
if (!global.menuVisible) exit;

var _W = display_get_gui_width();
var _H = display_get_gui_height();

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

if (menu_screen == MenuScreen.Main)
{
    draw_set_color(c_white);
    draw_text(_W * 0.5, _H * 0.25, "PLOP");

    var _L = menuGetLayout();
    var _n = is_array(menu_items) ? array_length(menu_items) : 0;

    for (var _i = 0; _i < _n; _i++)
    {
        var _item  = menu_items[_i];
        var _label = is_struct(_item) && variable_struct_exists(_item, "label") ? _item.label : string(_item);
        if (_i == sel) _label = "> " + string(_label) + " <";
        draw_text(_L.cx, _L.start_y + _i * _L.gap, string(_label));
    }
}
else
{
    var _panel_x1 = _W * 0.2;
    var _panel_y1 = _H * 0.15;
    var _panel_x2 = _W * 0.8;
    var _panel_y2 = _H * 0.90;

    draw_set_alpha(0.75);
    draw_set_color(make_color_rgb(20, 28, 52));
    draw_rectangle(_panel_x1, _panel_y1, _panel_x2, _panel_y2, false);
    draw_set_alpha(1);

    draw_set_color(c_white);
    draw_text(_W * 0.5, _H * 0.2, "Settings");

    var _L = menuGetLayout();
    var _n = is_array(menu_items) ? array_length(menu_items) : 0;

    for (var _i = 0; _i < _n; _i++)
    {
        var _item    = menu_items[_i];
        var _label   = is_struct(_item) && variable_struct_exists(_item, "label") ? _item.label : string(_item);
        var _enabled = !is_struct(_item) || !variable_struct_exists(_item, "enabled") || _item.enabled;
        var _text    = string(_label);
        var _y       = _L.start_y + _i * _L.gap;

        if (_i == sel && _enabled) _text = "> " + _text + " <";

        if (!_enabled)
        {
            draw_set_color(make_color_rgb(140, 140, 140));
        }
        else if (_i == sel)
        {
            draw_set_color(make_color_rgb(255, 230, 120));
        }
        else
        {
            draw_set_color(c_white);
        }

        draw_text(_L.cx, _y, _text);
    }

    draw_set_color(c_white);
    draw_text(_W * 0.5, _H * 0.88, "Use Arrow Keys / Mouse to adjust. Enter to activate.");
}
