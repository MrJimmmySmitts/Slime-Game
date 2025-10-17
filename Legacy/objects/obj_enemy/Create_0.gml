// Safety: ensure engine motion is not active by default
hspeed    = 0;
vspeed    = 0;
speed     = 0;
direction = 0;

// Loot configuration
/*essence_drop_min_amount = 6;   // minimum essence units
essence_drop_max_amount = 10;  // maximum essence units
modifier_drop_min       = 1;   // minimum modifier stack size
modifier_drop_max       = 1;   // maximum modifier stack size
modifier_drop_id        = ItemId.None; // random modifier when none specified*/
stats = {};
enemyInit(stats, EnemyType.Melee);