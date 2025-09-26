/*
* Name: obj_enemy_melee_attack.Collision[obj_player]
* Description: Damage the player when the slash connects and then expire.
*/
if (other.damage_cd <= 0)
{
    other.hp = max(0, other.hp - max(1, damage));
    other.damage_cd = 60;
    other.flash_timer = max(other.flash_timer, 15);
}

instance_destroy();
