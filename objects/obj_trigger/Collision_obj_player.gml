/*
* Name: obj_trigger.Collision[obj_player]
* Description: Load the next room when the player touches the trigger.
*/
var next_room = room_next(room);
if (next_room != -1)
{
    room_goto(next_room);
}
else
{
    show_debug_message("obj_trigger: no next room available; restarting current room.");
    room_restart();
}
