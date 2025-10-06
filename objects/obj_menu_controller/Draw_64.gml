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
    var _panel = menuSettingsGetPanelRect();
    var _view  = menuSettingsGetContentRect();

    draw_set_alpha(0.75);
    draw_set_color(make_color_rgb(20, 28, 52));
    draw_rectangle(_panel.left, _panel.top, _panel.right, _panel.bottom, false);
    draw_set_alpha(1);

    draw_set_color(c_white);
    draw_set_font(fnt_menu);
    var _title = (menu_screen == MenuScreen.SettingsControls) ? "Settings -> Controls" : "Settings";
    draw_text((_panel.left + _panel.right) * 0.5, _panel.top + 32, _title);
    draw_set_font(fnt_ui);

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

    var _current_scheme = menuSettingsGetControlScheme();

    for (var _i = 0; _i < _n; _i++)
    {
        var _item    = menu_items[_i];
        var _label   = is_struct(_item) && variable_struct_exists(_item, "label") ? _item.label : string(_item);
        var _enabled = !is_struct(_item) || !variable_struct_exists(_item, "enabled") || _item.enabled;
        var _rect    = menuGetItemRect(_i);
        var _selected = (_i == sel && _enabled);

        if (_rect.bottom < _view.top - _L.item_h || _rect.top > _view.bottom + _L.item_h) continue;

        if (is_struct(_item))
        {
            switch (_item.kind)
            {
                case MenuItemKind.Label:
                {
                    var _label_left = _rect.left + 16;
                    var _style      = variable_struct_exists(_item, "style") ? string(_item.style) : "";
                    draw_set_halign(fa_left);
                    if (_style == "header")
                    {
                        draw_set_color(make_color_rgb(180, 210, 255));
                        draw_set_font(fnt_menu);
                    }
                    else if (_style == "section")
                    {
                        draw_set_color(make_color_rgb(160, 180, 220));
                    }
                    else
                    {
                        draw_set_color(make_color_rgb(200, 200, 200));
                    }
                    draw_text(_label_left, _rect.y, string(_label));
                    draw_set_font(fnt_ui);
                    draw_set_halign(fa_center);
                    continue;
                }

                case MenuItemKind.Slider:
                {
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
                    var _base       = menuGetDropdownBaseRect(_i);
                    var _label_left = _rect.left + 16;
                    var _value_lbl  = menuOptionGetCurrentLabel(_item);
                    if (_value_lbl == "") _value_lbl = "(not available)";

                    draw_set_halign(fa_left);
                    draw_set_color(_enabled ? (_selected ? _color_selected : c_white) : _color_disabled);
                    draw_text(_label_left, _rect.y, string(_label));

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
                    draw_text(_base.left + 10, _rect.y, _value_lbl);

                    var _arrow_color = _enabled ? _value_color : _color_disabled;
                    if (_enabled && _dropdown_index == _i) _arrow_color = _color_selected;
                    var _arrow_x = _base.right - 12;
                    var _arrow_y = _rect.y + 1;
                    draw_set_color(_arrow_color);
                    draw_triangle(_arrow_x - 6, _arrow_y - 3, _arrow_x + 6, _arrow_y - 3, _arrow_x, _arrow_y + 4, false);

                    draw_set_halign(fa_center);
                    continue;
                }

                case MenuItemKind.KeyBinding:
                {
                    var _binding = variable_struct_exists(_item, "binding") ? _item.binding : undefined;
                    var _action  = (is_struct(_binding) && variable_struct_exists(_binding, "action")) ? _binding.action : "";
                    var _slot    = (is_struct(_binding) && variable_struct_exists(_binding, "slot")) ? _binding.slot : 0;
                    var _scheme   = (is_struct(_binding) && variable_struct_exists(_binding, "scheme")) ? _binding.scheme : menuSettingsGetControlScheme();
                    var _value_lbl = menuSettingsDescribeKeyBinding(_action, _slot, _scheme);
                    var _is_capture = menuKeybindingIsCapturingEntry(_item);
                    if (_is_capture) _value_lbl = "Press a key...";

                    var _value_rect = menuGetItemValueRect(_i);
                    var _label_left = _rect.left + 16;

                    draw_set_halign(fa_left);
                    draw_set_color(_enabled ? (_selected ? _color_selected : c_white) : _color_disabled);
                    draw_text(_label_left, _rect.y, string(_label));

                    var _bg_color = _enabled ? make_color_rgb(36, 44, 68) : make_color_rgb(46, 46, 46);
                    var _border_col = _enabled ? make_color_rgb(120, 130, 180) : make_color_rgb(70, 70, 70);
                    if (_selected && _enabled) _border_col = _color_selected;
                    if (_is_capture)
                    {
                        _bg_color   = make_color_rgb(48, 60, 96);
                        _border_col = make_color_rgb(150, 190, 255);
                    }

                    draw_set_color(_bg_color);
                    draw_rectangle(_value_rect.left, _value_rect.top, _value_rect.right, _value_rect.bottom, false);
                    draw_set_color(_border_col);
                    draw_rectangle(_value_rect.left, _value_rect.top, _value_rect.right, _value_rect.bottom, true);

                    var _value_color = _enabled ? (_selected || _is_capture ? _color_selected : c_white) : _color_disabled;
                    if (_is_capture) _value_color = make_color_rgb(200, 230, 255);
                    draw_set_color(_value_color);
                    draw_set_halign(fa_center);
                    draw_text((_value_rect.left + _value_rect.right) * 0.5, _value_rect.y, _value_lbl);
                    draw_set_halign(fa_center);
                    continue;
                }

                case MenuItemKind.Radio:
                {
                    var _value = variable_struct_exists(_item, "value") ? inputControlSchemeClamp(_item.value) : ControlScheme.KeyboardMouse;
                    var _is_checked = (_value == _current_scheme);
                    var _circle_x = _rect.left + 16;
                    var _circle_y = _rect.y;
                    var _radius   = 8;

                    var _outline_col = _enabled ? (_selected ? _color_selected : c_white) : _color_disabled;
                    draw_set_color(_outline_col);
                    draw_circle(_circle_x, _circle_y, _radius, true);

                    if (_is_checked)
                    {
                        var _fill_color = _enabled ? make_color_rgb(120, 180, 255) : make_color_rgb(80, 80, 80);
                        draw_set_color(_fill_color);
                        draw_circle(_circle_x, _circle_y, max(2, _radius - 3), false);
                    }

                    var _label_left = _circle_x + 16;
                    var _text_color = _enabled ? (_selected ? _color_selected : c_white) : _color_disabled;
                    draw_set_halign(fa_left);
                    draw_set_color(_text_color);
                    draw_text(_label_left, _circle_y, string(_label));
                    draw_set_halign(fa_center);
                    continue;
                }

                case MenuItemKind.DebugStat:
                {
                    var _rects       = menuGetNumberFieldRects(_i);
                    var _field_rect  = _rects.field;
                    var _min_rect    = _rects.min;
                    var _max_rect    = _rects.max;
                    var _range       = menuDebugGetStatRange(_item);
                    var _min_text    = menuDebugFormatStatValue(_item, _range[0]);
                    var _max_text    = menuDebugFormatStatValue(_item, _range[1]);
                    var _suffix_txt  = variable_struct_exists(_item, "suffix") ? string(_item.suffix) : "";
                    if (_suffix_txt != "")
                    {
                        if (_min_text != "--") _min_text = _min_text + _suffix_txt;
                        if (_max_text != "--") _max_text = _max_text + _suffix_txt;
                    }

                    var _is_editing  = menuDebugIsEditingIndex(_i);
                    var _value_text  = _is_editing ? string(menu_number_edit_text) : menuDebugGetStatDisplayValue(_item);
                    if (_is_editing && _value_text == "") _value_text = "";

                    var _label_color2 = _enabled ? (_selected ? _color_selected : c_white) : _color_disabled;
                    draw_set_halign(fa_left);
                    draw_set_color(_label_color2);
                    draw_text(_rect.left + 16, _rect.y, string(_label));

                    var _field_bg     = _enabled ? make_color_rgb(36, 44, 68) : make_color_rgb(46, 46, 46);
                    var _field_border = _enabled ? make_color_rgb(120, 130, 180) : make_color_rgb(70, 70, 70);
                    if (_selected && _enabled) _field_border = _color_selected;
                    if (_is_editing && _enabled) _field_border = make_color_rgb(150, 190, 255);
                    if (_is_editing) _field_bg = make_color_rgb(48, 60, 96);

                    var _invalid = _is_editing && menu_number_edit_invalid;
                    if (_invalid) _field_border = make_color_rgb(220, 80, 80);

                    draw_set_color(_field_bg);
                    draw_rectangle(_field_rect.left, _field_rect.top, _field_rect.right, _field_rect.bottom, false);
                    draw_set_color(_field_border);
                    draw_rectangle(_field_rect.left, _field_rect.top, _field_rect.right, _field_rect.bottom, true);

                    var _value_color2 = _enabled ? (_selected ? _color_selected : c_white) : _color_disabled;
                    if (_invalid) _value_color2 = make_color_rgb(255, 120, 120);
                    draw_set_color(_value_color2);
                    draw_set_halign(fa_center);
                    draw_set_valign(fa_middle);
                    draw_text((_field_rect.left + _field_rect.right) * 0.5, _field_rect.y, _value_text);

                    var _minmax_color = _enabled ? make_color_rgb(180, 190, 230) : _color_disabled;
                    draw_set_color(_minmax_color);
                    draw_set_halign(fa_right);
                    draw_text(_min_rect.right - 6, _field_rect.y, "Min: " + _min_text);
                    draw_set_halign(fa_left);
                    draw_text(_max_rect.left + 6, _field_rect.y, "Max: " + _max_text);

                    draw_set_valign(fa_middle);
                    draw_set_halign(fa_center);
                    continue;
                }
            }
        }

        var _text = string(_label);
        if (_selected) _text = "> " + _text + " <";

        var _style = is_struct(_item) && variable_struct_exists(_item, "style") ? string(_item.style) : "";
        var _base_color = c_white;
        if (_style == "primary" && _enabled) _base_color = make_color_rgb(180, 240, 180);
        else if (_style == "secondary" && _enabled) _base_color = make_color_rgb(190, 210, 255);

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
            draw_set_color(_base_color);
        }

        draw_set_halign(fa_center);
        draw_text(_L.cx, _rect.y, _text);
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

    var _content_h = menu_settings_content_height;
    var _view_h = menu_settings_view_height;
    if (_content_h > _view_h + 1)
    {
        var _bar_left  = _panel.right - 12;
        var _bar_right = _panel.right - 6;
        var _scroll    = menuSettingsGetScroll();
        var _max_scroll = max(1, menu_settings_scroll_max);
        var _thumb_height = max(24, (_view_h / _content_h) * _view_h);
        var _thumb_top = _view.top + (_view_h - _thumb_height) * (_scroll / _max_scroll);
        var _thumb_bottom = _thumb_top + _thumb_height;

        draw_set_color(make_color_rgb(32, 40, 64));
        draw_rectangle(_bar_left, _view.top, _bar_right, _view.bottom, false);
        draw_set_color(make_color_rgb(120, 180, 255));
        draw_rectangle(_bar_left, _thumb_top, _bar_right, _thumb_bottom, false);
        draw_set_color(make_color_rgb(16, 24, 40));
        draw_rectangle(_bar_left, _thumb_top, _bar_right, _thumb_bottom, true);
    }

    draw_set_halign(fa_center);
    draw_set_color(menu_settings_dirty ? make_color_rgb(255, 220, 160) : make_color_rgb(190, 200, 220));
    draw_text((_panel.left + _panel.right) * 0.5, _panel.bottom - 28, menu_settings_dirty ? "Unsaved changes • Press Apply to confirm" : "Adjust settings then press Apply to save changes");

    if (menuKeybindingIsCapturing())
    {
        draw_set_color(make_color_rgb(255, 200, 160));
        draw_text((_panel.left + _panel.right) * 0.5, _panel.bottom - 52, "Press a key to set the binding or click to cancel");
    }
}
