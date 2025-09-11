/* Description: Spawn enemies at interval while respecting collision tilemap
 *   Input: none
 *   Output: none
 */
if (global.isPaused) exit;
spawn_timer--;
if (spawn_timer <= 0) {
    var child    = choose(obj_enemy_1, obj_enemy_2);
    var attempts = 10;
    while (attempts > 0) {
        var sx = x + irandom_range(-200, 200);
        var sy = y + irandom_range(-200, 200);

        var blocked = false;
        if (tilemap_id != -1) {
            var steps = ceil(point_distance(x, y, sx, sy) / 16);
            for (var i = 0; i <= steps; i++) {
                var t  = i / steps;
                var px = lerp(x,  sx, t);
                var py = lerp(y,  sy, t);
                if (tilemapSolidAt(tilemap_id, px, py)) {
                    blocked = true;
                    break;
                }
            }
        }

        if (!blocked) {
            instance_create_layer(sx, sy, layer, child);
            break;
        }

        attempts--;
    }
    spawn_timer = irandom_range(60, 180);
}