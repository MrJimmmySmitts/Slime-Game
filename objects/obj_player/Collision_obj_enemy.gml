/*
* Name: obj_player.Collision[obj_enemy]
* Description: Apply damage with cooldown when touching enemies.
*/
if (damage_cd <= 0)
{
    if (variable_global_exists("Settings") && is_struct(global.Settings) && global.Settings.debug_god_mode) exit;
    hp -= 1;
    damage_cd = 60;    // invulnerability frames
    flash_timer = 15;  // flash white for a short time
}
