/*
 * Name: obj_player_melee_attack.Collision[obj_enemy]
 * Description: Apply damage to enemies hit by the player's melee attack.
 */
if (!instance_exists(other)) exit;

with (other)
{
    enemyApplyDamage(other.damage, other.owner);
}

instance_destroy();
