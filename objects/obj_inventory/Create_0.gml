/*
* Name: obj_inventory.Create
* Description: Initialise the previous-state tracker for inventory toggling.
*/
{
    if (!variable_global_exists("inv_prev_state")) {
        global.inv_prev_state = GameState.Playing;
    }
}