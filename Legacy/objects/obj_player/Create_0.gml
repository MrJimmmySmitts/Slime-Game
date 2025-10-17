/*
* Name: obj_player.Create
*/
player_init()
input_locked = true;      // checked by input helpers
alarm[0]     = 12;

// --- Essence container & health init ---
essence_per_container = PLAYER_HEALTH_ESSENCE;
hp_max                = PLAYER_HEALTH_MAX;
hp                    = hp_max;
essence_max           = hp_max * PLAYER_HEALTH_ESSENCE;
essence               = essence_max;
    
damage_cd   = 0;     // damage cooldown timer
flash_timer = 0;     // white flash timer when hit

base_hp_max                  = hp_max;
base_essence_per_container   = PLAYER_HEALTH_ESSENCE;
base_essence_bonus           = 0;
base_essence_max             = essence_max;
base_move_speed              = PLAYER_MOVE_SPEED;
base_dash_distance           = PLAYER_DASH_DISTANCE;
base_dash_time               = PLAYER_DASH_TIME;
base_dash_cooldown           = PLAYER_DASH_COOLDOWN;
base_fire_cooldown           = PLAYER_FIRE_COOLDOWN;
base_fire_damage             = PLAYER_FIRE_DAMAGE;
base_fire_speed              = PLAYER_FIRE_SPEED;

move_speed          = base_move_speed;
dash_distance_total = base_dash_distance;
dash_duration_max   = base_dash_time;
dash_cooldown_max   = base_dash_cooldown;
fire_cooldown       = base_fire_cooldown;
fire_damage       = base_fire_damage;
fire_speed        = base_fire_speed;

melee_cooldown      = 0;
melee_cooldown_max  = PLAYER_MELEE_COOLDOWN;
melee_range         = PLAYER_MELEE_RANGE;
melee_time          = PLAYER_MELEE_TIME;
melee_cost          = PLAYER_MELEE_ESSENCE_COST;

ability_damage_timer        = 0;
ability_damage_cooldown     = 0;
ability_damage_duration     = PLAYER_ABILITY_DURATION;
ability_damage_cooldown_max = PLAYER_ABILITY_COOLDOWN;
ability_damage_amount       = PLAYER_ABILITY_DAMAGE_BONUS;
ability_damage_cost         = PLAYER_ABILITY_ESSENCE_COST;
ability_damage_bonus        = 0;

