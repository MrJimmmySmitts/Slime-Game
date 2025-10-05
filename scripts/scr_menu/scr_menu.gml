// ====================================================================
// scr_menu.gml — menu layout, interaction helpers, and debug tools
// ====================================================================

enum MenuScreen
{
    Main     = 0,
    Settings = 1,
}

enum MenuItemKind
{
    Action      = 0,
    Slider      = 1,
    Option      = 2,
    Toggle      = 3,
    DebugStat   = 4,
    DebugAction = 5,
    Label       = 6,
}

/*
* Name: menuGetLayout
* Description: Return menu layout in GUI space for hit-testing and drawing.
*/
function menuGetLayout()
{
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    var _mode  = MenuScreen.Main;
    if (variable_instance_exists(id, "menu_screen")) _mode = menu_screen;

    var _start_y = (_mode == MenuScreen.Settings) ? _gui_h * 0.30 : _gui_h * 0.40;
    var _gap     = (_mode == MenuScreen.Settings) ? 26 : 28;
    var _item_w  = (_mode == MenuScreen.Settings) ? 420 : 360;

    return {
        cx:       _gui_w * 0.5,
        start_y:  _start_y, // MUST match Draw layout
        gap:      _gap,     // MUST match Draw spacing
        item_w:   _item_w,  // clickable width (centered on cx)
        item_h:   26        // clickable height
    };
}

/*
* Name: menuItemBounds
* Description: Clickable rect for item index (GUI space) → [left, top, right, bottom].
*/
function menuItemBounds(_index)
{
    var _L      = menuGetLayout();
    var _cx     = _L.cx;
    var _base_y = _L.start_y + _index * _L.gap;
    var _iw     = _L.item_w;
    var _ih     = _L.item_h;
    return [_cx - _iw * 0.5, _base_y - _ih * 0.5, _cx + _iw * 0.5, _base_y + _ih * 0.5];
}

function menuGetItemRect(_index)
{
    var _L      = menuGetLayout();
    var _cx     = _L.cx;
    var _base_y = _L.start_y + _index * _L.gap;
    var _half_w = _L.item_w * 0.5;
    var _half_h = _L.item_h * 0.5;
    return {
        left:   _cx - _half_w,
        right:  _cx + _half_w,
        top:    _base_y - _half_h,
        bottom: _base_y + _half_h,
        y:      _base_y
    };
}

function menuGetItemValueRect(_index)
{
    var _rect   = menuGetItemRect(_index);
    var _L      = menuGetLayout();
    var _pad    = 12;
    var _valueL = _rect.left + _L.item_w * 0.45;
    var _valueR = _rect.right - _pad;
    if (_valueR < _valueL)
    {
        var _mid = (_valueL + _valueR) * 0.5;
        _valueL = _mid;
        _valueR = _mid;
    }
    return {
        left:   _valueL,
        right:  _valueR,
        top:    _rect.top + 4,
        bottom: _rect.bottom - 4,
        y:      _rect.y
    };
}

function menuGetSliderTrackRect(_index)
{
    var _value_rect = menuGetItemValueRect(_index);
    var _track_h    = 6;
    return {
        left:   _value_rect.left,
        right:  _value_rect.right,
        top:    _value_rect.y - _track_h * 0.5,
        bottom: _value_rect.y + _track_h * 0.5,
        y:      _value_rect.y
    };
}

function menuGetDropdownBaseRect(_index)
{
    var _value_rect = menuGetItemValueRect(_index);
    return {
        left:   _value_rect.left,
        right:  _value_rect.right,
        top:    _value_rect.top,
        bottom: _value_rect.bottom,
        y:      (_value_rect.top + _value_rect.bottom) * 0.5
    };
}

function menuDropdownGetOptionRect(_index, _option_index)
{
    var _base      = menuGetDropdownBaseRect(_index);
    var _L         = menuGetLayout();
    var _gap       = 2;
    var _option_h  = _L.item_h;
    var _top       = _base.bottom + 4 + _option_index * (_option_h + _gap);
    var _bottom    = _top + _option_h;
    return {
        left:   _base.left,
        right:  _base.right,
        top:    _top,
        bottom: _bottom,
        y:      (_top + _bottom) * 0.5
    };
}

function menuGetNumberFieldRects(_index)
{
    var _value_rect = menuGetItemValueRect(_index);
    var _side_w     = 72;
    var _gap        = 6;
    var _mid_y      = (_value_rect.top + _value_rect.bottom) * 0.5;

    var _field_left  = _value_rect.left + _side_w + _gap;
    var _field_right = _value_rect.right - _side_w - _gap;

    if (_field_right < _field_left)
    {
        var _mid = (_field_left + _field_right) * 0.5;
        _field_left  = _mid;
        _field_right = _mid;
    }

    var _min_right = max(_value_rect.left, _field_left - _gap);
    var _max_left  = min(_value_rect.right, _field_right + _gap);

    return {
        field: {
            left:   _field_left,
            right:  _field_right,
            top:    _value_rect.top,
            bottom: _value_rect.bottom,
            y:      _mid_y
        },
        min: {
            left:   _value_rect.left,
            right:  _min_right,
            top:    _value_rect.top,
            bottom: _value_rect.bottom,
            y:      _mid_y
        },
        max: {
            left:   _max_left,
            right:  _value_rect.right,
            top:    _value_rect.top,
            bottom: _value_rect.bottom,
            y:      _mid_y
        },
        area: {
            left:   _value_rect.left,
            right:  _value_rect.right,
            top:    _value_rect.top,
            bottom: _value_rect.bottom,
            y:      _value_rect.y
        }
    };
}

/*
* Name: menuIndexAt
* Description: Menu index under the GUI-space point, or -1 if none.
*/
function menuIndexAt(_mx, _my)
{
    if (!is_array(menu_items)) return -1;
    var _n = array_length(menu_items);
    for (var _i = 0; _i < _n; _i++)
    {
        var _b = menuItemBounds(_i);
        if (_mx >= _b[0] && _mx <= _b[2] && _my >= _b[1] && _my <= _b[3]) return _i;
    }
    return -1;
}

function menuSliderGetStep(_entry)
{
    if (!is_struct(_entry)) return 0.1;
    if (variable_struct_exists(_entry, "step"))
    {
        var _step = _entry.step;
        if (is_real(_step) && _step > 0) return _step;
    }
    return 0.1;
}

