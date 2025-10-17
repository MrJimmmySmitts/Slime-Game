/*
* Name: obj_trigger_player_spawn.Room Start
* Description: Spawn or reposition the player when the room begins.
*/
event_inherited();

if (!trigger_spawned)
{
    triggerPlayerSpawnSpawnPlayer();
}
