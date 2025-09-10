/*
* Name: obj_menu_controller.Step (mouse + keys)
* Description: TAB toggles inventory when no menu is visible; ESC toggles pause in-game; mouse hover/click selection.
*/
{
    var _in_game = (room == rm_game);

    if (!global.menuVisible && keyboard_check_pressed(vk_tab)) {
        invToggle();
    }
    if (keyboard_check_pressed(vk_escape)) {
        if (global.invVisible) invHide();
        else if (_in_game)      menuToggle();
    }

    if (global.menuVisible) {
        if (keyboard_check_pressed(vk_up))   sel = (sel - 1 + array_length(menu_items)) mod array_length(menu_items);
        if (keyboard_check_pressed(vk_down)) sel = (sel + 1) mod array_length(menu_items);
        if (keyboard_check_pressed(vk_enter)) menuActivateSelection();

        // Mouse support
        menuMouseUpdate();
    }
}
