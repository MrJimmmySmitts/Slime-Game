/*
* Name: obj_enemy_1.Create
* Description: Child enemy setup.
*/
enemy_type      = EnemyType.Melee;
enemy_toughness = EnemyToughness.Elite;

event_inherited();

hp     = hp_max;
is_dead = false;

/*
* Name: obj_enemy_1.Create (overrides)
* Description: Elite melee drops.
*/
// Override drop configuration
essence_drop_min_amount = 3;
essence_drop_max_amount = 6;
modifier_drop_min       = 1;
modifier_drop_max       = 1;
modifier_drop_id        = ItemId.ModVelocity;
