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

// Die if hp <= 0 → drop slime
if (hp <= 0) {
    // Create slime pickup with 1–3 items
    var drop = instance_create_layer(x, y, layer, obj_slime);
    drop.amount = irandom_range(1, 3);
    instance_destroy();
}
