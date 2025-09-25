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
enemy_activation_range = enemy_range;
enemy_leash_range      = enemy_activation_range + 96;

// Override drop configuration
essence_drop_min_amount = 3;
essence_drop_max_amount = 6;
modifier_drop_min     = 1;
modifier_drop_max     = 1;
modifier_drop_id      = ItemId.ModVelocity;

