/*
* Name: obj_inventory.Step
* Description: Toggle the Inventory game state using Tab, remembering/restoring previous state.
*/
{
    if (keyboard_check_pressed(vk_tab))
    {
        if (game_get_state() == GameState.Inventory)
        {
            // Close inventory: restore previous state
            game_set_state(global.inv_prev_state);
        }
        else
        {
            // Open inventory: remember current state, then switch
            global.inv_prev_state = game_get_state();
            game_set_state(GameState.Inventory);
        }
    }
}
