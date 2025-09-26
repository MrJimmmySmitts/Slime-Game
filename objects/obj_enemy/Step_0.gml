if (onPauseExit()) {
    hspeed = 0; vspeed = 0; speed = 0;
    exit;
}

/*
* Name: obj_enemy.Step (behaviour)
* Description: Handle timers, state transitions, and behaviour logic.
*/
enemySeekPlayerStep();

// Die if hp <= 0 → drop essence and slime
if (hp <= 0 && !is_dead) {
    is_dead = true;

    // Spawn essence pickups using configured range
    var _layer_name = layer_get_name(layer);

    // Spawn essence pickup with combined amount
    var _essence_amt = irandom_range(essence_drop_min_amount, essence_drop_max_amount);
    if (_essence_amt > 0) {
        pickupSpawnEssence(x, y, _layer_name, _essence_amt);
    }

    // Spawn modifier pickup (respect preferred id if provided)
    var _mod_amt = irandom_range(modifier_drop_min, modifier_drop_max);
    if (_mod_amt > 0) {
        var _mod_id = pickupChooseModifierId(modifier_drop_id);
        if (_mod_id != ItemId.None) {
            pickupSpawnModifier(x, y, _layer_name, _mod_id, _mod_amt);
        }
    }

    instance_destroy();
}
