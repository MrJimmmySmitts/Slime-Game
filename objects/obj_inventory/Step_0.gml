/*
* Name: obj_inventory.Step
* Description: Handle drag, merge, and swap while the inventory UI is visible.
*/
{
    if (!global.invVisible) exit;

    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    // Begin drag on LMB press when a slot with items is clicked
    if (mouse_check_button_pressed(mb_left)) {
        var _idx = invHitTest();
        if (_idx != -1) {
            var _stack = INVENTORY_SLOTS[_idx];
            if (_stack.id != ItemId.None && _stack.count > 0) {
                invDragActiveSet(true);
                invDragStackSet(_stack);
                global.invDragFrom   = _idx;
                // clear slot while dragging
                INVENTORY_SLOTS[_idx] = { id: ItemId.None, count: 0 };
            }
        }
    }

    // Drop/merge on LMB release
    if (mouse_check_button_released(mb_left) && invDragActiveGet()) {
        var _drop_idx = invHitTest();
        if (_drop_idx != -1) {
            // Try merge via rule logic first (if defined)
            if (!invTryMergeDragIntoSlot(_drop_idx)) {
                // If merge failed: place into empty or swap with occupant
                var _dst = INVENTORY_SLOTS[_drop_idx];
                if (_dst.id == ItemId.None || _dst.count <= 0) {
                    INVENTORY_SLOTS[_drop_idx] = invDragStackGet();
                    invDragStackSet({ id: ItemId.None, count: 0 });
                } else {
                    // swap
                    var _tmp = _dst;
                    INVENTORY_SLOTS[_drop_idx] = invDragStackGet();
                    invDragStackSet(_tmp);
                }
            }
            invDragActiveSet(false);
            global.invDragFrom   = -1;
        } else {
            // If not dropped on the grid, return to source (or first empty)
            var _src = global.invDragFrom;
            if (_src >= 0 && _src < array_length(INVENTORY_SLOTS) && INVENTORY_SLOTS[_src].id == ItemId.None) {
                INVENTORY_SLOTS[_src] = invDragStackGet();
            } else {
                // fallback: find a place, else drop
                var _s = invDragStackGet();
                inv_add(_s.id, _s.count, 0, 0, "", 0); // adds to any free slot (non-dropping variant)
            }
            invDragActiveSet(false);
            global.invDragFrom   = -1;
            invDragStackSet({ id: ItemId.None, count: 0 });
        }
    }

    // Cancel drag with Escape or RMB
    if (invDragActiveGet() && (keyboard_check_pressed(vk_escape) || mouse_check_button_pressed(mb_right))) {
        var _src2 = global.invDragFrom;
        if (_src2 >= 0 && _src2 < array_length(INVENTORY_SLOTS) && INVENTORY_SLOTS[_src2].id == ItemId.None) {
            INVENTORY_SLOTS[_src2] = invDragStackGet();
        } else {
            var _st = invDragStackGet();
            inv_add(_st.id, _st.count, 0, 0, "", 0);
        }
        invDragActiveSet(false);
        global.invDragFrom   = -1;
        invDragStackSet({ id: ItemId.None, count: 0 });
    }
}