function menuSliderGetRange(_entry)
{
    var _min = variable_struct_exists(_entry, "min") ? _entry.min : 0;
    var _max = variable_struct_exists(_entry, "max") ? _entry.max : 1;
    if (!is_real(_min)) _min = 0;
    if (!is_real(_max)) _max = 1;
    if (_max < _min)
    {
        var _swap = _min;
        _min = _max;
        _max = _swap;
    }
    return [_min, _max];
}

function menuSliderClampValue(_entry, _value)
{
    var _range = menuSliderGetRange(_entry);
    var _min   = _range[0];
    var _max   = _range[1];
    _value     = clamp(_value, _min, _max);

    var _step = menuSliderGetStep(_entry);
    if (_step > 0)
    {
        _value = round((_value - _min) / _step) * _step + _min;
        _value = clamp(_value, _min, _max);
    }

    return _value;
}

function menuSliderGetValue(_entry)
{
    var _target = variable_struct_exists(_entry, "target") ? _entry.target : "";

    if (_target == "volume")
    {
        if (!variable_global_exists("Settings")) return menuSliderClampValue(_entry, 1);
        var _value = global.Settings.master_volume;
        if (!is_real(_value)) _value = 1;
        return menuSliderClampValue(_entry, _value);
    }

    return 0;
}

function menuSliderApplyValue(_entry, _value)
{
    _value = menuSliderClampValue(_entry, _value);

    var _target = variable_struct_exists(_entry, "target") ? _entry.target : "";
    if (_target == "volume")
    {
        if (!variable_global_exists("Settings")) return;
        global.Settings.master_volume = _value;
        audio_master_gain(global.Settings.master_volume);
    }
}

function menuSliderValueFromMouse(_entry, _track, _mx)
{
    if (!is_struct(_track)) return menuSliderGetValue(_entry);

    var _range = menuSliderGetRange(_entry);
    var _min   = _range[0];
    var _max   = _range[1];
    var _span  = _track.right - _track.left;
    if (_span == 0) return _min;

    var _ratio = clamp((_mx - _track.left) / _span, 0, 1);
    var _value = _min + (_max - _min) * _ratio;
    return menuSliderClampValue(_entry, _value);
}

function menuMouseHandleSliderPress(_index, _entry, _mx, _my)
{
    if (!is_struct(_entry)) return false;
    if (variable_struct_exists(_entry, "enabled") && !_entry.enabled) return false;

    var _track = menuGetSliderTrackRect(_index);
    var _hit_t = _track.top - 8;
    var _hit_b = _track.bottom + 8;

    if (_mx < _track.left || _mx > _track.right || _my < _hit_t || _my > _hit_b) return false;

    var _value = menuSliderValueFromMouse(_entry, _track, _mx);
    menuSliderApplyValue(_entry, _value);

    if (variable_instance_exists(id, "menu_slider_drag_index")) menu_slider_drag_index = _index;

    return true;
}

function menuMouseHandleSliderDrag(_index, _entry, _mx)
{
    if (!is_struct(_entry)) return;
    if (variable_struct_exists(_entry, "enabled") && !_entry.enabled) return;

    var _track = menuGetSliderTrackRect(_index);
    var _value = menuSliderValueFromMouse(_entry, _track, _mx);
    menuSliderApplyValue(_entry, _value);
}

function menuMouseHandleDebugStatPress(_index, _entry, _mx, _my)
{
    if (!is_struct(_entry)) return false;
    if (variable_struct_exists(_entry, "enabled") && !_entry.enabled) return false;

    var _rects = menuGetNumberFieldRects(_index);
    if (!is_struct(_rects)) return false;

    var _field = _rects.field;

    if (point_in_rectangle(_mx, _my, _field.left, _field.top, _field.right, _field.bottom))
    {
        if (!menuDebugIsEditingIndex(_index)) menuDebugStartEditing(_index);
        return true;
    }

    return false;
}

function menuOptionGetCount(_entry)
{
    if (!is_struct(_entry)) return 0;
    var _target = variable_struct_exists(_entry, "target") ? _entry.target : "";

    if (_target == "screen_size")
    {
        return is_array(screen_size_options) ? array_length(screen_size_options) : 0;
    }

    if (_target == "debug_room")
    {
        return is_array(settings_debug_rooms) ? array_length(settings_debug_rooms) : 0;
    }

    return 0;
}

function menuOptionGetIndex(_entry)
{
    var _count = menuOptionGetCount(_entry);
    if (_count <= 0) return -1;

    var _target = variable_struct_exists(_entry, "target") ? _entry.target : "";

    if (_target == "screen_size")
    {
        settings_screen_index = clamp(settings_screen_index, 0, _count - 1);
        return settings_screen_index;
    }

    if (_target == "debug_room")
    {
        settings_load_index = clamp(settings_load_index, 0, _count - 1);
        return settings_load_index;
    }

    return -1;
}

function menuOptionSetIndex(_entry, _index)
{
    var _target = variable_struct_exists(_entry, "target") ? _entry.target : "";

    if (_target == "screen_size")
    {
        if (!is_array(screen_size_options)) return;
        var _count = array_length(screen_size_options);
        if (_count <= 0) return;

        _index = clamp(_index, 0, _count - 1);
        settings_screen_index = _index;
        if (variable_global_exists("Settings")) global.Settings.screen_size_index = settings_screen_index;

        var _option = screen_size_options[settings_screen_index];
        menuApplyScreenSize(_option);
    }
    else if (_target == "debug_room")
    {
        if (!is_array(settings_debug_rooms)) return;
        var _count = array_length(settings_debug_rooms);
        if (_count <= 0) return;

        _index = clamp(_index, 0, _count - 1);
        settings_load_index = _index;

        menuDebugLoadSelectedRoom();
    }
}

