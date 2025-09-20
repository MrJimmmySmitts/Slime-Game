/*
* Name: obj_trigger_level_exit.Collision[obj_player]
* Description: Advance the game when the player touches the exit.
*/
event_inherited();

if (!triggerBaseIsActive())
{
    return;
}

triggerLevelHandlePlayer(other);
