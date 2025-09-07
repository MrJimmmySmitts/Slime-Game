/* 
* Name: obj_bullet.Collision[obj_enemy]
* Description: Apply damage; on death spawn 1–3 tiered slime pickups based on the enemy child.
*/

// Damage
with (other) {
    hp -= other.damage; // 'other' here is the bullet
    if (hp <= 0 && !is_dead) {
        is_dead = true;

        // Configure drop object per enemy (child classes define drop_pickup_obj)
        var drops_to_spawn = irandom_range(1, 3);
        var pickup_obj = is_undefined(drop_pickup_obj) ? obj_slime_1 : drop_pickup_obj;

        repeat (drops_to_spawn) {
            var spawn_x = x + irandom_range(-6, 6);
            var spawn_y = y + irandom_range(-6, 6);
            instance_create_layer(spawn_x, spawn_y, layer_get_name(layer), pickup_obj);
        }

        instance_destroy(); // remove enemy
    }
}

// Bullet is consumed on impact
instance_destroy();
