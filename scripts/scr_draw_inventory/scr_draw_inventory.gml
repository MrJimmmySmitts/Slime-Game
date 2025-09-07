// ====================================================================
// scr_draw_inventory.gml — COMPLETE REPLACEMENT
// Modernised inventory UI drawing helpers (GUI space)
// Depends on: INV_COLS/INV_ROWS/INV_SLOT_PAD/INV_PANEL_MARGIN macros,
//             INVENTORY_SLOTS macro, GameState enum,
//             global.inv_slot_w / global.inv_slot_h,
//             global.inv_spr_slot / inv_spr_slot_hover / inv_spr_slot_select (optional),
//             global.inv_spr_item_missing (optional)
// ====================================================================

/*
* Name: inv_gui_mouse
* Description: Returns { x, y } mouse position in GUI coordinates (for Draw GUI).
*/
function inv_gui_mouse()
{
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    return { x: mx, y: my };
}

/*
* Name: inv_panel_get_origin
* Description: Returns { x, y } for the top-left of the inventory grid panel.
*/
function inv_panel_get_origin()
{
    var cols   = INV_COLS;
    var rows   = INV_ROWS;
    var pad    = INV_SLOT_PAD;
    var sw     = global.inv_slot_w;
    var sh     = global.inv_slot_h;

    var grid_w = cols * sw + (cols - 1) * pad;
    var grid_h = rows * sh + (rows - 1) * pad;

    var margin = INV_PANEL_MARGIN;

    var ox = (display_get_gui_width()  - grid_w) * 0.5;
    var oy = (display_get_gui_height() - grid_h) * 0.5;

    var anchor = variable_global_exists("inv_panel_anchor") ? global.inv_panel_anchor : INV_PANEL_ANCHOR;

    switch (anchor)
    {
        case InvAnchor.TopLeft:
            ox = margin; oy = margin;
        break;
        case InvAnchor.TopRight:
            ox = display_get_gui_width() - grid_w - margin; oy = margin;
        break;
        case InvAnchor.BottomLeft:
            ox = margin; oy = display_get_gui_height() - grid_h - margin;
        break;
        case InvAnchor.BottomRight:
            ox = display_get_gui_width() - grid_w - margin;
            oy = display_get_gui_height() - grid_h - margin;
        break;
        default: /* Center */ ;
    }

    if (variable_global_exists("inv_panel_off_x")) ox += global.inv_panel_off_x;
    if (variable_global_exists("inv_panel_off_y")) oy += global.inv_panel_off_y;

    return { x: ox, y: oy };
}

/*
* Name: inv_panel_get_rect
* Description: Returns { l, t, r, b } rectangle of the grid in GUI space.
*/
function inv_panel_get_rect()
{
    var o  = inv_panel_get_origin();
    var sw = global.inv_slot_w;
    var sh = global.inv_slot_h;
    var pad= INV_SLOT_PAD;

    var w = INV_COLS * sw + (INV_COLS - 1) * pad;
    var h = INV_ROWS * sh + (INV_ROWS - 1) * pad;

    return { l: o.x, t: o.y, r: o.x + w, b: o.y + h };
}

/*
* Name: inv_draw_panel_bg
* Description: Draws a translucent backdrop behind the grid.
*/
function inv_draw_panel_bg()
{
    var rc = inv_panel_get_rect();
    var pad = (variable_global_exists("inv_bg_padding") ? global.inv_bg_padding : 8);
    var a   = (variable_global_exists("inv_bg_alpha") ? global.inv_bg_alpha : 0.6);

    draw_set_alpha(a);
    draw_set_color(c_black);
    draw_roundrect(rc.l - pad, rc.t - pad, rc.r + pad, rc.b + pad, true);
    draw_set_alpha(1);
}

/*
* Name: inv_hit_test
* Description: Returns slot index under the GUI mouse, or -1 if none.
*/
function inv_hit_test()
{
    var o   = inv_panel_get_origin();
    var sw  = global.inv_slot_w;
    var sh  = global.inv_slot_h;
    var pad = INV_SLOT_PAD;

    var m   = inv_gui_mouse();
    var mx  = m.x, my = m.y;

    // Quick reject outside panel bounds
    var rc  = inv_panel_get_rect();
    if (mx < rc.l || mx > rc.r || my < rc.t || my > rc.b) return -1;

    // Convert to grid coords
    var rel_x = mx - o.x;
    var rel_y = my - o.y;

    var cell_w = sw + pad;
    var cell_h = sh + pad;

    var c = floor(rel_x / cell_w);
    var r = floor(rel_y / cell_h);

    if (c < 0 || c >= INV_COLS || r < 0 || r >= INV_ROWS) return -1;

    // Ensure inside the slot interior (exclude padding gaps)
    var cx = c * cell_w;
    var cy = r * cell_h;
    if ((rel_x - cx) > sw || (rel_y - cy) > sh) return -1;

    return r * INV_COLS + c;
}

