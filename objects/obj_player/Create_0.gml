/*
* Name: obj_player.Create
*/
input_locked = true;      // checked by input helpers
alarm[0]     = 12;

// --- Essence container & health init ---
essence_per_container = ESSENCE_PER_CONTAINER;
hp_max                = PLAYER_START_CONTAINERS;
hp                    = hp_max;
essence_max           = hp_max * essence_per_container;
essence               = essence_max;
playerEssenceClamp(id);

damage_cd   = 0;          // damage cooldown timer
flash_timer = 0;          // white flash timer when hit

base_hp_max              = hp_max;
base_container_max       = hp_max;
base_essence_per_container = essence_per_container;
base_essence_bonus       = 0;
base_essence_max         = essence_max;
base_move_speed    = PLAYER_MOVE_SPEED;
base_dash_distance = PLAYER_DASH_DISTANCE;
base_dash_time     = PLAYER_DASH_TIME;
base_dash_cooldown = PLAYER_DASH_COOLDOWN;
base_fire_cooldown = FIRE_COOLDOWN_STEPS;
base_bullet_damage = PLAYER_BASE_BULLET_DAMAGE;
base_bullet_speed  = BULLET_SPEED;

move_speed          = base_move_speed;
dash_distance_total = base_dash_distance;
dash_duration_max   = base_dash_time;
dash_cooldown_max   = base_dash_cooldown;
fire_cooldown_steps = base_fire_cooldown;
bullet_damage       = base_bullet_damage;
bullet_speed        = base_bullet_speed;

