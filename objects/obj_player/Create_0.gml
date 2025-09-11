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
