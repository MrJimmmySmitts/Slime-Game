/*
* Name: obj_inventory.Step
* Description: Handle drag, merge, and swap while the inventory UI is visible.
*/
{
    if (!global.invVisible) exit;

    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    // Keyboard navigation for active slot
    var _a = global.invActiveSlot;
    var _row = _a div INV_COLS;
    var _col = _a mod INV_COLS;
    if (keyboard_check_pressed(INV_KEY_UP))    _row = max(0, _row - 1);
    if (keyboard_check_pressed(INV_KEY_DOWN))  _row = min(INV_ROWS - 1, _row + 1);
    if (keyboard_check_pressed(INV_KEY_LEFT))  _col = max(0, _col - 1);
    if (keyboard_check_pressed(INV_KEY_RIGHT)) _col = min(INV_COLS - 1, _col + 1);
    global.invActiveSlot = _row * INV_COLS + _col;

    // Selection via keyboard
    if (keyboard_check_pressed(INV_KEY_SELECT)) {
        var _idx = global.invActiveSlot;
        if (global.invSelectSlot == -1) {
            global.invSelectSlot = _idx;
        } else if (global.invSelectSlot != _idx) {
            var _a_stack = INVENTORY_SLOTS[global.invSelectSlot];
            var _b_stack = INVENTORY_SLOTS[_idx];
            var _rule = invCanMerge(_a_stack, _b_stack);
            if (!is_undefined(_rule) && show_question("Merge items?")) {
                var _out = invApplyMerge(_a_stack, _b_stack, _rule);
                if (!is_undefined(_out)) {
                    INVENTORY_SLOTS[_idx] = _out.dst_after;
                    INVENTORY_SLOTS[global.invSelectSlot] = _out.src_after;
                }
            }
            global.invSelectSlot = -1;
        } else {
            global.invSelectSlot = -1;
        }
    }

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
        var _src_stack = invDragStackGet();
        if (_drop_idx != -1) {
            var _dst = INVENTORY_SLOTS[_drop_idx];
            var _rule = invCanMerge(_src_stack, _dst);
            if (!is_undefined(_rule) && show_question("Merge items?")) {
                var _out = invApplyMerge(_src_stack, _dst, _rule);
                if (!is_undefined(_out)) {
                    INVENTORY_SLOTS[_drop_idx] = _out.dst_after;
                    invDragStackSet(_out.src_after);
                }
            } else if (is_undefined(_rule)) {
                // Merge not possible: move to empty slot or return to origin
                if (_dst.id == ItemId.None || _dst.count <= 0) {
                    // Destination empty, place item normally
                    INVENTORY_SLOTS[_drop_idx] = _src_stack;
                    invDragStackSet({ id: ItemId.None, count: 0 });
                } else {
                    // Occupied slot: restore dragged item to its source
                    var _src_idx = global.invDragFrom;
                    if (_src_idx >= 0 && _src_idx < array_length(INVENTORY_SLOTS) && INVENTORY_SLOTS[_src_idx].id == ItemId.None) {
                        INVENTORY_SLOTS[_src_idx] = _src_stack;
                    } else {
                        inv_add(_src_stack.id, _src_stack.count, 0, 0, "", 0);
                    }
                }
            } else {
                // Merge canceled: return to origin
                var _src_idx = global.invDragFrom;
                if (_src_idx >= 0 && _src_idx < array_length(INVENTORY_SLOTS) && INVENTORY_SLOTS[_src_idx].id == ItemId.None) {
                    INVENTORY_SLOTS[_src_idx] = _src_stack;
                } else {
                    inv_add(_src_stack.id, _src_stack.count, 0, 0, "", 0);
                }
            }
            invDragActiveSet(false);
            global.invDragFrom   = -1;
            invDragStackSet({ id: ItemId.None, count: 0 });
        } else {
            // If not dropped on the grid, return to source (or first empty)
            var _src = global.invDragFrom;
            if (_src >= 0 && _src < array_length(INVENTORY_SLOTS) && INVENTORY_SLOTS[_src].id == ItemId.None) {
                INVENTORY_SLOTS[_src] = _src_stack;
            } else {
                // fallback: find a place, else drop
                inv_add(_src_stack.id, _src_stack.count, 0, 0, "", 0); // adds to any free slot (non-dropping variant)
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
