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
    var _color_disabled = make_color_rgb(140, 140, 140);
    var _color_selected = make_color_rgb(255, 230, 120);
    var _dropdown_index = (variable_instance_exists(id, "menu_dropdown_open")) ? menu_dropdown_open : -1;
    var _dropdown_entry = undefined;

    if (_dropdown_index != -1 && _dropdown_index < _n)
    {
        _dropdown_entry = menu_items[_dropdown_index];
        if (!is_struct(_dropdown_entry) || _dropdown_entry.kind != MenuItemKind.Option)
        {
            _dropdown_index = -1;
            _dropdown_entry = undefined;
        }
    }

    for (var _i = 0; _i < _n; _i++)
    {
        var _item    = menu_items[_i];
        var _label   = is_struct(_item) && variable_struct_exists(_item, "label") ? _item.label : string(_item);
        var _enabled = !is_struct(_item) || !variable_struct_exists(_item, "enabled") || _item.enabled;
        var _y       = _L.start_y + _i * _L.gap;
        var _selected = (_i == sel && _enabled);

        if (is_struct(_item))
        {
            switch (_item.kind)
            {
                case MenuItemKind.Slider:
                {
                    var _rect      = menuGetItemRect(_i);
                    var _track     = menuGetSliderTrackRect(_i);
                    var _range     = menuSliderGetRange(_item);
                    var _value     = menuSliderGetValue(_item);
                    var _ratio     = (_range[1] > _range[0]) ? clamp((_value - _range[0]) / (_range[1] - _range[0]), 0, 1) : 0;
                    var _fill_x    = _track.left + (_track.right - _track.left) * _ratio;
                    var _label_x   = _rect.left + 16;
                    var _track_y1  = _track.y - 3;
                    var _track_y2  = _track.y + 3;
                    var _value_txt = string(round(_value * 100)) + "%";

                    draw_set_halign(fa_left);
                    draw_set_color(_enabled ? (_selected ? _color_selected : c_white) : _color_disabled);
                    draw_text(_label_x, _rect.y, string(_label));

                    var _track_bg = _enabled ? make_color_rgb(36, 44, 68) : make_color_rgb(48, 48, 48);
                    draw_set_color(_track_bg);
                    draw_rectangle(_track.left, _track_y1, _track.right, _track_y2, false);

                    var _fill_color = _enabled ? make_color_rgb(120, 180, 255) : make_color_rgb(80, 80, 80);
                    if (_selected && _enabled) _fill_color = _color_selected;
                    draw_set_color(_fill_color);
                    draw_rectangle(_track.left, _track_y1, _fill_x, _track_y2, false);

                    draw_set_color(make_color_rgb(16, 24, 40));
                    draw_rectangle(_track.left, _track_y1, _track.right, _track_y2, true);

                    var _knob_color = _enabled ? (_selected ? _color_selected : c_white) : _color_disabled;
                    var _knob_radius = 6;
                    draw_set_color(_knob_color);
                    draw_circle(_fill_x, _track.y, _knob_radius, false);
                    draw_set_color(make_color_rgb(20, 20, 36));
                    draw_circle(_fill_x, _track.y, _knob_radius, true);

                    draw_set_halign(fa_right);
                    draw_set_color(_enabled ? (_selected ? _color_selected : c_white) : _color_disabled);
                    draw_text(_track.right, _track.y - (_L.item_h * 0.6), _value_txt);

                    draw_set_halign(fa_center);
                    continue;
                }

                case MenuItemKind.Option:
                {
                    var _rect_opt   = menuGetItemRect(_i);
                    var _base       = menuGetDropdownBaseRect(_i);
                    var _label_left = _rect_opt.left + 16;
                    var _value_lbl  = menuOptionGetCurrentLabel(_item);
                    if (_value_lbl == "") _value_lbl = "(not available)";

                    draw_set_halign(fa_left);
                    draw_set_color(_enabled ? (_selected ? _color_selected : c_white) : _color_disabled);
                    draw_text(_label_left, _rect_opt.y, string(_label));

                    var _bg_color    = _enabled ? make_color_rgb(36, 44, 68) : make_color_rgb(46, 46, 46);
                    var _border_col  = _enabled ? make_color_rgb(120, 130, 180) : make_color_rgb(70, 70, 70);
                    if (_selected && _enabled) _border_col = _color_selected;
                    if (_enabled && _dropdown_index == _i)
                    {
                        _bg_color   = make_color_rgb(48, 60, 96);
                        _border_col = _color_selected;
                    }

                    draw_set_color(_bg_color);
                    draw_rectangle(_base.left, _base.top, _base.right, _base.bottom, false);
                    draw_set_color(_border_col);
                    draw_rectangle(_base.left, _base.top, _base.right, _base.bottom, true);

                    var _value_color = _enabled ? (_selected ? _color_selected : c_white) : _color_disabled;
                    draw_set_color(_value_color);
                    draw_text(_base.left + 10, _rect_opt.y, _value_lbl);

                    var _arrow_color = _enabled ? _value_color : _color_disabled;
                    if (_enabled && _dropdown_index == _i) _arrow_color = _color_selected;
                    var _arrow_x = _base.right - 12;
                    var _arrow_y = _rect_opt.y + 1;
                    draw_set_color(_arrow_color);
                    draw_triangle(_arrow_x - 6, _arrow_y - 3, _arrow_x + 6, _arrow_y - 3, _arrow_x, _arrow_y + 4, false);

                    draw_set_halign(fa_center);
                    continue;
                }
            }
        }

        var _text = string(_label);
        if (_selected) _text = "> " + _text + " <";

        if (!_enabled)
        {
            draw_set_color(_color_disabled);
        }
        else if (_selected)
        {
            draw_set_color(_color_selected);
        }
        else
        {
            draw_set_color(c_white);
        }

        draw_set_halign(fa_center);
        draw_text(_L.cx, _y, _text);
    }

    if (_dropdown_index != -1 && is_struct(_dropdown_entry))
    {
        var _option_count = menuOptionGetCount(_dropdown_entry);
        if (_option_count > 0)
        {
            var _list_top = 0;
            var _list_bottom = 0;
            for (var _o = 0; _o < _option_count; _o++)
            {
                var _opt_rect = menuDropdownGetOptionRect(_dropdown_index, _o);
                if (_o == 0) _list_top = _opt_rect.top;
                if (_o == _option_count - 1) _list_bottom = _opt_rect.bottom;
            }

            var _base_rect = menuGetDropdownBaseRect(_dropdown_index);
            var _list_left = _base_rect.left;
            var _list_right = _base_rect.right;

            draw_set_color(make_color_rgb(20, 28, 52));
            draw_rectangle(_list_left, _list_top - 4, _list_right, _list_bottom + 4, false);
            draw_set_color(make_color_rgb(120, 130, 180));
            draw_rectangle(_list_left, _list_top - 4, _list_right, _list_bottom + 4, true);

            for (var _o = 0; _o < _option_count; _o++)
            {
                var _rect_opt = menuDropdownGetOptionRect(_dropdown_index, _o);
                var _hovering = variable_instance_exists(id, "menu_dropdown_hover") && menu_dropdown_hover == _o;
                var _current = (menuOptionGetIndex(_dropdown_entry) == _o);

                var _option_bg = make_color_rgb(28, 36, 60);
                if (!_dropdown_entry.enabled) _option_bg = make_color_rgb(40, 40, 40);
                else if (_hovering) _option_bg = make_color_rgb(70, 90, 140);
                else if (_current) _option_bg = make_color_rgb(48, 62, 98);

                draw_set_color(_option_bg);
                draw_rectangle(_rect_opt.left, _rect_opt.top, _rect_opt.right, _rect_opt.bottom, false);
                draw_set_color(make_color_rgb(16, 22, 40));
                draw_rectangle(_rect_opt.left, _rect_opt.top, _rect_opt.right, _rect_opt.bottom, true);

                var _option_color = _dropdown_entry.enabled ? c_white : _color_disabled;
                if (_hovering && _dropdown_entry.enabled) _option_color = _color_selected;
                draw_set_color(_option_color);
                draw_set_halign(fa_left);
                draw_text(_rect_opt.left + 10, _rect_opt.y, menuOptionGetLabelForIndex(_dropdown_entry, _o));
            }

            draw_set_halign(fa_center);
        }
    }

    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_text(_W * 0.5, _H * 0.88, "Use Arrow Keys / Mouse to adjust. Enter to activate.");
}
