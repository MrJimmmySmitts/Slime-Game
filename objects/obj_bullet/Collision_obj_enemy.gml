/*
* Name: obj_bullet.Collision[obj_enemy]
* Description: Apply damage; on death spawn ammo pickups.
*/

// Damage
with (other) {
    hp -= other.damage; // 'other' here is the bullet
    if (hp <= 0 && !is_dead) {
        is_dead = true;

        // Spawn ammo pickups on death
        var drops_to_spawn = irandom_range(ammo_drop_min, ammo_drop_max);
        repeat (drops_to_spawn) {
            var spawn_x = x + irandom_range(-6, 6);
            var spawn_y = y + irandom_range(-6, 6);
            instance_create_layer(spawn_x, spawn_y, layer_get_name(layer), obj_ammo);
        }

        // Spawn slime pickup on death
        var slime = instance_create_layer(x, y, layer_get_name(layer), slime_drop_object);
        slime.amount = irandom_range(slime_drop_min, slime_drop_max);

        instance_destroy(); // remove enemy
    }
}

// Bullet is consumed on impact
instance_destroy();