function menuOptionGetLabelForIndex(_entry, _index)
{
    var _target = variable_struct_exists(_entry, "target") ? _entry.target : "";

    if (_target == "screen_size")
    {
        if (!is_array(screen_size_options) || array_length(screen_size_options) <= 0) return "(not available)";
        _index = clamp(_index, 0, array_length(screen_size_options) - 1);
        var _option = screen_size_options[_index];
        if (is_struct(_option))
        {
            if (variable_struct_exists(_option, "label")) return _option.label;
            if (variable_struct_exists(_option, "width") && variable_struct_exists(_option, "height"))
            {
                return string(_option.width) + " x " + string(_option.height);
            }
        }
        return "(invalid)";
    }

    if (_target == "debug_room")
    {
        return menuDebugGetRoomLabelForIndex(_index);
    }

    return "";
}

function menuOptionGetCurrentLabel(_entry)
{
    var _index = menuOptionGetIndex(_entry);
    if (_index < 0) return "(not available)";
    return menuOptionGetLabelForIndex(_entry, _index);
}

function menuDropdownOpen(_index)
{
    if (!is_array(menu_items)) return;
    if (!variable_instance_exists(id, "menu_dropdown_open")) return;
    if (_index < 0 || _index >= array_length(menu_items)) return;

    var _entry = menu_items[_index];
    if (!is_struct(_entry)) return;
    if (variable_struct_exists(_entry, "enabled") && !_entry.enabled) return;
    if (_entry.kind != MenuItemKind.Option) return;

    var _count = menuOptionGetCount(_entry);
    if (_count <= 0) return;

    menu_dropdown_open = _index;
    if (variable_instance_exists(id, "menu_dropdown_hover"))
    {
        menu_dropdown_hover = menuOptionGetIndex(_entry);
        if (menu_dropdown_hover < 0) menu_dropdown_hover = 0;
        menu_dropdown_hover = clamp(menu_dropdown_hover, 0, _count - 1);
    }
}

function menuDropdownClose()
{
    if (variable_instance_exists(id, "menu_dropdown_open")) menu_dropdown_open = -1;
    if (variable_instance_exists(id, "menu_dropdown_hover")) menu_dropdown_hover = -1;
}

function menuDropdownStep(_dir)
{
    if (_dir == 0) return;
    if (!is_array(menu_items)) return;
    if (!variable_instance_exists(id, "menu_dropdown_open")) return;
    if (menu_dropdown_open == -1) return;

    var _index = menu_dropdown_open;
    if (_index < 0 || _index >= array_length(menu_items)) return;

    var _entry = menu_items[_index];
    if (!is_struct(_entry) || _entry.kind != MenuItemKind.Option) return;

    var _count = menuOptionGetCount(_entry);
    if (_count <= 0) return;

    if (variable_instance_exists(id, "menu_dropdown_hover"))
    {
        if (menu_dropdown_hover < 0) menu_dropdown_hover = menuOptionGetIndex(_entry);
        if (menu_dropdown_hover < 0) menu_dropdown_hover = 0;
        menu_dropdown_hover = (menu_dropdown_hover + _dir + _count) mod _count;
    }
}

function menuDropdownConfirm()
{
    if (!is_array(menu_items)) return;
    if (!variable_instance_exists(id, "menu_dropdown_open")) return;
    if (menu_dropdown_open == -1) return;

    var _index = menu_dropdown_open;
    if (_index < 0 || _index >= array_length(menu_items))
    {
        menuDropdownClose();
        return;
    }

    var _entry = menu_items[_index];
    if (!is_struct(_entry) || _entry.kind != MenuItemKind.Option)
    {
        menuDropdownClose();
        return;
    }

    var _count = menuOptionGetCount(_entry);
    if (_count <= 0)
    {
        menuDropdownClose();
        return;
    }

    var _choice = variable_instance_exists(id, "menu_dropdown_hover") ? menu_dropdown_hover : -1;
    if (_choice < 0) _choice = menuOptionGetIndex(_entry);
    if (_choice < 0) _choice = 0;
    _choice = clamp(_choice, 0, _count - 1);

    menuOptionSetIndex(_entry, _choice);
    menuDropdownClose();

    if (menu_screen == MenuScreen.Settings) menuRebuildItems();
}

function menuDropdownOptionAtPosition(_index, _entry, _mx, _my)
{
    if (!is_struct(_entry)) return -1;
    if (_entry.kind != MenuItemKind.Option) return -1;

    var _count = menuOptionGetCount(_entry);
    if (_count <= 0) return -1;

    for (var _i = 0; _i < _count; _i++)
    {
        var _rect = menuDropdownGetOptionRect(_index, _i);
        if (_mx >= _rect.left && _mx <= _rect.right && _my >= _rect.top && _my <= _rect.bottom)
        {
            return _i;
        }
    }

    return -1;
}

function menuBuildKeyMappingItems()
{
    return [
        { label: "Key Bindings", kind: MenuItemKind.Label, style: "header", enabled: false },
        { label: "Move: WASD or Arrow Keys", kind: MenuItemKind.Label, enabled: false },
        { label: "Aim: IJKL", kind: MenuItemKind.Label, enabled: false },
        { label: "Dash: Space", kind: MenuItemKind.Label, enabled: false },
        { label: "Primary Fire: Mouse Left", kind: MenuItemKind.Label, enabled: false },
        { label: "Melee: Shift (uses essence)", kind: MenuItemKind.Label, enabled: false },
        { label: "Ability: E (damage boost)", kind: MenuItemKind.Label, enabled: false },
        { label: "Inventory: Tab", kind: MenuItemKind.Label, enabled: false },
    ];
}

