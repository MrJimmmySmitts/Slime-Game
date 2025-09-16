// Inherit the parent event
event_inherited();

// Handle ranged attacks when the player is nearby
if (projectile_cooldown > 0) {
    projectile_cooldown -= 1;
}

var shoot_target = target;
if (!instance_exists(shoot_target)) {
    shoot_target = instance_nearest(x, y, obj_player);
}

if (instance_exists(shoot_target)) {
    var dx = shoot_target.x - x;
    var dy = shoot_target.y - y;
    var dist = point_distance(x, y, shoot_target.x, shoot_target.y);

    if (dist <= projectile_range && projectile_cooldown <= 0) {
        var aim = vec2Norm(dx, dy);
        var aim_x = aim[0];
        var aim_y = aim[1];

        if (!(approxZero(aim_x, 0.00001) && approxZero(aim_y, 0.00001))) {
            var spawn_layer = BULLET_LAYER_NAME;
            if (!layer_exists(spawn_layer)) {
                var default_layer = layer_get_id_at_depth(0);
                if (default_layer != -1) {
                    spawn_layer = layer_get_name(default_layer);
                }
            }

            var bullet = instance_create_layer(x, y, spawn_layer, obj_enemy_bullet);
            bullet.dirx = aim_x;
            bullet.diry = aim_y;
            bullet.spd  = projectile_speed;
            bullet.damage = projectile_damage;
            bullet.owner  = id;

            projectile_cooldown = projectile_cooldown_max;
        }
    }
}

