/*
* Name: obj_menu_controller.Step
* Description: Title vs in-game menu control; TAB toggles inventory only when no menu is up; ESC controls the pause menu in-game.
*/
{
    var in_game = (room == rm_game);

    // --- Toggle keys ---
    // TAB: only when no menu is visible (prevents double-toggle or odd states)
    if (!global.menu_visible && keyboard_check_pressed(vk_tab)) {
        inv_toggle();
    }

    // ESC: in-game -> toggle pause menu; on title -> (optional) do nothing or quit
    if (keyboard_check_pressed(vk_escape)) {
        if (global.inv_visible) {
            inv_hide();          // close inventory first if it was open
        } else if (in_game) {
            menu_toggle();       // pause menu in-game
        } else {
            // Title screen ESC behaviour (optional): game_end(); // or ignore
        }
    }

    // --- Menu navigation (only when visible) ---
    if (global.menu_visible) {
        // Up/Down selection (assumes sel/menu_items exist from Create)
        if (keyboard_check_pressed(vk_up))   sel = (sel - 1 + array_length(menu_items)) mod array_length(menu_items);
        if (keyboard_check_pressed(vk_down)) sel = (sel + 1) mod array_length(menu_items);

        if (keyboard_check_pressed(vk_enter)) {
            var choice = menu_items[sel];

            // IMPORTANT: use helpers so pause state updates correctly.
            if (choice == "New") {
                /*
                * Name: Menu action - New
                * Description: Hide menu, recompute pause, start game room.
                */
                menu_hide();           // replaces: global.menu_visible = false;
                room_goto(rm_game);
            }
            else if (choice == "Continue") {
                /*
                * Name: Menu action - Continue
                * Description: Hide menu and go to game; placeholder equals New for now.
                */
                menu_hide();
                room_goto(rm_game);
            }
            else if (choice == "Load") {
                // TODO: open a load UI (can keep menu up or push a subpanel)
            }
            else if (choice == "Settings") {
                // TODO: open settings panel (keep menu visible)
            }
            else if (choice == "Quit") {
                game_end();
            }
        }
    }
}
