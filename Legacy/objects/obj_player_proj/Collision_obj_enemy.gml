/*
* Name: obj_bullet.Collision[obj_enemy]
* Description: Apply damage, trigger behaviour reactions, and consume the bullet.
*/

with (other) {
    enemyApplyDamage(other.damage, other.owner);
}

instance_destroy();
