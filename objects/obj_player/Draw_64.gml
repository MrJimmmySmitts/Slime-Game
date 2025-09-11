/*
 * Name: obj_player.Draw GUI
 * Description: Draw health and ammo HUD using GUI coordinates so that it
 * remains fixed on the screen regardless of the camera position.
 */

// Fetch GUI dimensions in case the window or view size changes
var gui_w = display_get_gui_width();

// Margin from the screen edges
var margin  = 10;
var text_x = margin;
var text_y = margin;

draw_set_font(fnt_ui);
draw_set_color(c_white);

// Draw numeric health so it's visible even without heart glyphs
var health_text = "Health: " + string(hp) + " / " + string(hp_max);
draw_text(text_x, text_y, health_text);

// Draw ammo text anchored to the top-right corner
var ammo_text = "Ammo: " + string(ammo);
draw_set_halign(fa_right);
draw_text(gui_w - margin, text_y + 16, ammo_text);
draw_set_halign(fa_left);
