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
    var drops_to_spawn = irandom_range(ammo_drop_min, ammo_drop_max);
    repeat (drops_to_spawn) {
        var spawn_x = x + irandom_range(-6, 6);
        var spawn_y = y + irandom_range(-6, 6);
        instance_create_layer(spawn_x, spawn_y, layer_get_name(layer), obj_ammo);
    }

    // Spawn configured slime pickup
    var drop = instance_create_layer(x, y, layer_get_name(layer), slime_drop_object);
    drop.amount = irandom_range(slime_drop_min, slime_drop_max);

    instance_destroy();
}
