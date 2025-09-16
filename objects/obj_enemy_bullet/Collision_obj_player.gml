/*
* Name: obj_enemy_bullet.Collision[obj_player]
* Description: Damage the player with invulnerability cooldown.
*/
if (other.damage_cd <= 0) {
    other.hp -= damage;
    other.damage_cd = 60;
    other.flash_timer = max(other.flash_timer, 15);
}

instance_destroy();
