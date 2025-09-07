// ====================================================================
// scr_inventory.gml — inventory subsystem
// ====================================================================

/*
* Name: inv_empty
* Description: Canonical empty stack value.
*/
function inv_empty()
{
    return { id: ItemId.None, count: 0 };
}

/*
* Name: inventory_boot
* Description: Builds the inventory subsystem once. Must be called from game_init().
*/
function inventory_boot(_slot_count)
{
    var slots_count = max(1, (_slot_count > 0) ? _slot_count : 16);

    // Create subsystem root if missing
    if (!variable_global_exists("Inventory")) global.Inventory = {};

    // Slots array
    if (!variable_struct_exists(global.Inventory, "slots"))
    {
        global.Inventory.slots = array_create(slots_count, inv_empty());
    }
    else
    {
        var n = array_length(global.Inventory.slots);
        if (n != slots_count) {
            var new_slots = array_create(slots_count, inv_empty());
            var copy_n    = min(n, slots_count);
            for (var i = 0; i < copy_n; i++) {
                new_slots[i] = is_undefined(global.Inventory.slots[i]) ? inv_empty() : global.Inventory.slots[i];
            }
            global.Inventory.slots = new_slots;
        } else {
            for (var j = 0; j < n; j++) {
                var s = global.Inventory.slots[j];
                if (is_undefined(s) || is_undefined(s.id) || is_undefined(s.count)) {
                    global.Inventory.slots[j] = inv_empty();
                }
            }
        }
    }

    // Drag stack
    if (!variable_struct_exists(global.Inventory, "drag"))
    {
        global.Inventory.drag = inv_empty();
    }
}

/*
* Name: inv_try_add_simple
* Description: Fill existing stacks, then empty slots. Returns remaining count.
*/
function inv_try_add_simple(_item_id, _count)
{
    var remaining = max(0, _count);
    if (remaining <= 0) return 0;

    var cap = item_get_max_stack(_item_id);
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
* Name: inv_world_drop_spawn
* Description: Spawn a world pickup for leftovers.
*/
function inv_world_drop_spawn(_item_id, _count, _wx, _wy, _layer_name)
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
* Name: inv_add_or_drop
* Description: Add into INVENTORY_SLOTS or drop leftovers. Assumes inventory_boot() already ran.
*/
function inv_add_or_drop(_id, _count, _wx, _wy, _layer_name)
{
    var remain = inv_try_add_simple(_id, _count);
    if (remain > 0) inv_world_drop_spawn(_id, remain, _wx, _wy, _layer_name);
}
/*
* Name: inventory_ui_boot
* Description: Sets slot size and basic UI flags for the inventory. Call from game_init().
*/
function inventory_ui_boot(_slot_w, _slot_h)
{
    // Slot pixel size used by layout (read by inv_panel_get_origin, etc.)
    if (!variable_global_exists("inv_slot_w")) global.inv_slot_w = max(1, _slot_w);
    if (!variable_global_exists("inv_slot_h")) global.inv_slot_h = max(1, _slot_h);

    // Panel anchoring & offsets (optional; used by your panel/origin helpers)
    if (!variable_global_exists("inv_panel_anchor")) global.inv_panel_anchor = INV_PANEL_ANCHOR;
    if (!variable_global_exists("inv_panel_off_x")) global.inv_panel_off_x  = 0;
    if (!variable_global_exists("inv_panel_off_y")) global.inv_panel_off_y  = 0;

    // Optional theme defaults (safe no-ops if you don’t use them)
    if (!variable_global_exists("inv_bg_alpha"))     global.inv_bg_alpha     = 0.6;
    if (!variable_global_exists("inv_bg_padding"))   global.inv_bg_padding   = 8;
}
/*
* Name: inventory_skin_boot
* Description: Binds UI sprite assets to non-conflicting globals used by inventory drawers.
*/
function inventory_skin_boot()
{
    // Look up sprites by resource name; store in non-conflicting global names
    global.inv_spr_slot         = asset_get_index("spr_slot");
    global.inv_spr_slot_hover   = asset_get_index("spr_slot_hover");
    global.inv_spr_slot_select  = asset_get_index("spr_slot_select");
    global.inv_spr_item_missing = asset_get_index("spr_item_missing");

    // Derive slot size from slot sprite if not already set
    if (!variable_global_exists("inv_slot_w") || global.inv_slot_w <= 0)
    {
        global.inv_slot_w = (global.inv_spr_slot != -1) ? sprite_get_width(global.inv_spr_slot) : 32;
    }
    if (!variable_global_exists("inv_slot_h") || global.inv_slot_h <= 0)
    {
        global.inv_slot_h = (global.inv_spr_slot != -1) ? sprite_get_height(global.inv_spr_slot) : 32;
    }
}

/*
* Name: inv_drag_active_get
* Description: Returns true if drag is flagged active; false if unset/not active.
*/
function inv_drag_active_get()
{
    if (!variable_global_exists("Inventory")) return false;
    return variable_struct_exists(global.Inventory, "drag_active") ? global.Inventory.drag_active : false;
}

/*
* Name: inv_drag_stack_get
* Description: Returns current dragged stack struct, or {id: ItemId.None, count: 0} if unset.
*/
function inv_drag_stack_get()
{
    if (variable_global_exists("Inventory") && variable_struct_exists(global.Inventory, "drag"))
        return global.Inventory.drag;
    return { id: ItemId.None, count: 0 };
}

/*
* Name: inv_drag_active_set
* Description: Sets the drag active flag, creating the field on first use.
*/
function inv_drag_active_set(_on)
{
    if (!variable_global_exists("Inventory")) global.Inventory = {};
    global.Inventory.drag_active = (_on == true);
}

/*
* Name: inv_drag_stack_set
* Description: Sets the dragged stack, creating the field on first use.
*/
function inv_drag_stack_set(_stack)
{
    if (!variable_global_exists("Inventory")) global.Inventory = {};
    global.Inventory.drag = _stack;
}

