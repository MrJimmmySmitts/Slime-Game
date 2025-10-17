/*
* Name: obj_enemy.Draw
* Description: Draw the enemy with a brief hurt flash overlay.
*/
if (sprite_index != -1) {
    draw_self();

    if (enemy_flash_timer > 0) {
        var _dur = max(1, enemy_flash_duration);
        var _ratio = clamp(enemy_flash_timer / _dur, 0, 1);

        gpu_set_blendmode(bm_add);
        draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_white, _ratio);
        gpu_set_blendmode(bm_normal);
    }
} else {
    draw_self();
}