/*
* Name: menuRebuildItems
* Description: Build the current menu item list (main/settings/debug overlays).
*/
function menuRebuildItems()
{
    if (!variable_instance_exists(id, "menu_screen")) return;

    var _items = [];

    if (!is_array(menu_main)) menu_main = [];

    switch (menu_screen)
    {
        case MenuScreen.Main:
        {
            var _len = array_length(menu_main);
            for (var _i = 0; _i < _len; _i++) _items[array_length(_items)] = menu_main[_i];
            break;
        }

        case MenuScreen.Settings:
        {
            var _slot = array_length(_items);
            _items[_slot] = {
                label:   "Master Volume",
                kind:    MenuItemKind.Slider,
                target:  "volume",
                step:    0.1,
                min:     0,
                max:     1,
                enabled: true
            };

            _slot = array_length(_items);
            _items[_slot] = {
                label:   "Screen Size",
                kind:    MenuItemKind.Option,
                target:  "screen_size",
                enabled: is_array(screen_size_options) && array_length(screen_size_options) > 0
            };

            var _key_items = menuBuildKeyMappingItems();
            if (is_array(_key_items))
            {
                var _key_count = array_length(_key_items);
                for (var _k = 0; _k < _key_count; _k++)
                {
                    _items[array_length(_items)] = _key_items[_k];
                }
            }

            _slot = array_length(_items);
            _items[_slot] = {
                label:   settings_debug_visible ? "Hide Debug Options" : "Show Debug Options",
                kind:    MenuItemKind.Toggle,
                target:  "debug_panel",
                enabled: true
            };

            if (settings_debug_visible)
            {
                var _player        = menuDebugGetPlayer();
                var _player_exists = instance_exists(_player);

                if (is_array(debug_stat_defs))
                {
                    var _count = array_length(debug_stat_defs);
                    for (var _i = 0; _i < _count; _i++)
                    {
                        var _def    = debug_stat_defs[_i];
                        var _suffix = variable_struct_exists(_def, "suffix") ? _def.suffix : "";
                        var _label  = string(_def.label);

                        _slot = array_length(_items);
                        _items[_slot] = {
                            label:             _label,
                            kind:              MenuItemKind.DebugStat,
                            stat:              _def.stat,
                            base:              variable_struct_exists(_def, "base") ? _def.base : undefined,
                            step:              variable_struct_exists(_def, "step") ? _def.step : 1,
                            min:               variable_struct_exists(_def, "min") ? _def.min : -1000000000,
                            max:               variable_struct_exists(_def, "max") ? _def.max : 1000000000,
                            decimals:          variable_struct_exists(_def, "decimals") ? _def.decimals : 0,
                            suffix:            _suffix,
                            current:           variable_struct_exists(_def, "current") ? _def.current : undefined,
                            current_behaviour: variable_struct_exists(_def, "current_behaviour") ? _def.current_behaviour : "clamp",
                            enabled:           _player_exists
                        };
                    }
                }

                _slot = array_length(_items);
                _items[_slot] = {
                    label:   "God Mode: " + (menuIsGodModeEnabled() ? "ON" : "OFF"),
                    kind:    MenuItemKind.Toggle,
                    target:  "god_mode",
                    enabled: true
                };

                _slot = array_length(_items);
                _items[_slot] = {
                    label:   "Spawn Enemy",
                    kind:    MenuItemKind.DebugAction,
                    action:  "spawn_enemy",
                    enabled: true
                };

                _slot = array_length(_items);
                _items[_slot] = {
                    label:   "Load Level",
                    kind:    MenuItemKind.Option,
                    target:  "debug_room",
                    enabled: is_array(settings_debug_rooms) && array_length(settings_debug_rooms) > 0
                };
            }

            _slot = array_length(_items);
            _items[_slot] = {
                label:   "Back",
                kind:    MenuItemKind.Action,
                action:  "back",
                enabled: true
            };
            break;
        }
    }

    menu_items = _items;

    var _count = array_length(menu_items);
    if (_count <= 0) sel = 0;
    else sel = clamp(sel, 0, _count - 1);

    if (variable_instance_exists(id, "menu_dropdown_open"))
    {
        if (menu_dropdown_open != -1)
        {
            if (menu_dropdown_open >= _count)
            {
                menuDropdownClose();
            }
            else
            {
                var _dropdown_entry = menu_items[menu_dropdown_open];
                if (!is_struct(_dropdown_entry) || _dropdown_entry.kind != MenuItemKind.Option)
                {
                    menuDropdownClose();
                }
                else if (variable_struct_exists(_dropdown_entry, "enabled") && !_dropdown_entry.enabled)
                {
                    menuDropdownClose();
                }
            }
        }
    }

    if (variable_instance_exists(id, "menu_slider_drag_index"))
    {
        if (menu_slider_drag_index != -1)
        {
            if (menu_slider_drag_index >= _count)
            {
                menu_slider_drag_index = -1;
            }
            else
            {
                var _slider_entry = menu_items[menu_slider_drag_index];
                if (!is_struct(_slider_entry) || _slider_entry.kind != MenuItemKind.Slider)
                {
                    menu_slider_drag_index = -1;
                }
                else if (variable_struct_exists(_slider_entry, "enabled") && !_slider_entry.enabled)
                {
                    menu_slider_drag_index = -1;
                }
            }
        }
    }
}

/*
* Name: menuActivateSelection
* Description: Perform the currently selected action (same as pressing Enter).
*/
function menuActivateSelection()
{
    if (!is_array(menu_items)) return;
    var _count = array_length(menu_items);
    if (_count <= 0) return;
    if (sel < 0 || sel >= _count) return;

    var _entry = menu_items[sel];
    if (!is_struct(_entry)) return;
    if (variable_struct_exists(_entry, "enabled") && !_entry.enabled) return;

    if (_entry.kind != MenuItemKind.Option && variable_instance_exists(id, "menu_dropdown_open")) menuDropdownClose();

    switch (_entry.kind)
    {
        case MenuItemKind.Action:
        {
            var _choice = variable_struct_exists(_entry, "action") ? _entry.action : "";
            if (_choice == "new")
            {
                dialogQueuePush("Welcome to the world of slime, there is too much non-slime around, you should fix that.");
                menuHide();
                room_goto(rm_game);
            }
            else if (_choice == "continue")
            {
                dialogQueuePush("Welcome back to the world of slime. You know what to do.");
                menuHide();
                room_goto(rm_game);
            }
            else if (_choice == "load")
            {
                // TODO
            }
            else if (_choice == "settings")
            {
                menuOpenSettings();
            }
            else if (_choice == "back")
            {
                menuCloseSettings();
            }
            else if (_choice == "quit")
            {
                game_end();
            }
            break;
        }

        case MenuItemKind.Slider:
        {
            menuAdjustSelection(1);
            break;
        }

        case MenuItemKind.DebugStat:
        {
            if (menuDebugIsEditingIndex(sel))
            {
                menuDebugSubmitEditing();
            }
            else
            {
                menuDebugStartEditing(sel);
            }
            break;
        }

        case MenuItemKind.Option:
        {
            if (variable_instance_exists(id, "menu_dropdown_open") && menu_dropdown_open == sel)
            {
                menuDropdownConfirm();
            }
            else
            {
                menuDropdownOpen(sel);
            }
            break;
        }

        case MenuItemKind.Toggle:
        {
            menuToggleEntry(_entry);
            break;
        }

        case MenuItemKind.DebugAction:
        {
            var _action = variable_struct_exists(_entry, "action") ? _entry.action : "";
            if (_action == "spawn_enemy") menuDebugSpawnEnemy();
            break;
        }

        case MenuItemKind.Label:
        {
            break;
        }
    }

    if (menu_screen == MenuScreen.Settings) menuRebuildItems();
}

