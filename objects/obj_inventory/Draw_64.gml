/*
* Name: obj_inventory.Draw
* Description: Draw inventory panel + dragged stack when visible.
*/
if (!global.inv_visible) exit;

// Optional title
var _o = inv_panel_get_origin();
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(_o.x, _o.y - 24, "Inventory");

// Main UI
inv_draw_all();

// Drag preview
if (inv_drag_active_get()) {
    inv_draw_cursor_stack();
}
