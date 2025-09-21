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
    DebugLoad   = 6,
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
            var _settings = variable_global_exists("Settings") ? global.Settings : undefined;
            var _volume   = 1.0;
            if (is_struct(_settings) && variable_struct_exists(_settings, "master_volume"))
            {
                _volume = clamp(_settings.master_volume, 0, 1);
            }
            var _volume_label = "Master Volume: " + string(round(_volume * 100)) + "%";
            var _slot = array_length(_items);
            _items[_slot] = {
                label:   _volume_label,
                kind:    MenuItemKind.Slider,
                target:  "volume",
                step:    0.1,
                enabled: true
            };

            _slot = array_length(_items);
            _items[_slot] = {
                label:   menuGetScreenSizeLabel(),
                kind:    MenuItemKind.Option,
                target:  "screen_size",
                enabled: is_array(screen_size_options) && array_length(screen_size_options) > 0
            };

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
                        var _def = debug_stat_defs[_i];
                        var _suffix = variable_struct_exists(_def, "suffix") ? _def.suffix : "";
                        var _value_label = menuDebugDescribeStat(_player, _def);
                        var _label = string(_def.label) + ": " + _value_label + _suffix;

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
                    label:   menuDebugGetLoadRoomLabel(),
                    kind:    MenuItemKind.DebugLoad,
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
        case MenuItemKind.Option:
        case MenuItemKind.DebugStat:
        {
            menuAdjustSelection(1);
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

        case MenuItemKind.DebugLoad:
        {
            menuDebugLoadSelectedRoom();
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

    var _idx = menuIndexAt(_mx, _my);
    if (_idx != -1) sel = _idx;
    else return;

    if (mouse_check_button_pressed(mb_left))
    {
        menuActivateSelection();
    }

    if (mouse_check_button_pressed(mb_right))
    {
        menuAdjustSelection(-1);
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
            menuAdjustOption(_entry, _dir);
            break;

        case MenuItemKind.Toggle:
            menuToggleEntry(_entry);
            break;

        case MenuItemKind.DebugStat:
            menuDebugAdjustStat(_entry, _dir);
            break;

        case MenuItemKind.DebugLoad:
            menuDebugCycleRoom(_dir);
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

    var _target = variable_struct_exists(_entry, "target") ? _entry.target : "";

    if (_target == "volume")
    {
        if (!variable_global_exists("Settings")) return;

        var _step = variable_struct_exists(_entry, "step") ? max(0.01, _entry.step) : 0.1;
        var _value = global.Settings.master_volume + _dir * _step;
        _value = clamp(_value, 0, 1);
        if (_step > 0)
        {
            _value = round(_value / _step) * _step;
        }
        _value = clamp(_value, 0, 1);

        global.Settings.master_volume = _value;
        audio_master_gain(audio_master, global.Settings.master_volume, 0);
    }
}

/*
* Name: menuAdjustOption
* Description: Cycle through option lists (screen sizes, etc.).
*/
function menuAdjustOption(_entry, _dir)
{
    if (_dir == 0) return;
    if (!is_struct(_entry)) return;

    var _target = variable_struct_exists(_entry, "target") ? _entry.target : "";

    if (_target == "screen_size")
    {
        if (!is_array(screen_size_options)) return;
        var _count = array_length(screen_size_options);
        if (_count <= 0) return;

        settings_screen_index = (settings_screen_index + _dir + _count) mod _count;
        if (variable_global_exists("Settings")) global.Settings.screen_size_index = settings_screen_index;

        var _option = screen_size_options[settings_screen_index];
        menuApplyScreenSize(_option);
    }
}

/*
* Name: menuOpenSettings
* Description: Switch to the settings screen and rebuild entries.
*/
function menuOpenSettings()
{
    menu_screen = MenuScreen.Settings;
    sel = 0;
    menuRebuildItems();
}

/*
* Name: menuCloseSettings
* Description: Return to the main menu screen and rebuild entries.
*/
function menuCloseSettings()
{
    menu_screen = MenuScreen.Main;
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
    if (!is_array(screen_size_options) || array_length(screen_size_options) <= 0)
    {
        return "Screen Size: (not available)";
    }

    var _count = array_length(screen_size_options);
    settings_screen_index = clamp(settings_screen_index, 0, _count - 1);

    var _option = screen_size_options[settings_screen_index];
    var _label  = "";

    if (is_struct(_option))
    {
        if (variable_struct_exists(_option, "label"))
        {
            _label = _option.label;
        }
        else if (variable_struct_exists(_option, "width") && variable_struct_exists(_option, "height"))
        {
            _label = string(_option.width) + " x " + string(_option.height);
        }
    }

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

/*
* Name: menuDebugAdjustStat
* Description: Adjust a numeric player stat with clamping and optional base/current synchronisation.
*/
function menuDebugAdjustStat(_entry, _dir)
{
    if (_dir == 0) return;
    var _player = menuDebugGetPlayer();
    if (!instance_exists(_player)) return;
    if (!is_struct(_entry) || !variable_struct_exists(_entry, "stat")) return;

    var _stat = _entry.stat;
    if (!variable_instance_exists(_player, _stat)) return;

    var _step     = variable_struct_exists(_entry, "step") ? _entry.step : 1;
    var _min      = variable_struct_exists(_entry, "min") ? _entry.min : -1000000000;
    var _max      = variable_struct_exists(_entry, "max") ? _entry.max : 1000000000;
    var _decimals = variable_struct_exists(_entry, "decimals") ? max(0, _entry.decimals) : 0;

    var _value = variable_instance_get(_player, _stat);
    _value += _dir * _step;
    _value = clamp(_value, _min, _max);

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
}

/*
* Name: menuDebugCycleRoom
* Description: Cycle the debug room selection index.
*/
function menuDebugCycleRoom(_dir)
{
    if (_dir == 0) return;
    if (!is_array(settings_debug_rooms)) return;
    var _count = array_length(settings_debug_rooms);
    if (_count <= 0) return;

    settings_load_index = (settings_load_index + _dir + _count) mod _count;
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

    var _entry = settings_debug_rooms[settings_load_index];
    if (!is_struct(_entry) || !variable_struct_exists(_entry, "room"))
    {
        return "Load Level: (invalid)";
    }

    var _label = "";
    if (variable_struct_exists(_entry, "name"))
    {
        _label = _entry.name;
    }
    else
    {
        var _room_name = room_get_name(_entry.room);
        _label = string_replace_all(_room_name, "_", " ");
    }

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