/*
* Name: menuMouseUpdate
* Description: When menu is visible, hover to select and click (LMB/RMB) to activate or adjust.
*/
function menuMouseUpdate()
{
    if (!global.menuVisible) return;
    if (!is_array(menu_items)) return;

    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    if (mouse_check_button_pressed(mb_left) && menuDebugIsEditing())
    {
        var _edit_index = menu_number_edit_index;
        var _inside_item = false;

        if (is_array(menu_items) && _edit_index >= 0 && _edit_index < array_length(menu_items))
        {
            var _bounds = menuItemBounds(_edit_index);
            _inside_item = (_mx >= _bounds[0] && _mx <= _bounds[2] && _my >= _bounds[1] && _my <= _bounds[3]);
        }

        if (!_inside_item)
        {
            if (!menuDebugSubmitEditing()) menuDebugCancelEditing();
        }
    }

    var _count = array_length(menu_items);

    if (variable_instance_exists(id, "menu_slider_drag_index") && mouse_check_button_released(mb_left))
    {
        menu_slider_drag_index = -1;
    }

    var _dropdown_index = -1;
    var _dropdown_entry = undefined;
    if (variable_instance_exists(id, "menu_dropdown_open"))
    {
        _dropdown_index = menu_dropdown_open;
        if (_dropdown_index != -1 && _dropdown_index < _count)
        {
            _dropdown_entry = menu_items[_dropdown_index];
            if (!is_struct(_dropdown_entry) || _dropdown_entry.kind != MenuItemKind.Option)
            {
                _dropdown_index = -1;
                _dropdown_entry = undefined;
            }
        }
        else
        {
            _dropdown_index = -1;
            _dropdown_entry = undefined;
        }
    }

    if (_dropdown_index != -1 && is_struct(_dropdown_entry))
    {
        var _hover_option = menuDropdownOptionAtPosition(_dropdown_index, _dropdown_entry, _mx, _my);
        if (_hover_option != -1 && variable_instance_exists(id, "menu_dropdown_hover"))
        {
            menu_dropdown_hover = _hover_option;
        }
    }

    var _idx = menuIndexAt(_mx, _my);
    if (_idx != -1)
    {
        if (menuDebugIsEditing())
        {
            if (menuDebugIsEditingIndex(_idx)) sel = _idx;
        }
        else sel = _idx;
    }

    if (mouse_check_button_pressed(mb_left))
    {
        if (_dropdown_index != -1 && is_struct(_dropdown_entry))
        {
            var _selected_option = menuDropdownOptionAtPosition(_dropdown_index, _dropdown_entry, _mx, _my);
            if (_selected_option != -1)
            {
                if (variable_instance_exists(id, "menu_dropdown_hover")) menu_dropdown_hover = _selected_option;
                menuDropdownConfirm();
                return;
            }

            var _base_rect = menuGetDropdownBaseRect(_dropdown_index);
            if (point_in_rectangle(_mx, _my, _base_rect.left, _base_rect.top, _base_rect.right, _base_rect.bottom))
            {
                menuDropdownClose();
                return;
            }
            else if (_idx != _dropdown_index)
            {
                menuDropdownClose();
            }
        }

        if (_idx == -1)
        {
            if (variable_instance_exists(id, "menu_slider_drag_index")) menu_slider_drag_index = -1;
            if (variable_instance_exists(id, "menu_dropdown_open")) menuDropdownClose();
            return;
        }

        var _entry = menu_items[_idx];
        if (!is_struct(_entry)) return;

        if (variable_struct_exists(_entry, "enabled") && !_entry.enabled)
        {
            if (variable_instance_exists(id, "menu_slider_drag_index")) menu_slider_drag_index = -1;
            return;
        }

        switch (_entry.kind)
        {
            case MenuItemKind.Slider:
            {
                if (menuMouseHandleSliderPress(_idx, _entry, _mx, _my))
                {
                    if (variable_instance_exists(id, "menu_dropdown_open")) menuDropdownClose();
                    return;
                }
                menuAdjustSelection(1);
                return;
            }

            case MenuItemKind.Option:
            {
                var _base_rect = menuGetDropdownBaseRect(_idx);
                if (point_in_rectangle(_mx, _my, _base_rect.left, _base_rect.top, _base_rect.right, _base_rect.bottom))
                {
                    if (variable_instance_exists(id, "menu_dropdown_open") && menu_dropdown_open == _idx)
                    {
                        menuDropdownClose();
                    }
                    else
                    {
                        menuDropdownOpen(_idx);
                    }
                    return;
                }
                else
                {
                    if (variable_instance_exists(id, "menu_dropdown_open")) menuDropdownClose();
                }
                break;
            }

            case MenuItemKind.DebugStat:
            {
                if (menuMouseHandleDebugStatPress(_idx, _entry, _mx, _my))
                {
                    if (variable_instance_exists(id, "menu_dropdown_open")) menuDropdownClose();
                    return;
                }

                if (!menuDebugIsEditingIndex(_idx)) menuDebugStartEditing(_idx);
                if (variable_instance_exists(id, "menu_dropdown_open")) menuDropdownClose();
                return;
            }

            case MenuItemKind.Label:
            {
                return;
            }

            default:
            {
                menuActivateSelection();
                return;
            }
        }
    }

    if (mouse_check_button_pressed(mb_right))
    {
        if (variable_instance_exists(id, "menu_dropdown_open") && menu_dropdown_open != -1)
        {
            menuDropdownClose();
        }
        else
        {
            if (menuDebugIsEditing())
            {
                menuDebugCancelEditing();
            }
            else
            {
                menuAdjustSelection(-1);
            }
        }
    }

    if (mouse_check_button(mb_left))
    {
        if (variable_instance_exists(id, "menu_slider_drag_index") && menu_slider_drag_index != -1)
        {
            if (menu_slider_drag_index < _count)
            {
                var _drag_entry = menu_items[menu_slider_drag_index];
                if (is_struct(_drag_entry) && _drag_entry.kind == MenuItemKind.Slider)
                {
                    menuMouseHandleSliderDrag(menu_slider_drag_index, _drag_entry, _mx);
                }
            }
        }
    }
}

