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

var ability_timer   = variable_instance_exists(id, "ability_damage_timer") ? ability_damage_timer : 0;
var ability_cd      = variable_instance_exists(id, "ability_damage_cooldown") ? ability_damage_cooldown : 0;
var ability_cost    = variable_instance_exists(id, "ability_damage_cost") ? ability_damage_cost : PLAYER_ABILITY_ESSENCE_COST;
var ability_amount  = variable_instance_exists(id, "ability_damage_amount") ? ability_damage_amount : PLAYER_ABILITY_DAMAGE_BONUS;
var ability_text    = "Ability (E): Ready (Cost " + string(ability_cost) + ")";
var _rs             = max(1, room_speed);

if (ability_timer > 0)
{
    var ability_secs = ability_timer / _rs;
    ability_text = "Ability (E): Active +" + string(ability_amount) + " dmg (" + string_format(ability_secs, 0, 1) + "s)";
}
else if (ability_cd > 0)
{
    var ability_cd_secs = ability_cd / _rs;
    ability_text = "Ability (E): Cooldown " + string_format(ability_cd_secs, 0, 1) + "s";
}
else if (!playerEssenceCanSpend(id, ability_cost))
{
    ability_text = "Ability (E): Need " + string(ability_cost) + " essence";
}

var melee_cd   = variable_instance_exists(id, "melee_cooldown") ? melee_cooldown : 0;
var melee_cost = variable_instance_exists(id, "melee_cost") ? id.melee_cost : PLAYER_MELEE_ESSENCE_COST;
var melee_text = "Melee (Shift): Ready (Cost " + string(melee_cost) + ")";

if (melee_cd > 0)
{
    var melee_secs = melee_cd / _rs;
    melee_text = "Melee (Shift): Cooldown " + string_format(melee_secs, 0, 1) + "s";
}
else if (!playerEssenceCanSpend(id, melee_cost))
{
    melee_text = "Melee (Shift): Need " + string(melee_cost) + " essence";
}

draw_text(text_x, text_y + 32, ability_text);
draw_text(text_x, text_y + 48, melee_text);

if (ControlScheme.KeyboardMouse) {
    var _mx_gui = device_mouse_x_to_gui(0);
    var _my_gui = device_mouse_y_to_gui(0);
    var _reticle_color = make_color_rgb(255, 220, 120);

    draw_set_color(_reticle_color);
    draw_line(_mx_gui - 8, _my_gui, _mx_gui + 8, _my_gui);
    draw_line(_mx_gui, _my_gui - 8, _mx_gui, _my_gui + 8);

    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    var _mouse_text = "mouse_x: " + string_format(mouse_x, 0, 2) + "\nmouse_y: " + string_format(mouse_y, 0, 2);
    draw_text(_mx_gui + 10, _my_gui + 10, _mouse_text);
    draw_set_valign(fa_top);
    draw_set_halign(fa_left);
}
