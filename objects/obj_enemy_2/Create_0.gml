/* 
* Name: obj_enemy_2.Create
* Description: Child enemy setup; drops Slime2 pickups on death.
*/
event_inherited();
hp_max = 45;
hp     = hp_max;
is_dead = false;

// Which pickup object to drop (1–3 will spawn)
drop_pickup_obj = obj_slime_2;
