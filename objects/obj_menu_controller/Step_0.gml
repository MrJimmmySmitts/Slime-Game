/*
* Name: obj_menu_controller.Step (mouse + keys)
* Description: TAB toggles inventory when no menu is visible; ESC backs out of settings/pause; keyboard & mouse drive menu.
*/
{
    var _in_game = (room != rm_start);

    if (!global.menuVisible && inputBindingCheckPressed("inventory"))
    {
        invToggle();
    }

    if (!global.menuVisible && menuDebugIsEditing())
    {
        menuDebugCancelEditing();
    }

    if (keyboard_check_pressed(vk_escape))
    {
        if (menuKeybindingIsCapturing())
        {
            menuKeybindingCancelCapture();
        }
        else if (menuDebugIsEditing())
        {
            menuDebugCancelEditing();
        }
        else if (variable_instance_exists(id, "menu_dropdown_open") && menu_dropdown_open != -1)
        {
            menuDropdownClose();
        }
        else if (global.invVisible)
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

        menuDebugEnsureEditingEntryValid();
        if (menu_screen != MenuScreen.Settings && menuDebugIsEditing()) menuDebugCancelEditing();
        if (menu_screen != MenuScreen.Settings && menuKeybindingIsCapturing()) menuKeybindingCancelCapture();

        var _capturing = menuKeybindingIsCapturing();
        if (_capturing) menuKeybindingHandleCaptureInput();
        _capturing = menuKeybindingIsCapturing();
        if (_capturing && menuDebugIsEditing()) menuDebugCancelEditing();

        var _dropdown_index = (variable_instance_exists(id, "menu_dropdown_open")) ? menu_dropdown_open : -1;

        var _editing = menuDebugIsEditing();
        if (_editing) menuDebugHandleEditingInput();
        _editing = menuDebugIsEditing();

        if (menu_screen == MenuScreen.Settings && !_editing && !_capturing)
        {
            menuSettingsHandleKeyboardScroll();
        }

        if (_dropdown_index != -1)
        {
            if (!_editing && !_capturing && keyboard_check_pressed(vk_up)) menuDropdownStep(-1);
            if (!_editing && !_capturing && keyboard_check_pressed(vk_down)) menuDropdownStep(1);
            if (!_editing && !_capturing && keyboard_check_pressed(vk_left)) menuDropdownStep(-1);
            if (!_editing && !_capturing && keyboard_check_pressed(vk_right)) menuDropdownStep(1);
            if (!_editing && !_capturing && keyboard_check_pressed(vk_enter)) menuDropdownConfirm();
            if (!_editing && !_capturing && keyboard_check_pressed(vk_backspace)) menuDropdownClose();
        }
        else
        {
            var _count = is_array(menu_items) ? array_length(menu_items) : 0;
            if (_count > 0)
            {
                if (!_editing && !_capturing && keyboard_check_pressed(vk_up))
                {
                    sel = (sel - 1 + _count) mod _count;
                    if (menu_screen == MenuScreen.Settings) menuSettingsEnsureSelectionVisible();
                }
                if (!_editing && !_capturing && keyboard_check_pressed(vk_down))
                {
                    sel = (sel + 1) mod _count;
                    if (menu_screen == MenuScreen.Settings) menuSettingsEnsureSelectionVisible();
                }
                if (!_editing && !_capturing && keyboard_check_pressed(vk_left))
                {
                    menuAdjustSelection(-1);
                }
                if (!_editing && !_capturing && keyboard_check_pressed(vk_right))
                {
                    menuAdjustSelection(1);
                }
                if (!_editing && !_capturing && keyboard_check_pressed(vk_enter))
                {
                    menuActivateSelection();
                }
            }

            if (!_editing && !_capturing && keyboard_check_pressed(vk_backspace) && menu_screen == MenuScreen.Settings)
            {
                menuCloseSettings();
            }
        }

        // Mouse support
        menuMouseUpdate();
    }
}
