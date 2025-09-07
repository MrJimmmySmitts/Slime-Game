// Simple keyboard navigation (Up/Down, Enter)
if (keyboard_check_pressed(vk_up))   sel = (sel - 1 + array_length(menu_items)) mod array_length(menu_items);
if (keyboard_check_pressed(vk_down)) sel = (sel + 1) mod array_length(menu_items);

if (keyboard_check_pressed(vk_enter)) {
    var choice = menu_items[sel];
    if (choice == "New") {
        room_goto(rm_game);
    } else if (choice == "Continue") {
        // Stub: load last save if implemented
        room_goto(rm_game);
    } else if (choice == "Load") {
        // Stub: show load UI
    } else if (choice == "Settings") {
        // Stub: show settings
    } else if (choice == "Quit") {
        game_end();
    }
}
