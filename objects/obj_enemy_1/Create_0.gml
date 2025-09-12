/*
* Name: obj_enemy_1.Create
* Description: Child enemy setup.
*/
event_inherited();
hp_max = 30;
hp     = hp_max;
is_dead = false;
/*
* Name: obj_enemy_1.Create (overrides)
* Description: Faster, longer-range chaser.
*/
enemy_speed = 0.9;
enemy_range = 160;

// Override drop configuration
ammo_drop_min   = 1;
ammo_drop_max   = 2;
slime_drop_object = obj_slime_1;
slime_drop_min    = 1;
slime_drop_max    = 1;

