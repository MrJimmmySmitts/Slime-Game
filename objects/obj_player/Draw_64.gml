/*
 * Name: obj_player.Draw GUI
 * Description: Draw essence container HUD using GUI coordinates so that it
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

// Draw container count so it's visible even without custom glyphs
var container_text = "Containers: " + string(hp) + " / " + string(hp_max);
draw_text(text_x, text_y, container_text);

// Draw total essence anchored to the top-right corner
var essence_current = variable_instance_exists(id, "essence") ? string(essence) : "0";
var essence_maximum = variable_instance_exists(id, "essence_max") ? string(essence_max) : "0";
var essence_text = "Essence: " + essence_current + " / " + essence_maximum;
draw_set_halign(fa_right);
draw_text(gui_w - margin, text_y + 16, essence_text);
draw_set_halign(fa_left);
