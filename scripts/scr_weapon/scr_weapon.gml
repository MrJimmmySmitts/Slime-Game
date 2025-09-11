// ====================================================================
// scr_weapon.gml — firing helpers
// ====================================================================

/*
* Name: weaponTickCooldown
* Description: Decrements fire cooldown on an instance if present.
*/
function weaponTickCooldown(inst)
{
    if (!variable_instance_exists(inst, "fire_cd")) inst.fire_cd = 0;
    if (inst.fire_cd > 0) inst.fire_cd -= 1;
}

/*
* Name: weaponTryFire
* Description: Spawns a bullet if cooldown is ready and aim vector is valid.
*/
function weaponTryFire(owner, origin_x, origin_y, aim_dx, aim_dy)
{
    if (owner.fire_cd > 0) return false;
    if (!variable_instance_exists(owner, "ammo")) owner.ammo = 0;
    if (owner.ammo <= 0) return false; // no ammo

    // Normalise incoming aim
    var n = vec2Norm(aim_dx, aim_dy);
    var dir_x = n[0], dir_y = n[1];
    if (approxZero(dir_x, 0.00001) && approxZero(dir_y, 0.00001)) return false;

    // Resolve bullet asset by string (avoids compile break if missing)
    var bullet_obj = asset_get_index(OBJ_BULLET_NAME);
    if (bullet_obj == -1)
    {
        show_debug_message("weaponTryFire: Missing asset '" + string(OBJ_BULLET_NAME) + "'.");
        return false;
    }

    var spawn_layer = BULLET_LAYER_NAME;
    if (!layer_exists(spawn_layer))
    {
        // Fallback: try first layer at depth 0
        var ll = layer_get_id_at_depth(0);
        if (ll != -1) spawn_layer = layer_get_name(ll);
    }

    var b = instance_create_layer(origin_x, origin_y, spawn_layer, bullet_obj);

    // Common fields most bullet templates expect
    b.direction = point_direction(0, 0, dir_x, dir_y);
    b.speed     = BULLET_SPEED;

    // Helpful extras (ignored if unused in your bullet)
    b.owner     = owner;
    b.dir_x     = dir_x;
    b.dir_y     = dir_y;

    // Reset cooldown
    owner.fire_cd = FIRE_COOLDOWN_STEPS;
    owner.ammo -= 1;
    return true;
}
