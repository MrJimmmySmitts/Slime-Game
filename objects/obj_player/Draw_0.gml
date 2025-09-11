// (Optional) Draw a tiny aim line to indicate direction
var aim = inputGetAimAxis();
draw_line_width(x, y, x + aim[0]*20, y + aim[1]*20, 2);

if (flash_timer > 0) {
    gpu_set_blendmode(bm_add);
    draw_self();
    gpu_set_blendmode(bm_normal);
} else {
    draw_self();
}

// Draw health hearts
var heart_x = 10;
var heart_y = 10;
draw_set_color(c_white);
for (var i = 0; i < hp_max; i++) {
    var heart_char = (i < hp) ? "\u2665" : "\u2661"; // ♥ or ♡
    draw_text(heart_x + i * 16, heart_y, heart_char);
}

// Draw ammo
draw_text(10, heart_y + 16, "Ammo: " + string(ammo));