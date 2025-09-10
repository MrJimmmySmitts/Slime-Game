/*
* Name: obj_inventory.Draw
* Description: Draw inventory panel + dragged stack when visible.
*/
if (!global.invVisible) exit;

// Optional title
var _o = invPanelGetOrigin();
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(_o.x, _o.y - 24, "Inventory");

// Main UI
invDrawAll();

// Drag preview
if (invDragActiveGet()) {
    invDrawCursorStack();
}
