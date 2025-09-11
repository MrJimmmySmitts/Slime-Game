/*
* Name: obj_player.Collision[obj_enemy]
* Description: Apply damage with cooldown when touching enemies.
*/
if (damage_cd <= 0)
{
    hp -= 1;
    damage_cd = 60;    // invulnerability frames
    flash_timer = 15;  // flash white for a short time
}
