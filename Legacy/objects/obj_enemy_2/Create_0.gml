/*
* Name: obj_enemy_2.Create
* Description: Child enemy setup.
*/
type      = EnemyType.Ranged;
toughness = EnemyToughness.Normal;

event_inherited();

hp     = hp_max;
is_dead = false;

/*
* Name: obj_enemy_2.Create (overrides)
* Description: Ranged enemy drop configuration.
*/
// Override drop configuration
essence_drop_min_amount = 8;
essence_drop_max_amount = 12;
modifier_drop_min       = 1;
modifier_drop_max       = 1;
modifier_drop_id        = ItemId.ModCatalyst;
