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
* Name: itemDbPut
* Description: Registers an item definition in the global DB (DS map keyed by item id).
*/
function itemDbPut(_id, _def) {
    if (!variable_global_exists("ITEM_DB")) {
        global.ITEM_DB = ds_map_create();
        // Keep only the DB alias; DO NOT alias the enum.
        global.itemDb = global.ITEM_DB;
    }
    ds_map_set(global.ITEM_DB, _id, _def);
}



/*
* Name: ruleMake
* Description: Convenience constructor for a single merge rule entry (A + with_id -> result).
*/
function ruleMake(_with_id, _result_id, _src_cost, _dst_cost, _result_count) {
    return {
        with_id:      _with_id,       // partner item id
        result_id:    _result_id,     // crafted result id
        src_cost:     _src_cost,      // consume from "A" (dragged stack)
        dst_cost:     _dst_cost,      // consume from "B" (destination stack)
        result_count: _result_count   // how many units of result to create
    };
}

/*
* Name: itemDbInit
* Description: Builds the item database with stack caps and data-driven merge rules.
*              Calls should happen once at boot (e.g., inside gameInit()).
*/
function itemDbInit() {
    // Safely destroy previous map if it exists
    if (variable_global_exists("ITEM_DB")) {
        if (ds_exists(global.ITEM_DB, ds_type_map)) {
            ds_map_destroy(global.ITEM_DB);
        }
    }

    // Recreate DB and set compatibility alias for the MAP only
    global.ITEM_DB = ds_map_create();
    global.itemDb = global.ITEM_DB;   // ✅ ok (map alias)
    // ❌ DO NOT: global.ItemId = ItemId;

    // ---- Special "None" (empty slot) ----
    itemDbPut(ItemId.None, {
        name: "Empty",
        max_stack: 0,
        icon_sprite: noone,
        color_tint: c_white,
        desc: ""
    });

    // ---- Slimes ----
    itemDbPut(ItemId.Slime1, {
        name: "Slime 1",
        max_stack: 1,
        merge_rules: [ ruleMake(ItemId.Slime1, ItemId.Slime2, 1, 1, 1) ],
        icon_sprite: spr_slime_1,
        color_tint: c_white,
        desc: "Gloopy basics."
    });

    itemDbPut(ItemId.Slime2, {
        name: "Slime 2",
        max_stack: 1,
        merge_rules: [ ruleMake(ItemId.Slime2, ItemId.Slime3, 1, 1, 1) ],
        icon_sprite: spr_slime_2,
        color_tint: c_white,
        desc: "Thicker ooze."
    });

    itemDbPut(ItemId.Slime3, {
        name: "Slime 3",
        max_stack: 1,
        merge_rules: [],
        icon_sprite: spr_slime_3,
        color_tint: c_white,
        desc: "Potent sludge."
    });
}

/*
* Name: itemGetDef
* Description: Returns the item definition struct for a given id, or undefined.
*/
function itemGetDef(_id) {
    if (is_undefined(global.ITEM_DB)) return undefined;
    if (!ds_map_exists(global.ITEM_DB, _id)) return undefined;
    return ds_map_find_value(global.ITEM_DB, _id);
}

/*
* Name: itemDbGet
* Description: Alias to itemGetDef for compatibility with older naming.
*/
function itemDbGet(_id) {
    return itemGetDef(_id);
}

/*
* Name: itemGetName
* Description: Convenience: returns display name for item_id, or "Unknown".
*/
function itemGetName(_id) {
    var rec = itemGetDef(_id);
    return is_undefined(rec) ? "Unknown" : (is_undefined(rec.name) ? "Unknown" : rec.name);
}

/*
* Name: itemIsValid
* Description: True if the id exists in the DB.
*/
function itemIsValid(_id) {
    if (is_undefined(global.ITEM_DB)) return false;
    return ds_map_exists(global.ITEM_DB, _id);
}

/*
* Name: itemCoalesce
* Description: Returns _id if valid; otherwise ItemId.None.
*/
function itemCoalesce(_id) {
    return itemIsValid(_id) ? _id : ItemId.None;
}

/*
* Name: itemMergeRuleLookup
* Description: Finds a merge rule for A+B. Checks A’s rules for B, then B’s rules for A (swapping costs).
*/
function itemMergeRuleLookup(_a_id, _b_id) {
    var a_def = itemGetDef(_a_id);
    var b_def = itemGetDef(_b_id);
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
   NOTE: This script intentionally does NOT redefine itemGetMaxStack().
         Your existing function remains the source of truth.
   =========================================================== */

/*
* Name: invCanMerge
* Description: Returns a normalized merge rule (or undefined) for two stacks using itemMergeRuleLookup.
*/
function invCanMerge(_src_stack, _dst_stack) {
    if (is_undefined(_src_stack) || is_undefined(_dst_stack)) return undefined;
    if (_src_stack.id <= 0 || _dst_stack.id <= 0) return undefined;

    var rule = itemMergeRuleLookup(_src_stack.id, _dst_stack.id);
    if (is_undefined(rule)) return undefined;

    // Ensure sufficient counts
    if (_src_stack.count < rule.a_cost) return undefined;
    if (_dst_stack.count < rule.b_cost) return undefined;

    return rule;
}

/*
* Name: invApplyMerge
* Description: Applies a merge using a rule; returns { dst_after, src_after } or undefined if it cannot fit.
*/
function invApplyMerge(_src_stack, _dst_stack, _rule) {
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
        var cap   = itemGetMaxStack(_rule.result_id); // uses your existing function
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
* Name: invTryMergeDragIntoSlot
* Description: Attempts to merge the globally dragged stack into a given slot index.
*/
function invTryMergeDragIntoSlot(_slot_index) {
    var dst = INVENTORY_SLOTS[_slot_index];
    var src = invDragStackGet();

    var rule = invCanMerge(src, dst);
    if (is_undefined(rule)) return false;

    var outcome = invApplyMerge(src, dst, rule);
    if (is_undefined(outcome)) return false;

    INVENTORY_SLOTS[_slot_index] = outcome.dst_after;
    invDragStackSet(outcome.src_after);
    return true;
}

/*
* Name: itemGetMaxStack
* Description: Returns the stack cap for the given item id from the item DB. Defaults to 1; "None" stays 0.
*/
function itemGetMaxStack(_id)
{
    var def = itemGetDef(_id);
    if (is_undefined(def)) return 1;
    if (is_undefined(def.max_stack)) return 1;
    return def.max_stack;
}

/*
* Name: itemGetSprite
* Description: Returns the icon sprite for the given item id from the DB, or `noone` if unknown.
*/
function itemGetSprite(_id) {
    var _def = itemGetDef(_id);
    if (is_undefined(_def)) return noone;
    if (is_undefined(_def.icon_sprite) || _def.icon_sprite == noone) return noone;
    return _def.icon_sprite;
}

