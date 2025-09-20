/*
* Name: obj_trigger.Create
* Description: Configure trigger behaviour and perform immediate setup.
*/
if (!variable_instance_exists(id, "trigger_kind")) trigger_kind = TriggerKind.LevelExit;
if (!variable_instance_exists(id, "spawn_interval_min")) spawn_interval_min = 60;
if (!variable_instance_exists(id, "spawn_interval_max")) spawn_interval_max = max(spawn_interval_min, 180);
if (!variable_instance_exists(id, "spawn_radius"))        spawn_radius = 200;
if (!variable_instance_exists(id, "spawn_attempts"))      spawn_attempts = 10;
if (!variable_instance_exists(id, "level_message"))       level_message = "Exit reached! Prepare for the next area.";
if (!variable_instance_exists(id, "level_final_message")) level_final_message = "You win! What would you like to do?";

trigger_behaviour = triggerCreateBehaviour(id, trigger_kind);

if (is_struct(trigger_behaviour))
{
    trigger_behaviour.onCreate();
    trigger_behaviour.onRoomStart();

}
else
{
    trigger_behaviour = undefined;
    show_debug_message("obj_trigger: failed to create behaviour for kind " + string(trigger_kind));
}
