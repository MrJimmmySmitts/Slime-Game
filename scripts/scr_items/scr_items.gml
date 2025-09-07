// ====================================================================
// scr_items.gml — unified item ids, database, merge rules & helpers
// ====================================================================

/*
* Name: ItemId
* Description: Stable compile-time item identifiers used across the project.
*/
enum ItemId
{
    None   = 0,      // required by UI/empty slots

    Slime1 = 1001,
    Slime2 = 1002,
    Slime3 = 1003,

    // Add more here as needed (e.g., KeyBronze = 2001, PotionHP = 3001, ...)
}

/*
* Name: item_db_put
* Description: Registers an item definition in the global DB (DS map keyed by item id).
*/
function item_db_put(_id, _def) {
    if (!variable_global_exists("ITEM_DB")) {
        global.ITEM_DB = ds_map_create();
        // Keep only the DB alias; DO NOT alias the enum.
        global.item_db = global.ITEM_DB;
    }
    ds_map_set(global.ITEM_DB, _id, _def);
}



/*
* Name: rule_make
* Description: Convenience constructor for a single merge rule entry (A + with_id -> result).
*/
function rule_make(_with_id, _result_id, _src_cost, _dst_cost, _result_count) {
    return {
        with_id:      _with_id,       // partner item id
        result_id:    _result_id,     // crafted result id
        src_cost:     _src_cost,      // consume from "A" (dragged stack)
        dst_cost:     _dst_cost,      // consume from "B" (destination stack)
        result_count: _result_count   // how many units of result to create
    };
}

/*
* Name: item_db_init
* Description: Builds the item database with stack caps and data-driven merge rules.
*              Calls should happen once at boot (e.g., inside game_init()).
*/
function item_db_init() {
    // Safely destroy previous map if it exists
    if (variable_global_exists("ITEM_DB")) {
        if (ds_exists(global.ITEM_DB, ds_type_map)) {
            ds_map_destroy(global.ITEM_DB);
        }
    }

    // Recreate DB and set compatibility alias for the MAP only
    global.ITEM_DB = ds_map_create();
    global.item_db = global.ITEM_DB;   // ✅ ok (map alias)
    // ❌ DO NOT: global.ItemId = ItemId;

    // ---- Special "None" (empty slot) ----
    item_db_put(ItemId.None, {
        name: "Empty",
        max_stack: 0,
        icon_sprite: noone,
        color_tint: c_white,
        desc: ""
    });

    // ---- Slimes ----
    item_db_put(ItemId.Slime1, {
        name: "Slime 1",
        max_stack: 1,
        merge_rules: [ rule_make(ItemId.Slime1, ItemId.Slime2, 1, 1, 1) ],
        icon_sprite: noone,
        color_tint: c_white,
        desc: "Gloopy basics."
    });

    item_db_put(ItemId.Slime2, {
        name: "Slime 2",
        max_stack: 1,
        merge_rules: [ rule_make(ItemId.Slime2, ItemId.Slime3, 1, 1, 1) ],
        icon_sprite: noone,
        color_tint: c_white,
        desc: "Thicker ooze."
    });

    item_db_put(ItemId.Slime3, {
        name: "Slime 3",
        max_stack: 1,
        merge_rules: [],
        icon_sprite: noone,
        color_tint: c_white,
        desc: "Potent sludge."
    });
}

/*
* Name: item_get_def
* Description: Returns the item definition struct for a given id, or undefined.
*/
function item_get_def(_id) {
    if (is_undefined(global.ITEM_DB)) return undefined;
    if (!ds_map_exists(global.ITEM_DB, _id)) return undefined;
    return ds_map_find_value(global.ITEM_DB, _id);
}

/*
* Name: item_db_get
* Description: Alias to item_get_def for compatibility with older naming.
*/
function item_db_get(_id) {
    return item_get_def(_id);
}

/*
* Name: item_get_name
* Description: Convenience: returns display name for item_id, or "Unknown".
*/
function item_get_name(_id) {
    var rec = item_get_def(_id);
    return is_undefined(rec) ? "Unknown" : (is_undefined(rec.name) ? "Unknown" : rec.name);
}

/*
* Name: item_is_valid
* Description: True if the id exists in the DB.
*/
function item_is_valid(_id) {
    if (is_undefined(global.ITEM_DB)) return false;
    return ds_map_exists(global.ITEM_DB, _id);
}

/*
* Name: item_coalesce
* Description: Returns _id if valid; otherwise ItemId.None.
*/
function item_coalesce(_id) {
    return item_is_valid(_id) ? _id : ItemId.None;
}

