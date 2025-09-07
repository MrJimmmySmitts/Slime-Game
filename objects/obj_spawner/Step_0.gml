/* Description: Spawn enemies at interval
 *   Input: none
 *   Output: none
 */
if (global.is_paused) exit;
spawn_timer--;
if (spawn_timer <= 0) {
    var child = choose(obj_enemy_1, obj_enemy_2);
    instance_create_layer(x + irandom_range(-200,200), y + irandom_range(-200,200), layer, child);
    spawn_timer = irandom_range(60, 180);
}