/*
* Name: menuAdjustSelection
* Description: Adjust the currently selected entry (e.g., sliders/options) by ±1 step.
*/
function menuAdjustSelection(_dir)
{
    if (_dir == 0) return;
    if (!is_array(menu_items)) return;
    var _count = array_length(menu_items);
    if (_count <= 0) return;
    if (sel < 0 || sel >= _count) return;

    var _entry = menu_items[sel];
    if (!is_struct(_entry)) return;
    if (variable_struct_exists(_entry, "enabled") && !_entry.enabled) return;

    switch (_entry.kind)
    {
        case MenuItemKind.Slider:
            menuAdjustSlider(_entry, _dir);
            break;

        case MenuItemKind.Option:
            if (variable_instance_exists(id, "menu_dropdown_open") && menu_dropdown_open == sel)
            {
                menuDropdownStep(_dir);
            }
            else
            {
                menuAdjustOption(_entry, _dir);
            }
            break;

        case MenuItemKind.Toggle:
            menuToggleEntry(_entry);
            break;

        case MenuItemKind.DebugStat:
            menuDebugAdjustStat(_entry, _dir);
            break;

        case MenuItemKind.Label:
            break;
    }

    if (menu_screen == MenuScreen.Settings) menuRebuildItems();
}

/*
* Name: menuToggleEntry
* Description: Toggle boolean-style entries (debug panel, god mode).
*/
function menuToggleEntry(_entry)
{
    if (!is_struct(_entry)) return;
    var _target = variable_struct_exists(_entry, "target") ? _entry.target : "";

    if (_target == "debug_panel")
    {
        settings_debug_visible = !settings_debug_visible;
    }
    else if (_target == "god_mode")
    {
        if (variable_global_exists("Settings"))
        {
            global.Settings.debug_god_mode = !global.Settings.debug_god_mode;
        }
    }

    if (menu_screen == MenuScreen.Settings) menuRebuildItems();
}

/*
* Name: menuAdjustSlider
* Description: Handle slider-style adjustments (currently master volume).
*/
function menuAdjustSlider(_entry, _dir)
{
    if (_dir == 0) return;
    if (!is_struct(_entry)) return;

    var _step = menuSliderGetStep(_entry);
    var _value = menuSliderGetValue(_entry) + _dir * _step;
    _value = menuSliderClampValue(_entry, _value);
    menuSliderApplyValue(_entry, _value);
}

/*
* Name: menuAdjustOption
* Description: Cycle through option lists (screen sizes, etc.).
*/
function menuAdjustOption(_entry, _dir)
{
    if (_dir == 0) return;
    if (!is_struct(_entry)) return;

    var _count = menuOptionGetCount(_entry);
    if (_count <= 0) return;

    var _index = menuOptionGetIndex(_entry);
    if (_index < 0) _index = 0;

    _index = (_index + _dir + _count) mod _count;

    menuOptionSetIndex(_entry, _index);
}

/*
* Name: menuOpenSettings
* Description: Switch to the settings screen and rebuild entries.
*/
function menuOpenSettings()
{
    menu_screen = MenuScreen.Settings;
    sel = 0;
    if (variable_instance_exists(id, "menu_dropdown_open")) menuDropdownClose();
    menuRebuildItems();
}

/*
* Name: menuCloseSettings
* Description: Return to the main menu screen and rebuild entries.
*/
function menuCloseSettings()
{
    menu_screen = MenuScreen.Main;
    if (variable_instance_exists(id, "menu_dropdown_open")) menuDropdownClose();
    var _len = is_array(menu_main) ? array_length(menu_main) : 0;
    if (_len > 0)
    {
        sel = clamp(menu_settings_index, 0, _len - 1);
    }
    else sel = 0;
    menuRebuildItems();
}

/*
* Name: menuGetScreenSizeLabel
* Description: Build the display label for the current screen size option.
*/
function menuGetScreenSizeLabel()
{
    var _entry = { target: "screen_size" };
    var _count = menuOptionGetCount(_entry);
    if (_count <= 0) return "Screen Size: (not available)";

    var _label = menuOptionGetCurrentLabel(_entry);
    if (_label == "") _label = "(invalid)";

    return "Screen Size: " + _label;
}

/*
* Name: menuApplyScreenSize
* Description: Apply the supplied screen size option to the game window/gui.
*/
function menuApplyScreenSize(_option)
{
    if (!is_struct(_option)) return;
    if (!variable_struct_exists(_option, "width")) return;
    if (!variable_struct_exists(_option, "height")) return;

    var _w = _option.width;
    var _h = _option.height;

    if (!is_real(_w) || !is_real(_h)) return;

    window_set_size(_w, _h);

    if (application_surface_is_enabled())
    {
        surface_resize(application_surface, _w, _h);
    }

    display_set_gui_size(_w, _h);
}

/*
* Name: menuIsGodModeEnabled
* Description: Helper to read the debug god-mode flag.
*/
function menuIsGodModeEnabled()
{
    if (!variable_global_exists("Settings")) return false;
    if (!is_struct(global.Settings)) return false;
    if (!variable_struct_exists(global.Settings, "debug_god_mode")) return false;
    return global.Settings.debug_god_mode;
}

/*
* Name: menuDebugGetPlayer
* Description: Return the first player instance or noone if none exist.
*/
function menuDebugGetPlayer()
{
    if (instance_exists(obj_player)) return instance_find(obj_player, 0);
    return noone;
}

