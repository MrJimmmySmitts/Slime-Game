/*
* Name: obj_enemy.Create
* Description: Initialise health and slime drop configuration.
*/
// (Optional) other shared init:
// move_speed = 1.5;
// ai_state   = 0;
hp_max           = 30;
hp               = hp_max;
is_dead          = false;
enemy_speed      = 1.5;

// Safety: ensure engine motion is not active by default
hspeed           = 0;
vspeed           = 0;
speed            = 0;
direction        = 0;
target           = noone;
// Default drop (child overrides this)
drop_pickup_obj = obj_slime_1;

slime_drop_min   = 1;   // minimum slime pickups
slime_drop_max   = 3;   // maximum slime pickups

/*
* Name: obj_enemy.Create (base init)
* Description: Initialise enemy defaults and cache collision tilemap.
*/
enemy_base_init();