/*
* Name: item_merge_rule_lookup
* Description: Finds a merge rule for A+B. Checks A’s rules for B, then B’s rules for A (swapping costs).
*/
function item_merge_rule_lookup(_a_id, _b_id) {
    var a_def = item_get_def(_a_id);
    var b_def = item_get_def(_b_id);
    if (is_undefined(a_def) || is_undefined(b_def)) return undefined;

    var scan_rules = function(_rules, _partner_id) {
        if (is_undefined(_rules)) return undefined;
        var n = array_length(_rules);
        for (var i = 0; i < n; i++) {
            var r = _rules[i];
            if (r.with_id == _partner_id) return r;
        }
        return undefined;
    };

    // (1) A’s rules targeting B
    var rA = scan_rules(a_def.merge_rules, _b_id);
    if (!is_undefined(rA)) {
        return {
            result_id:    rA.result_id,
            result_count: (is_undefined(rA.result_count) ? 1 : rA.result_count),
            a_cost:       (is_undefined(rA.src_cost) ? 1 : rA.src_cost),
            b_cost:       (is_undefined(rA.dst_cost) ? 1 : rA.dst_cost)
        };
    }

    // (2) B’s rules targeting A (swap costs)
    var rB = scan_rules(b_def.merge_rules, _a_id);
    if (!is_undefined(rB)) {
        return {
            result_id:    rB.result_id,
            result_count: (is_undefined(rB.result_count) ? 1 : rB.result_count),
            a_cost:       (is_undefined(rB.dst_cost) ? 1 : rB.dst_cost), // swapped
            b_cost:       (is_undefined(rB.src_cost) ? 1 : rB.src_cost)
        };
    }

    return undefined;
}

/* ===========================================================
   MERGE HELPERS (drag→drop flow calls these)
   NOTE: This script intentionally does NOT redefine item_get_max_stack().
         Your existing function remains the source of truth.
   =========================================================== */

/*
* Name: inv_can_merge
* Description: Returns a normalized merge rule (or undefined) for two stacks using item_merge_rule_lookup.
*/
function inv_can_merge(_src_stack, _dst_stack) {
    if (is_undefined(_src_stack) || is_undefined(_dst_stack)) return undefined;
    if (_src_stack.id <= 0 || _dst_stack.id <= 0) return undefined;

    var rule = item_merge_rule_lookup(_src_stack.id, _dst_stack.id);
    if (is_undefined(rule)) return undefined;

    // Ensure sufficient counts
    if (_src_stack.count < rule.a_cost) return undefined;
    if (_dst_stack.count < rule.b_cost) return undefined;

    return rule;
}

/*
* Name: inv_apply_merge
* Description: Applies a merge using a rule; returns { dst_after, src_after } or undefined if it cannot fit.
*/
function inv_apply_merge(_src_stack, _dst_stack, _rule) {
    if (is_undefined(_rule)) return undefined;

    // Consume costs from source & destination
    var src_after = { id: _src_stack.id, count: _src_stack.count - _rule.a_cost };
    var dst_remaining = _dst_stack.count - _rule.b_cost;

    // Place result into destination slot
    if (dst_remaining <= 0) {
        // Destination fully consumed -> becomes the result
        return {
            dst_after: { id: _rule.result_id, count: _rule.result_count },
            src_after: src_after
        };
    } else {
        // Destination still has items; only valid if result is same id and fits stack cap
        if (_dst_stack.id != _rule.result_id) {
            return undefined;
        }
        var cap   = item_get_max_stack(_rule.result_id); // uses your existing function
        var space = cap - dst_remaining;
        if (space < _rule.result_count) {
            return undefined;
        }
        return {
            dst_after: { id: _rule.result_id, count: dst_remaining + _rule.result_count },
            src_after: src_after
        };
    }
}

/*
* Name: inv_try_merge_drag_into_slot
* Description: Attempts to merge the globally dragged stack into a given slot index.
*/
function inv_try_merge_drag_into_slot(_slot_index) {
    var dst = global.inventory_slots[_slot_index];
    var src = global.inv_drag_stack;

    var rule = inv_can_merge(src, dst);
    if (is_undefined(rule)) return false;

    var outcome = inv_apply_merge(src, dst, rule);
    if (is_undefined(outcome)) return false;

    global.inventory_slots[_slot_index] = outcome.dst_after;
    global.inv_drag_stack = outcome.src_after;
    return true;
}

/*
* Name: item_get_max_stack
* Description: Returns the stack cap for the given item id from the item DB. Defaults to 1; "None" stays 0.
*/
function item_get_max_stack(_id)
{
    var def = item_get_def(_id);
    if (is_undefined(def)) return 1;
    if (is_undefined(def.max_stack)) return 1;
    return def.max_stack;
}
