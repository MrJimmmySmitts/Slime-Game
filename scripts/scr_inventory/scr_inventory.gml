// ====================================================================
// scr_inventory.gml — inventory subsystem
// ====================================================================

/*
* Name: invEmpty
* Description: Canonical empty stack value.
*/
function invEmpty()
{
    return { id: ItemId.None, count: 0 };
}

/*
* Name: inventoryBoot
* Description: Builds the inventory subsystem once. Must be called from gameInit().
*/
function inventoryBoot(_slot_count)
{
    var slots_count = max(1, (_slot_count > 0) ? _slot_count : 16);

    // Create subsystem root if missing
    if (!variable_global_exists("Inventory")) global.Inventory = {};

    // Slots array
    if (!variable_struct_exists(global.Inventory, "slots"))
    {
        global.Inventory.slots = array_create(slots_count, invEmpty());
    }
    else
    {
        var n = array_length(global.Inventory.slots);
        if (n != slots_count) {
            var new_slots = array_create(slots_count, invEmpty());
            var copy_n    = min(n, slots_count);
            for (var i = 0; i < copy_n; i++) {
                new_slots[i] = is_undefined(global.Inventory.slots[i]) ? invEmpty() : global.Inventory.slots[i];
            }
            global.Inventory.slots = new_slots;
        } else {
            for (var j = 0; j < n; j++) {
                var s = global.Inventory.slots[j];
                if (is_undefined(s) || is_undefined(s.id) || is_undefined(s.count)) {
                    global.Inventory.slots[j] = invEmpty();
                }
            }
        }
    }

    // Drag helpers
    if (!variable_struct_exists(global.Inventory, "drag"))
    {
        global.Inventory.drag = invEmpty();
    }
    if (!variable_struct_exists(global.Inventory, "drag_active"))
    {
        global.Inventory.drag_active = false;
    }
    if (!variable_global_exists("invDragFrom"))
    {
        global.invDragFrom = -1;
    }
}

/*
* Name: invTryAddSimple
* Description: Fill existing stacks, then empty slots. Returns remaining count.
*/
function invTryAddSimple(_item_id, _count)
{
    var remaining = max(0, _count);
    if (remaining <= 0) return 0;

    var cap = itemGetMaxStack(_item_id);
    if (cap <= 0) return remaining;

    var slots = INVENTORY_SLOTS;
    var n = array_length(slots);

    // 1) Top up existing stacks
    for (var i = 0; i < n && remaining > 0; i++)
    {
        var st = slots[i];
        if (st.id == _item_id)
        {
            var space = max(0, cap - st.count);
            if (space > 0)
            {
                var add = min(space, remaining);
                st.count += add;
                slots[i] = st;
                remaining -= add;
            }
        }
    }

    // 2) Fill empty slots
    for (var j = 0; j < n && remaining > 0; j++)
    {
        var st2 = slots[j];
        if (st2.id == ItemId.None || st2.count <= 0)
        {
            var put_amt = min(cap, remaining);
            slots[j] = { id: _item_id, count: put_amt };
            remaining -= put_amt;
        }
    }

    return remaining;
}

/*
* Name: invWorldDropSpawn
* Description: Spawn a world pickup for leftovers.
*/
function invWorldDropSpawn(_item_id, _count, _wx, _wy, _layer_name)
{
    var obj_name = "";
    switch (_item_id) {
        case ItemId.Slime1: obj_name = "obj_slime_1"; break;
        case ItemId.Slime2: obj_name = "obj_slime_2"; break;
        case ItemId.Slime3: obj_name = "obj_slime_3"; break;
        default: obj_name = ""; break;
    }
    if (obj_name == "") return;

    var obj_ix = asset_get_index(obj_name);
    if (obj_ix == -1) return;

    var lyr = layer_exists(_layer_name) ? _layer_name : "Instances";
    var inst = instance_create_layer(_wx, _wy, lyr, obj_ix);
    if (!is_undefined(inst) && variable_instance_exists(inst, "count")) inst.count = _count;
}

