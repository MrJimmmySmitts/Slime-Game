/*
 * Name: obj_player.Draw GUI
 * Description: Draw health and ammo HUD using GUI coordinates so that it
 * remains fixed on the screen regardless of the camera position.
 */

// Fetch GUI dimensions in case the window or view size changes
var gui_w = display_get_gui_width();

// Margin from the screen edges
var margin  = 10;
var heart_x = margin;
var heart_y = margin;

draw_set_color(c_white);

// Draw hearts representing current and maximum health
for (var i = 0; i < hp_max; i++) {
    var heart_char = (i < hp) ? "\u2665" : "\u2661"; // ♥ or ♡
    draw_text(heart_x + i * 16, heart_y, heart_char);
}

// Draw ammo text anchored to the top-right corner
var ammo_text = "Ammo: " + string(ammo);
draw_set_halign(fa_right);
draw_text(gui_w - margin, heart_y + 16, ammo_text);
draw_set_halign(fa_left);
