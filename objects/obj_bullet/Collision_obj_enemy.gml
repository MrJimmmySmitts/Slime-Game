/*
* Name: obj_bullet.Collision[obj_enemy]
* Description: Apply damage; on death spawn ammo pickups.
*/

// Damage
with (other) {
    hp -= other.damage; // 'other' here is the bullet
    if (hp <= 0 && !is_dead) {
        is_dead = true;

        var _layer_name = layer_get_name(layer);

        // Spawn stock pickup
        var _stock_amt = irandom_range(stock_drop_min_amount, stock_drop_max_amount);
        if (_stock_amt > 0) {
            pickupSpawnStock(x, y, _layer_name, _stock_amt);
        }

        // Spawn modifier pickup
        var _mod_amt = irandom_range(modifier_drop_min, modifier_drop_max);
        if (_mod_amt > 0) {
            var _mod_id = pickupChooseModifierId(modifier_drop_id);
            if (_mod_id != ItemId.None) {
                pickupSpawnModifier(x, y, _layer_name, _mod_id, _mod_amt);
            }
        }

        instance_destroy(); // remove enemy
    }
}

// Bullet is consumed on impact
instance_destroy();