/*
* Name: invAddOrDrop
* Description: Add into INVENTORY_SLOTS or drop leftovers. Assumes inventoryBoot() already ran.
*/
function invAddOrDrop(_id, _count, _wx, _wy, _layer_name)
{
    var remain = invTryAddSimple(_id, _count);
    if (remain > 0) invWorldDropSpawn(_id, remain, _wx, _wy, _layer_name);
}
/*
* Name: inventoryUiBoot
* Description: Sets slot size and basic UI flags for the inventory. Call from gameInit().
*/
function inventoryUiBoot(_slot_w, _slot_h)
{
    // Slot pixel size used by layout (read by invPanelGetOrigin, etc.)
    if (!variable_global_exists("invSlotW")) global.invSlotW = max(1, _slot_w);
    if (!variable_global_exists("invSlotH")) global.invSlotH = max(1, _slot_h);

    // Panel anchoring & offsets (optional; used by your panel/origin helpers)
    if (!variable_global_exists("invPanelAnchor")) global.invPanelAnchor = INV_PANEL_ANCHOR;
    if (!variable_global_exists("invPanelOffX")) global.invPanelOffX  = 0;
    if (!variable_global_exists("invPanelOffY")) global.invPanelOffY  = 0;

    // Optional theme defaults (safe no-ops if you don’t use them)
    if (!variable_global_exists("invBgAlpha"))     global.invBgAlpha     = 0.6;
    if (!variable_global_exists("invBgPadding"))   global.invBgPadding   = 8;
}
/*
* Name: inventorySkinBoot
* Description: Binds UI sprite assets to non-conflicting globals used by inventory drawers.
*/
function inventorySkinBoot()
{
    // Look up sprites by resource name; store in non-conflicting global names
    global.invSprSlot         = asset_get_index("spr_slot");
    global.invSprSlotHover   = asset_get_index("spr_slot_hover");
    global.invSprSlotSelect  = asset_get_index("spr_slot_select");
    global.invSprItemMissing = asset_get_index("spr_item_missing");

    // Derive slot size from slot sprite if not already set
    if (!variable_global_exists("invSlotW") || global.invSlotW <= 0)
    {
        global.invSlotW = (global.invSprSlot != -1) ? sprite_get_width(global.invSprSlot) : 32;
    }
    if (!variable_global_exists("invSlotH") || global.invSlotH <= 0)
    {
        global.invSlotH = (global.invSprSlot != -1) ? sprite_get_height(global.invSprSlot) : 32;
    }
}

/*
* Name: invDragActiveGet
* Description: Returns true if drag is flagged active; false if unset/not active.
*/
function invDragActiveGet()
{
    if (!variable_global_exists("Inventory")) return false;
    return variable_struct_exists(global.Inventory, "drag_active") ? global.Inventory.drag_active : false;
}

/*
* Name: invDragStackGet
* Description: Returns current dragged stack struct, or {id: ItemId.None, count: 0} if unset.
*/
function invDragStackGet()
{
    if (variable_global_exists("Inventory") && variable_struct_exists(global.Inventory, "drag"))
        return global.Inventory.drag;
    return { id: ItemId.None, count: 0 };
}

/*
* Name: invDragActiveSet
* Description: Sets the drag active flag, creating the field on first use.
*/
function invDragActiveSet(_on)
{
    if (!variable_global_exists("Inventory")) global.Inventory = {};
    global.Inventory.drag_active = (_on == true);
}

/*
* Name: invDragStackSet
* Description: Sets the dragged stack, creating the field on first use.
*/
function invDragStackSet(_stack)
{
    if (!variable_global_exists("Inventory")) global.Inventory = {};
    global.Inventory.drag = _stack;
}

/*
* Name: invShow
* Description: Show inventory and recompute pause.
*/
function invShow() {
    global.invVisible = true;
    recomputePauseState();
}

/*
* Name: invHide
* Description: Hide inventory and recompute pause.
*/
function invHide() {
    global.invVisible = false;
    recomputePauseState();
}


/*
* Name: invToggle
* Description: Toggle inventory UI and pause state.
*/
function invToggle() {
    if (global.invVisible) invHide(); else invShow();
}


