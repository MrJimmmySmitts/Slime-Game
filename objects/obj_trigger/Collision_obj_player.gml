/*
* Name: obj_trigger.Collision[obj_player]
* Description: Delegate collision handling to the configured behaviour.
*/
if (is_struct(trigger_behaviour))
{
    trigger_behaviour.onPlayerEnter(other);
}
