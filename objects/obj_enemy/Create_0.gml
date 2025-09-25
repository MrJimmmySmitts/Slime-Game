/*
* Name: obj_enemy.Create
* Description: Initialise health and essence drop configuration.
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
enemy_state      = EnemyState.Idle;
enemy_flash_timer = 0;
enemy_stun_timer  = 0;

// Loot configuration
essence_drop_min_amount = 6;   // minimum essence units
essence_drop_max_amount = 10;  // maximum essence units
modifier_drop_min     = 1;   // minimum modifier stack size
modifier_drop_max     = 1;   // maximum modifier stack size
modifier_drop_id      = ItemId.None; // random modifier when none specified

/*
* Name: obj_enemy.Create (base init)
* Description: Initialise enemy defaults and cache collision tilemap.
*/
enemyBaseInit();
