/*
* Name: obj_trigger_enemy_spawn.Step
* Description: Count down towards the next enemy spawn.
*/
event_inherited();

if (!triggerBaseIsActive())
{
    return;
}
if (onPauseExit())
{
    return;
}

if (spawn_timer > 0)
{
    spawn_timer -= 1;
}

if (spawn_timer <= 0)
{
    triggerEnemySpawnSpawnOnce();
}
