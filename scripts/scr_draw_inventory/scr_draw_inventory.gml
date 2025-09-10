
/*
* Name: invGuiMouse
* Description: Returns { x, y } mouse position in GUI coordinates (for Draw GUI).
*/
function invGuiMouse()
{
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    return { x: mx, y: my };
}

/*
* Name: invPanelGetOrigin
* Description: Returns { x, y } for the top-left of the inventory grid panel.
*/
function invPanelGetOrigin()
{
    var cols   = INV_COLS;
    var rows   = INV_ROWS;
    var pad    = INV_SLOT_PAD;
    var sw     = global.invSlotW;
    var sh     = global.invSlotH;

    var grid_w = cols * sw + (cols - 1) * pad;
    var grid_h = rows * sh + (rows - 1) * pad;

    var margin = INV_PANEL_MARGIN;

    var ox = (display_get_gui_width()  - grid_w) * 0.5;
    var oy = (display_get_gui_height() - grid_h) * 0.5;

    var anchor = variable_global_exists("invPanelAnchor") ? global.invPanelAnchor : INV_PANEL_ANCHOR;

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

    if (variable_global_exists("invPanelOffX")) ox += global.invPanelOffX;
    if (variable_global_exists("invPanelOffY")) oy += global.invPanelOffY;

    return { x: ox, y: oy };
}

/*
* Name: invPanelGetRect
* Description: Returns { l, t, r, b } rectangle of the grid in GUI space.
*/
function invPanelGetRect()
{
    var o  = invPanelGetOrigin();
    var sw = global.invSlotW;
    var sh = global.invSlotH;
    var pad= INV_SLOT_PAD;

    var w = INV_COLS * sw + (INV_COLS - 1) * pad;
    var h = INV_ROWS * sh + (INV_ROWS - 1) * pad;

    return { l: o.x, t: o.y, r: o.x + w, b: o.y + h };
}

/*
* Name: invDrawPanelBg
* Description: Draws a translucent backdrop behind the grid.
*/
function invDrawPanelBg()
{
    var rc = invPanelGetRect();
    var pad = (variable_global_exists("invBgPadding") ? global.invBgPadding : 8);
    var a   = (variable_global_exists("invBgAlpha") ? global.invBgAlpha : 0.6);

    draw_set_alpha(a);
    draw_set_color(c_black);
    draw_roundrect(rc.l - pad, rc.t - pad, rc.r + pad, rc.b + pad, true);
    draw_set_alpha(1);
}

/*
* Name: invHitTest
* Description: Returns slot index under the GUI mouse, or -1 if none.
*/
function invHitTest()
{
    var o   = invPanelGetOrigin();
    var sw  = global.invSlotW;
    var sh  = global.invSlotH;
    var pad = INV_SLOT_PAD;

    var m   = invGuiMouse();
    var mx  = m.x, my = m.y;

    // Quick reject outside panel bounds
    var rc  = invPanelGetRect();
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
* Name: invDrawTooltip
* Description: Draws a simple tooltip with item name when hovering a non-empty slot.
*/
function invDrawTooltip()
{
    var idx = invHitTest();
    if (idx < 0) return;

    var slots = INVENTORY_SLOTS;
    if (idx >= array_length(slots)) return;

    var st = slots[idx];
    if (is_undefined(st) || st.id == ItemId.None || st.count <= 0) return;

    var name = itemGetName(st.id);

    var m = invGuiMouse();
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
* Name: invDrawSlots
* Description: Draw slot frames using global.invSprSlot, scaled to slot size.
*/
function invDrawSlots() {
    var _o = invPanelGetOrigin();
    var _left = _o.x;
    var _top  = _o.y;

    var _base = global.invSprSlot;
    if (_base == -1) {
        // No slot sprite available; nothing to draw
        return;
    }

    var _sp_w   = sprite_get_width(_base);
    var _sp_h   = sprite_get_height(_base);
    var _scaleX = (_sp_w > 0) ? (global.invSlotW / _sp_w) : 1;
    var _scaleY = (_sp_h > 0) ? (global.invSlotH / _sp_h) : 1;

    var _hover  = invHitTest();
    var _active = (variable_global_exists("invActiveSlot") ? global.invActiveSlot : -1);
    var _sel    = (variable_global_exists("invSelectSlot") ? global.invSelectSlot : -1);

    for (var _r = 0; _r < INV_ROWS; _r++) {
        for (var _c = 0; _c < INV_COLS; _c++) {
            var _idx = _r * INV_COLS + _c;
            var _cx = _left + _c * (global.invSlotW + INV_SLOT_PAD) + global.invSlotW * 0.5;
            var _cy = _top  + _r * (global.invSlotH + INV_SLOT_PAD) + global.invSlotH * 0.5;

            var _spr = _base;
            if (_idx == _active || _idx == _sel) {
                if (global.invSprSlotSelect != -1) _spr = global.invSprSlotSelect;
            } else if (_idx == _hover) {
                if (global.invSprSlotHover != -1) _spr = global.invSprSlotHover;
            }
            draw_sprite_ext(_spr, 0, _cx, _cy, _scaleX, _scaleY, 0, c_white, 1);
        }
    }
}
/*
* Name: invDrawItems
* Description: Draw item sprites in each occupied slot, scaled to fit while preserving aspect.
*/
function invDrawItems() {
    for (var _i = 0; _i < array_length(INVENTORY_SLOTS); _i++) {
        var _s = INVENTORY_SLOTS[_i];
        if (_s.id == ItemId.None || _s.count <= 0) continue;

        var _sp = itemGetSprite(_s.id);
        if (_sp == noone) continue;

        var _pos = inv_get_slot_center(_i);
        var _cx  = _pos.xx;
        var _cy  = _pos.yy;

        var _sw = sprite_get_width(_sp);
        var _sh = sprite_get_height(_sp);
        var _sc = min(global.invSlotW / _sw, global.invSlotH / _sh);
        draw_sprite_ext(_sp, 0, _cx, _cy, _sc, _sc, 0, c_white, 1);

        if (_s.count > 1) {
            var _pad = 4;
            draw_set_halign(fa_right);
            draw_set_valign(fa_top);
            draw_text(_cx + global.invSlotW * 0.5 - _pad, _cy - global.invSlotH * 0.5 + _pad, string(_s.count));
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
}
/*
* Name: invDrawAll
* Description: Convenience: draw slot frames then items.
*/
function invDrawAll() {
    invDrawSlots();
    invDrawItems();
}
/*
* Name: invDrawCursorStack
* Description: Draw the sprite for the currently dragged stack at the GUI mouse position.
*/
function invDrawCursorStack() {
    if (!invDragActiveGet()) return;
    var _stack = invDragStackGet();
    if (_stack.id == ItemId.None || _stack.count <= 0) return;

    var _sp = itemGetSprite(_stack.id);
    if (_sp == noone) return;

    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    var _sw = sprite_get_width(_sp);
    var _sh = sprite_get_height(_sp);
    var _sc = min(global.invSlotW / _sw, global.invSlotH / _sh);

    draw_sprite_ext(_sp, 0, _mx, _my, _sc, _sc, 0, c_white, 0.9);
    if (_stack.count > 1) {
        draw_set_halign(fa_right);
        draw_set_valign(fa_top);
        draw_text(_mx + global.invSlotW * 0.5 - 2, _my - global.invSlotH * 0.5 + 2, string(_stack.count));
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}
