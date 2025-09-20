if (onPauseExit()) {
    hspeed = 0; vspeed = 0; speed = 0;
    exit;
}
    
/*
* Name: obj_enemy.Step (pursuit)
* Description: Pursue the player when within range, using tilemap collision.
*/
enemySeekPlayerStep();


if (!instance_exists(target)) {
    target = instance_nearest(x, y, obj_player);
}
if (instance_exists(target)) {
    var dx = sign(target.x - x);
    var dy = sign(target.y - y);
    var len = point_distance(x, y, target.x, target.y);
    if (len > 0) {
        dx = (target.x - x) / len;
        dy = (target.y - y) / len;
    }
    x += dx * speed;
    y += dy * speed;
}

// Die if hp <= 0 → drop ammo and slime
if (hp <= 0) {

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
