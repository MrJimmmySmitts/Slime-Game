/*
* Name: obj_inventory.Create
* Description: Initialise the previous-state tracker for inventory toggling.
*/
{
    if (!variable_global_exists("invPrevState")) {
        global.invPrevState = GameState.Playing;
    }
}