/*
* Name: inv_draw_slots
* Description: Draws the inventory slot frames using the current grid layout.
*/
function inv_draw_slots()
{
    var o    = inv_panel_get_origin();
    var left = o.x;
    var top  = o.y;

    var cols = INV_COLS;
    var rows = INV_ROWS;
    var pad  = INV_SLOT_PAD;
    var sw   = global.inv_slot_w;
    var sh   = global.inv_slot_h;

    var base   = variable_global_exists("inv_spr_slot")        ? global.inv_spr_slot        : -1;
    var hover  = variable_global_exists("inv_spr_slot_hover")  ? global.inv_spr_slot_hover  : -1;
    var select = variable_global_exists("inv_spr_slot_select") ? global.inv_spr_slot_select : -1;

    // Determine hovered index for hover frame
    var hi = inv_hit_test();
    var total = cols * rows;

    for (var i = 0; i < total; i++)
    {
        var r = i div cols;
        var c = i mod cols;

        var cx = left + c * (sw + pad) + sw * 0.5;
        var cy = top  + r * (sh + pad) + sh * 0.5;

        if (base != -1) draw_sprite(base, 0, cx, cy);
        else draw_rectangle(cx - sw*0.5, cy - sh*0.5, cx + sw*0.5, cy + sh*0.5, true);

        // Hover overlay (if any)
        if (i == hi && hover != -1) draw_sprite(hover, 0, cx, cy);

        // (Optional) Selected overlay placeholder:
        // if (i == selected_index && select != -1) draw_sprite(select, 0, cx, cy);
    }
}

/*
* Name: inv_draw_items
* Description: Draws item icons/counts from INVENTORY_SLOTS using the current grid layout.
*/
function inv_draw_items()
{
    var slots = INVENTORY_SLOTS;
    var total = array_length(slots);

    var o    = inv_panel_get_origin();
    var left = o.x;
    var top  = o.y;

    var cols = INV_COLS;
    var pad  = INV_SLOT_PAD;
    var sw   = global.inv_slot_w;
    var sh   = global.inv_slot_h;

    var fallback_icon = (variable_global_exists("inv_spr_item_missing") ? global.inv_spr_item_missing : -1);

    for (var i = 0; i < total; i++)
    {
        var r = i div cols;
        var c = i mod cols;

        var cx = left + c * (sw + pad) + sw * 0.5;
        var cy = top  + r * (sh + pad) + sh * 0.5;

        var st = slots[i];
        if (is_undefined(st) || st.id == ItemId.None || st.count <= 0) continue;

        // TODO: resolve per-item icon sprite based on st.id; fallback used here
        var spr = fallback_icon;

        if (spr != -1)
        {
            draw_sprite_ext(spr, 0, cx, cy, 1, 1, 0, c_white, 1);
        }
        else
        {
            // Minimal fallback if no icon: a small filled rect
            draw_set_alpha(1);
            draw_set_color(c_white);
            draw_rectangle(cx - sw*0.35, cy - sh*0.35, cx + sw*0.35, cy + sh*0.35, false);
        }

        // Draw stack count bottom-right
        draw_set_halign(fa_right);
        draw_set_valign(fa_bottom);
        draw_text(cx + sw*0.45, cy + sh*0.45, string(st.count));
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

/*
* Name: inv_draw_cursor_stack
* Description: Draws the dragged stack near the cursor if active.
*/
function inv_draw_cursor_stack()
{
    if (!inv_drag_active_get()) return;
    var st = inv_drag_stack_get();
    if (st.id == ItemId.None || st.count <= 0) return;

    var m  = { x: device_mouse_x_to_gui(0), y: device_mouse_y_to_gui(0) };
    var sw = global.inv_slot_w;
    var sh = global.inv_slot_h;

    var spr = (variable_global_exists("inv_spr_item_missing") ? global.inv_spr_item_missing : -1);

    if (spr != -1) draw_sprite_ext(spr, 0, m.x, m.y, 1, 1, 0, c_white, 0.85);
    else draw_rectangle(m.x - sw*0.35, m.y - sh*0.35, m.x + sw*0.35, m.y + sh*0.35, false);

    draw_set_halign(fa_right);
    draw_set_valign(fa_bottom);
    draw_text(m.x + sw*0.45, m.y + sh*0.45, string(st.count));
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
/*
* Name: inv_draw_tooltip
* Description: Draws a simple tooltip with item name when hovering a non-empty slot.
*/
function inv_draw_tooltip()
{
    var idx = inv_hit_test();
    if (idx < 0) return;

    var slots = INVENTORY_SLOTS;
    if (idx >= array_length(slots)) return;

    var st = slots[idx];
    if (is_undefined(st) || st.id == ItemId.None || st.count <= 0) return;

    var name = item_get_name(st.id);

    var m = inv_gui_mouse();
    var pad = 6;
    var tw = string_width(name);
    var th = string_height(name);

    draw_set_alpha(0.9);
    draw_set_color(c_black);
    draw_roundrect(m.x + 12, m.y + 12, m.x + 12 + tw + pad*2, m.y + 12 + th + pad*2, true);
    draw_set_alpha(1);

    draw_set_color(c_white);
    draw_text(m.x + 12 + pad, m.y + 12 + pad, name);
}

/*
* Name: inv_draw_all
* Description: High-level orchestrator for inventory UI drawing (call from Draw GUI).
*/
function inv_draw_all()
{
    inv_draw_panel_bg();
    inv_draw_slots();
    inv_draw_items();
    inv_draw_tooltip();
    inv_draw_cursor_stack();
}
