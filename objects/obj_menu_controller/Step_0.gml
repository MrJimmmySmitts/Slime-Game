/*
* Name: obj_menu_controller.Step (mouse + keys)
* Description: TAB toggles inventory when no menu is visible; ESC toggles pause in-game; mouse hover/click selection.
*/
{
    var _in_game = (room == rm_game);

    if (!global.menu_visible && keyboard_check_pressed(vk_tab)) {
        inv_toggle();
    }
    if (keyboard_check_pressed(vk_escape)) {
        if (global.inv_visible) inv_hide();
        else if (_in_game)      menu_toggle();
    }

    if (global.menu_visible) {
        if (keyboard_check_pressed(vk_up))   sel = (sel - 1 + array_length(menu_items)) mod array_length(menu_items);
        if (keyboard_check_pressed(vk_down)) sel = (sel + 1) mod array_length(menu_items);
        if (keyboard_check_pressed(vk_enter)) menu_activate_selection();

        // Mouse support
        menu_mouse_update();
    }
}
