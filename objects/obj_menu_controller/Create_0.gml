menu_screen = MenuScreen.Main;

menu_main = [
    { label: "New",      kind: MenuItemKind.Action, action: "new",      enabled: true },
    { label: "Continue", kind: MenuItemKind.Action, action: "continue", enabled: true },
    { label: "Load",     kind: MenuItemKind.Action, action: "load",     enabled: true },
    { label: "Settings", kind: MenuItemKind.Action, action: "settings", enabled: true },
    { label: "Quit",     kind: MenuItemKind.Action, action: "quit",     enabled: true }
];

menu_settings_index = 0;
var _main_len = array_length(menu_main);
for (var _i = 0; _i < _main_len; _i++)
{
    if (menu_main[_i].action == "settings")
    {
        menu_settings_index = _i;
        break;
    }
}

sel        = 0;
menu_items = [];

settings_debug_visible = false;

screen_size_options = [
    { label: "800 x 600 (1x)",   width:  800, height:  600 },
    { label: "1200 x 900 (1.5x)", width: 1200, height:  900 },
    { label: "1600 x 1200 (2x)",  width: 1600, height: 1200 }
];

settings_screen_index = 0;
if (variable_global_exists("Settings"))
{
    settings_screen_index = clamp(global.Settings.screen_size_index, 0, max(0, array_length(screen_size_options) - 1));
    global.Settings.screen_size_index = settings_screen_index;
}

if (is_array(screen_size_options) && array_length(screen_size_options) > 0)
{
    menuApplyScreenSize(screen_size_options[settings_screen_index]);
}

settings_debug_rooms = [
    { room: rm_start, name: "Start Menu" },
    { room: rm_game,  name: "Game" },
    { room: rm_game_2, name: "Game 2" }
];
settings_load_index = 0;

debug_stat_defs = [
    { label: "Player Max HP",   stat: "hp_max",             base: "base_hp_max",        step: 1,   min: 1,   max: 50,  decimals: 0, current: "hp",   current_behaviour: "match" },
    { label: "Player Max Ammo", stat: "ammo_max",           base: "base_ammo_max",      step: 5,   min: 0,   max: 999, decimals: 0, current: "ammo" },
    { label: "Move Speed",      stat: "move_speed",         base: "base_move_speed",    step: 0.1, min: 0,   max: 10,  decimals: 2, suffix: " px/step" },
    { label: "Dash Distance",   stat: "dash_distance_total", base: "base_dash_distance", step: 4,   min: 0,   max: 512, decimals: 0, suffix: " px" },
    { label: "Bullet Damage",   stat: "bullet_damage",      base: "base_bullet_damage", step: 1,   min: 1,   max: 50,  decimals: 0 }
];

menuRebuildItems();
