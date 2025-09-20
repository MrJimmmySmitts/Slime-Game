if (onPauseExit()) {
    hspeed = 0; vspeed = 0; speed = 0;
    exit;
}

/*
* Name: obj_enemy.Step (behaviour)
* Description: Handle timers, state transitions, and chasing logic.
*/
if (enemy_flash_timer > 0) enemy_flash_timer -= 1;
if (enemy_stun_timer  > 0) enemy_stun_timer  -= 1;

enemySeekPlayerStep();

// Die if hp <= 0 → drop ammo and slime
if (hp <= 0 && !is_dead) {
    is_dead = true;

    // Spawn ammo pickups using configured range
    var _layer_name = layer_get_name(layer);

    // Spawn stock pickup with combined ammo amount
    var _stock_amt = irandom_range(stock_drop_min_amount, stock_drop_max_amount);
    if (_stock_amt > 0) {
        pickupSpawnStock(x, y, _layer_name, _stock_amt);
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
