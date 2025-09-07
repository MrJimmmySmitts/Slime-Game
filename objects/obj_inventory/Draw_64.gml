/*
* Name: obj_inventory.Draw (visibility gate)
* Description: Draw only when inventory is visible.
*/
if (!global.inv_visible) exit;

/*
* Name: obj_inventory.DrawGUI
* Description: Draw inventory UI only when the global state is Inventory.
*/
{
    if (!inventory_is_open()) exit;

    // Optional title
    var o = inv_panel_get_origin();
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text(o.x, o.y - 24, "Inventory");

    // Main UI
    inv_draw_all();

    // Optional: show dragged stack preview while inventory is open
    if (inv_drag_active_get()) {
        inv_draw_cursor_stack();
    }
}
