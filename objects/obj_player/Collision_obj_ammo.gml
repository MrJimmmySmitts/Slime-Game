/*
* Name: obj_player.Collision[obj_ammo]
* Description: Refill ammo to maximum if not already full.
*/
if (ammo < ammo_max) {
    ammo = ammo_max;
    with (other) instance_destroy();
}
