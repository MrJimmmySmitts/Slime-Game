/*
* Name: obj_enemy_2.Create
* Description: Child enemy setup.
*/
event_inherited();
hp_max = 45;
hp     = hp_max;
is_dead = false;
/*
* Name: obj_enemy_2.Create (overrides)
* Description: Faster, longer-range chaser.
*/
enemy_speed = 2;
enemy_range = 200;

// Override drop configuration
ammo_drop_min   = 3;
ammo_drop_max   = 4;
slime_drop_object = obj_slime_2;
slime_drop_min    = 1;
slime_drop_max    = 1;

