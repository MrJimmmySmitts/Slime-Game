/*
* Name: obj_enemy.Create
* Description: Initialise health and ammo drop configuration.
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

// Ammo drop configuration
ammo_drop_min   = 3;   // minimum ammo pickups
ammo_drop_max   = 5;   // maximum ammo pickups

/*
* Name: obj_enemy.Create (base init)
* Description: Initialise enemy defaults and cache collision tilemap.
*/
enemyBaseInit();
