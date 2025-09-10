
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
* Name: inv_draw_slots
* Description: Draw slot frames using global.inv_spr_slot, scaled to slot size.
*/
function inv_draw_slots() {
    var _o = inv_panel_get_origin();
    var _left = _o.x;
    var _top  = _o.y;

    var _sp     = global.inv_spr_slot;
    var _sp_w   = sprite_get_width(_sp);
    var _sp_h   = sprite_get_height(_sp);
    var _scaleX = (_sp_w > 0) ? (global.inv_slot_w / _sp_w) : 1;
    var _scaleY = (_sp_h > 0) ? (global.inv_slot_h / _sp_h) : 1;

    for (var _r = 0; _r < INV_ROWS; _r++) {
        for (var _c = 0; _c < INV_COLS; _c++) {
            var _cx = _left + _c * (global.inv_slot_w + INV_SLOT_PAD) + global.inv_slot_w * 0.5;
            var _cy = _top  + _r * (global.inv_slot_h + INV_SLOT_PAD) + global.inv_slot_h * 0.5;
            draw_sprite_ext(_sp, 0, _cx, _cy, _scaleX, _scaleY, 0, c_white, 1);
        }
    }
}
/*
* Name: inv_draw_items
* Description: Draw item sprites in each occupied slot, scaled to fit while preserving aspect.
*/
function inv_draw_items() {
    for (var _i = 0; _i < array_length(global.inventory_slots); _i++) {
        var _s = global.inventory_slots[_i];
        if (_s.id == ItemId.None || _s.count <= 0) continue;

        var _sp = item_get_sprite(_s.id);
        if (_sp == -1) continue;

        var _pos = inv_get_slot_center(_i);
        var _cx  = _pos.xx;
        var _cy  = _pos.yy;

        var _sw = sprite_get_width(_sp);
        var _sh = sprite_get_height(_sp);
        var _sc = min(global.inv_slot_w / _sw, global.inv_slot_h / _sh);
        draw_sprite_ext(_sp, 0, _cx, _cy, _sc, _sc, 0, c_white, 1);

        if (_s.count > 1) {
            var _pad = 4;
            draw_set_halign(fa_right);
            draw_set_valign(fa_top);
            draw_text(_cx + global.inv_slot_w * 0.5 - _pad, _cy - global.inv_slot_h * 0.5 + _pad, string(_s.count));
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
}
/*
* Name: inv_draw_all
* Description: Convenience: draw slot frames then items.
*/
function inv_draw_all() {
    inv_draw_slots();
    inv_draw_items();
}
/*
* Name: inv_draw_cursor_stack
* Description: Draw the sprite for the currently dragged stack at the GUI mouse position.
*/
function inv_draw_cursor_stack() {
    if (!global.inv_drag_active) return;
    var _stack = global.inv_drag_stack;
    if (_stack.id == ItemId.None || _stack.count <= 0) return;

    var _sp = item_get_sprite(_stack.id);
    if (_sp == -1) return;

    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    var _sw = sprite_get_width(_sp);
    var _sh = sprite_get_height(_sp);
    var _sc = min(global.inv_slot_w / _sw, global.inv_slot_h / _sh);

    draw_sprite_ext(_sp, 0, _mx, _my, _sc, _sc, 0, c_white, 0.9);
    if (_stack.count > 1) {
        draw_set_halign(fa_right);
        draw_set_valign(fa_top);
        draw_text(_mx + global.inv_slot_w * 0.5 - 2, _my - global.inv_slot_h * 0.5 + 2, string(_stack.count));
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}
