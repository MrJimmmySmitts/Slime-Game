/*
* Name: obj_trigger_level_exit.Create
* Description: Reset level exit bookkeeping.
*/
event_inherited();
triggerLevelInit();

if (!variable_instance_exists(id, "level_message"))
{
    level_message = "Exit reached! Prepare for the next area.";
}
if (!variable_instance_exists(id, "level_final_message"))
{
    level_final_message = "You win! What would you like to do?";
}