/*
* Name: menuDebugDescribeStat
* Description: Format a player stat value for display in the debug panel.
*/
function menuDebugDescribeStat(_player, _def)
{
    if (!instance_exists(_player)) return "--";
    if (!is_struct(_def) || !variable_struct_exists(_def, "stat")) return "--";

    var _stat = _def.stat;
    if (!variable_instance_exists(_player, _stat)) return "--";

    var _value = variable_instance_get(_player, _stat);
    var _decimals = variable_struct_exists(_def, "decimals") ? max(0, _def.decimals) : 0;

    if (_decimals <= 0) return string(round(_value));
    return string_format(_value, 0, _decimals);
}

function menuDebugGetStatValue(_entry)
{
    if (!is_struct(_entry) || !variable_struct_exists(_entry, "stat")) return undefined;

    var _player = menuDebugGetPlayer();
    if (!instance_exists(_player)) return undefined;

    var _stat = _entry.stat;
    if (!variable_instance_exists(_player, _stat)) return undefined;

    return variable_instance_get(_player, _stat);
}

function menuDebugGetStatRange(_entry)
{
    var _min = variable_struct_exists(_entry, "min") ? _entry.min : -1000000000;
    var _max = variable_struct_exists(_entry, "max") ? _entry.max : 1000000000;

    if (!is_real(_min)) _min = -1000000000;
    if (!is_real(_max)) _max = 1000000000;

    if (_max < _min)
    {
        var _swap = _min;
        _min = _max;
        _max = _swap;
    }

    return [_min, _max];
}

function menuDebugFormatStatValue(_entry, _value)
{
    if (!is_real(_value)) return "--";

    var _decimals = variable_struct_exists(_entry, "decimals") ? max(0, _entry.decimals) : 0;
    if (_decimals <= 0) return string(round(_value));

    return string_format(_value, 0, _decimals);
}

function menuDebugGetStatDisplayValue(_entry)
{
    var _value = menuDebugGetStatValue(_entry);
    if (!is_real(_value)) return "--";

    var _text = menuDebugFormatStatValue(_entry, _value);
    var _suffix = variable_struct_exists(_entry, "suffix") ? _entry.suffix : "";

    return string(_text) + string(_suffix);
}

function menuDebugSetStatValue(_entry, _value)
{
    if (!is_struct(_entry) || !variable_struct_exists(_entry, "stat")) return false;

    var _player = menuDebugGetPlayer();
    if (!instance_exists(_player)) return false;

    var _stat = _entry.stat;
    if (!variable_instance_exists(_player, _stat)) return false;

    var _range = menuDebugGetStatRange(_entry);
    var _min   = _range[0];
    var _max   = _range[1];

    _value = clamp(_value, _min, _max);

    var _decimals = variable_struct_exists(_entry, "decimals") ? max(0, _entry.decimals) : 0;
    if (_decimals <= 0)
    {
        _value = round(_value);
    }
    else
    {
        var _mul = power(10, _decimals);
        _value = round(_value * _mul) / _mul;
    }

    variable_instance_set(_player, _stat, _value);

    if (variable_struct_exists(_entry, "base"))
    {
        var _base = _entry.base;
        if (variable_instance_exists(_player, _base)) variable_instance_set(_player, _base, _value);
    }

    if (variable_struct_exists(_entry, "current"))
    {
        var _current = _entry.current;
        if (variable_instance_exists(_player, _current))
        {
            if (variable_struct_exists(_entry, "current_behaviour") && _entry.current_behaviour == "match")
            {
                variable_instance_set(_player, _current, _value);
            }
            else
            {
                var _cur_value = variable_instance_get(_player, _current);
                if (_cur_value > _value) variable_instance_set(_player, _current, _value);
            }
        }
    }

    return true;
}

function menuDebugValidateInput(_entry, _text)
{
    if (!is_struct(_entry)) return false;

    if (!is_string(_text)) _text = string(_text);

    var _len = string_length(_text);
    if (_len <= 0) return false;

    var _range = menuDebugGetStatRange(_entry);
    var _allow_negative = (_range[0] < 0);
    var _decimals = variable_struct_exists(_entry, "decimals") ? max(0, _entry.decimals) : 0;

    var _has_digit   = false;
    var _has_decimal = false;

    for (var _i = 1; _i <= _len; _i++)
    {
        var _ch = string_char_at(_text, _i);

        if (_i == 1 && _ch == "-")
        {
            if (!_allow_negative) return false;
            continue;
        }

        if (_ch == ".")
        {
            if (_has_decimal || _decimals <= 0) return false;
            _has_decimal = true;
            continue;
        }

        if (_ch >= "0" && _ch <= "9")
        {
            _has_digit = true;
            continue;
        }

        return false;
    }

    if (!_has_digit) return false;

    var _value = real(_text);
    if (!is_real(_value)) return false;

    if (_value < _range[0] || _value > _range[1]) return false;

    return true;
}

function menuDebugIsEditing()
{
    if (!variable_instance_exists(id, "menu_number_edit_index")) return false;
    return menu_number_edit_index != -1;
}

function menuDebugIsEditingIndex(_index)
{
    if (!menuDebugIsEditing()) return false;
    return menu_number_edit_index == _index;
}

function menuDebugStartEditing(_index)
{
    if (!is_array(menu_items)) return;
    if (_index < 0 || _index >= array_length(menu_items)) return;

    var _entry = menu_items[_index];
    if (!is_struct(_entry) || _entry.kind != MenuItemKind.DebugStat) return;
    if (variable_struct_exists(_entry, "enabled") && !_entry.enabled) return;

    if (!variable_instance_exists(id, "menu_number_edit_index")) return;

    menu_number_edit_index = _index;

    var _value    = menuDebugGetStatValue(_entry);
    var _decimals = variable_struct_exists(_entry, "decimals") ? max(0, _entry.decimals) : 0;
    var _text     = "";

    if (is_real(_value))
    {
        if (_decimals <= 0) _text = string(round(_value));
        else _text = string_format(_value, 0, _decimals);
    }

    menu_number_edit_text = _text;
    if (_text == "") menu_number_edit_invalid = true;
    else menu_number_edit_invalid = !menuDebugValidateInput(_entry, _text);

    keyboard_string = _text;
}

function menuDebugCancelEditing()
{
    if (!variable_instance_exists(id, "menu_number_edit_index")) return;

    menu_number_edit_index  = -1;
    menu_number_edit_text   = "";
    menu_number_edit_invalid = false;
    keyboard_string = "";
}

