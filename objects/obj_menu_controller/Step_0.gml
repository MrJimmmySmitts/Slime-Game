/*
* Name: obj_menu_controller.Step (mouse + keys)
* Description: TAB toggles inventory when no menu is visible; ESC backs out of settings/pause; keyboard & mouse drive menu.
*/
{
    var _in_game = (room != rm_start);

    if (!global.menuVisible && keyboard_check_pressed(vk_tab))
    {
        invToggle();
    }

    if (keyboard_check_pressed(vk_escape))
    {
        if (global.invVisible)
        {
            invHide();
        }
        else if (global.menuVisible && menu_screen == MenuScreen.Settings)
        {
            menuCloseSettings();
        }
        else if (_in_game)
        {
            menuToggle();
        }
    }

    if (global.menuVisible)
    {
        menuRebuildItems();

        var _count = is_array(menu_items) ? array_length(menu_items) : 0;
        if (_count > 0)
        {
            if (keyboard_check_pressed(vk_up))
            {
                sel = (sel - 1 + _count) mod _count;
            }
            if (keyboard_check_pressed(vk_down))
            {
                sel = (sel + 1) mod _count;
            }
            if (keyboard_check_pressed(vk_left))
            {
                menuAdjustSelection(-1);
            }
            if (keyboard_check_pressed(vk_right))
            {
                menuAdjustSelection(1);
            }
            if (keyboard_check_pressed(vk_enter))
            {
                menuActivateSelection();
            }
            if (keyboard_check_pressed(vk_backspace) && menu_screen == MenuScreen.Settings)
            {
                menuCloseSettings();
            }
        }

        // Mouse support
        menuMouseUpdate();
    }
}
