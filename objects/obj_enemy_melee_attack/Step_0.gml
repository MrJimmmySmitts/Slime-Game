/*
* Name: obj_enemy_melee_attack.Step
* Description: Countdown lifetime and clean up when finished.
*/
if (life > 0)
{
    life -= 1;
    if (life <= 0)
    {
        instance_destroy();
        exit;
    }
}

if (!instance_exists(owner))
{
    owner = noone;
}