function menuDebugSubmitEditing()
{
    if (!menuDebugIsEditing()) return false;
    if (!is_array(menu_items))
    {
        menuDebugCancelEditing();
        return false;
    }

    var _index = menu_number_edit_index;
    if (_index < 0 || _index >= array_length(menu_items))
    {
        menuDebugCancelEditing();
        return false;
    }

    var _entry = menu_items[_index];
    if (!is_struct(_entry) || _entry.kind != MenuItemKind.DebugStat)
    {
        menuDebugCancelEditing();
        return false;
    }

    if (!menuDebugValidateInput(_entry, menu_number_edit_text))
    {
        menu_number_edit_invalid = true;
        return false;
    }

    var _value = real(menu_number_edit_text);
    if (!menuDebugSetStatValue(_entry, _value))
    {
        menu_number_edit_invalid = true;
        return false;
    }

    menuDebugCancelEditing();
    return true;
}

function menuDebugHandleEditingInput()
{
    if (!menuDebugIsEditing()) return;
    if (!is_array(menu_items))
    {
        menuDebugCancelEditing();
        return;
    }

    var _index = menu_number_edit_index;
    if (_index < 0 || _index >= array_length(menu_items))
    {
        menuDebugCancelEditing();
        return;
    }

    var _entry = menu_items[_index];
    if (!is_struct(_entry) || _entry.kind != MenuItemKind.DebugStat)
    {
        menuDebugCancelEditing();
        return;
    }

    if (variable_struct_exists(_entry, "enabled") && !_entry.enabled)
    {
        menuDebugCancelEditing();
        return;
    }

    menu_number_edit_text = keyboard_string;
    menu_number_edit_invalid = !menuDebugValidateInput(_entry, menu_number_edit_text);

    if (keyboard_check_pressed(vk_enter))
    {
        if (!menuDebugSubmitEditing()) menu_number_edit_invalid = true;
    }
    else if (keyboard_check_pressed(vk_escape))
    {
        menuDebugCancelEditing();
    }
}

function menuDebugEnsureEditingEntryValid()
{
    if (!menuDebugIsEditing()) return;

    if (!is_array(menu_items))
    {
        menuDebugCancelEditing();
        return;
    }

    var _index = menu_number_edit_index;
    if (_index < 0 || _index >= array_length(menu_items))
    {
        menuDebugCancelEditing();
        return;
    }

    var _entry = menu_items[_index];
    if (!is_struct(_entry) || _entry.kind != MenuItemKind.DebugStat)
    {
        menuDebugCancelEditing();
        return;
    }

    if (variable_struct_exists(_entry, "enabled") && !_entry.enabled)
    {
        menuDebugCancelEditing();
        return;
    }
}

/*
* Name: menuDebugAdjustStat
* Description: Adjust a numeric player stat with clamping and optional base/current synchronisation.
*/
function menuDebugAdjustStat(_entry, _dir)
{
    if (_dir == 0) return;
    if (!is_struct(_entry) || !variable_struct_exists(_entry, "stat")) return;

    var _player = menuDebugGetPlayer();
    if (!instance_exists(_player)) return;

    var _stat = _entry.stat;
    if (!variable_instance_exists(_player, _stat)) return;

    var _step = variable_struct_exists(_entry, "step") ? _entry.step : 1;
    if (!is_real(_step)) _step = 1;

    var _value = variable_instance_get(_player, _stat);
    if (!is_real(_value)) _value = 0;

    _value += _dir * _step;

    menuDebugSetStatValue(_entry, _value);
}

/*
* Name: menuDebugCycleRoom
* Description: Cycle the debug room selection index.
*/
function menuDebugGetRoomLabelForIndex(_index)
{
    if (!is_array(settings_debug_rooms) || array_length(settings_debug_rooms) <= 0)
    {
        return "(no rooms)";
    }

    var _count = array_length(settings_debug_rooms);
    _index = clamp(_index, 0, _count - 1);

    var _entry = settings_debug_rooms[_index];
    if (!is_struct(_entry) || !variable_struct_exists(_entry, "room"))
    {
        return "(invalid)";
    }

    if (variable_struct_exists(_entry, "name"))
    {
        return _entry.name;
    }

    var _room_name = room_get_name(_entry.room);
    if (is_string(_room_name)) return string_replace_all(_room_name, "_", " ");

    return "(invalid)";
}

/*
* Name: menuDebugGetLoadRoomLabel
* Description: Format the label for the debug load-level entry.
*/
function menuDebugGetLoadRoomLabel()
{
    if (!is_array(settings_debug_rooms) || array_length(settings_debug_rooms) <= 0)
    {
        return "Load Level: (no rooms)";
    }

    var _count = array_length(settings_debug_rooms);
    settings_load_index = clamp(settings_load_index, 0, _count - 1);

    var _label = menuDebugGetRoomLabelForIndex(settings_load_index);
    if (_label == "") _label = "(invalid)";

    return "Load Level: " + _label;
}

/*
* Name: menuDebugLoadSelectedRoom
* Description: Jump to the currently selected debug room.
*/
function menuDebugLoadSelectedRoom()
{
    if (!is_array(settings_debug_rooms) || array_length(settings_debug_rooms) <= 0) return;

    var _count = array_length(settings_debug_rooms);
    settings_load_index = clamp(settings_load_index, 0, _count - 1);

    var _entry = settings_debug_rooms[settings_load_index];
    if (!is_struct(_entry) || !variable_struct_exists(_entry, "room")) return;

    menuHide();
    room_goto(_entry.room);
}

/*
* Name: menuDebugSpawnEnemy
* Description: Spawn a debug enemy near the player (or centre if no player).
*/
function menuDebugSpawnEnemy()
{
    var _player = menuDebugGetPlayer();

    var _spawn_x = room_width * 0.5;
    var _spawn_y = room_height * 0.5;
    var _layer_id = layer_get_id("Instances");

    if (instance_exists(_player))
    {
        _spawn_x = _player.x + 48;
        _spawn_y = _player.y;
        _layer_id = _player.layer;
    }

    if (_layer_id == -1) _layer_id = layer_get_id("Instances");
    if (_layer_id == -1) _layer_id = layer_create(0, "Instances_Debug");

    instance_create_layer(_spawn_x, _spawn_y, _layer_id, obj_enemy);
}
