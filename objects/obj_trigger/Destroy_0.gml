/*
* Name: obj_trigger.Destroy
* Description: Forward destroy event to the behaviour struct.
*/
if (is_struct(trigger_behaviour))
{
    trigger_behaviour.onDestroy();
    trigger_behaviour = undefined;
}
