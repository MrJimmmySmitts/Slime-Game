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

// Ranged attack configuration
projectile_cooldown_max = 75; // steps between shots (configurable)
projectile_cooldown     = irandom_range(0, projectile_cooldown_max);
projectile_speed        = 4.5;
projectile_damage       = 1;
projectile_range        = enemy_range;

// Override drop configuration
stock_drop_min_amount = 8;
stock_drop_max_amount = 12;
modifier_drop_min     = 1;
modifier_drop_max     = 1;
modifier_drop_id      = ItemId.ModCatalyst;

