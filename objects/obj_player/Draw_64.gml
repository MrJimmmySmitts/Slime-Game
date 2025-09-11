/*
 * Name: obj_player.Draw GUI
 * Description: Draw health and ammo HUD in GUI coordinates.
 */
var heart_x = 10;
var heart_y = 10;
draw_set_color(c_white);
for (var i = 0; i < hp_max; i++) {
    var heart_char = (i < hp) ? "\u2665" : "\u2661"; // ♥ or ♡
    draw_text(heart_x + i * 16, heart_y, heart_char);
}

draw_text(10, heart_y + 16, "Ammo: " + string(ammo));
