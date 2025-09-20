/*
* Name: obj_player.Create
*/
input_locked = true;      // checked by input helpers
alarm[0]     = 12;

// --- Health & ammo init ---
hp_max      = 3;
hp          = hp_max;
damage_cd   = 0;          // damage cooldown timer
flash_timer = 0;          // white flash timer when hit

ammo_max    = 10;
ammo        = ammo_max;

base_hp_max        = hp_max;
base_ammo_max      = ammo_max;
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

