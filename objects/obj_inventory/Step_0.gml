/*
* Name: obj_inventory.Step
* Description: Handle drag, merge, and swap while the inventory UI is visible.
*/
{
    if (!global.inv_visible) exit;

    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    // Begin drag on LMB press when a slot with items is clicked
    if (mouse_check_button_pressed(mb_left)) {
        var _idx = inv_hit_test();
        if (_idx != -1) {
            var _stack = global.inventory_slots[_idx];
            if (_stack.id != ItemId.None && _stack.count > 0) {
                global.inv_drag_active = true;
                global.inv_drag_stack  = _stack;
                global.inv_drag_from   = _idx;
                // clear slot while dragging
                global.inventory_slots[_idx] = { id: ItemId.None, count: 0 };
            }
        }
    }

    // Drop/merge on LMB release
    if (mouse_check_button_released(mb_left) && global.inv_drag_active) {
        var _drop_idx = inv_hit_test();
        if (_drop_idx != -1) {
            // Try merge via rule logic first (if defined)
            if (!inv_try_merge_drag_into_slot(_drop_idx)) {
                // If merge failed: place into empty or swap with occupant
                var _dst = global.inventory_slots[_drop_idx];
                if (_dst.id == ItemId.None || _dst.count <= 0) {
                    global.inventory_slots[_drop_idx] = global.inv_drag_stack;
                    global.inv_drag_stack = { id: ItemId.None, count: 0 };
                } else {
                    // swap
                    var _tmp = _dst;
                    global.inventory_slots[_drop_idx] = global.inv_drag_stack;
                    global.inv_drag_stack            = _tmp;
                }
            }
            global.inv_drag_active = false;
            global.inv_drag_from   = -1;
        } else {
            // If not dropped on the grid, return to source (or first empty)
            var _src = global.inv_drag_from;
            if (_src >= 0 && _src < array_length(global.inventory_slots) && global.inventory_slots[_src].id == ItemId.None) {
                global.inventory_slots[_src] = global.inv_drag_stack;
            } else {
                // fallback: find a place, else drop
                var _s = global.inv_drag_stack;
                inv_add(_s.id, _s.count, 0, 0, "", 0); // adds to any free slot (non-dropping variant)
            }
            global.inv_drag_active = false;
            global.inv_drag_from   = -1;
            global.inv_drag_stack  = { id: ItemId.None, count: 0 };
        }
    }

    // Cancel drag with Escape or RMB
    if (global.inv_drag_active && (keyboard_check_pressed(vk_escape) || mouse_check_button_pressed(mb_right))) {
        var _src2 = global.inv_drag_from;
        if (_src2 >= 0 && _src2 < array_length(global.inventory_slots) && global.inventory_slots[_src2].id == ItemId.None) {
            global.inventory_slots[_src2] = global.inv_drag_stack;
        } else {
            inv_add(global.inv_drag_stack.id, global.inv_drag_stack.count, 0, 0, "", 0);
        }
        global.inv_drag_active = false;
        global.inv_drag_from   = -1;
        global.inv_drag_stack  = { id: ItemId.None, count: 0 };
    }
}
