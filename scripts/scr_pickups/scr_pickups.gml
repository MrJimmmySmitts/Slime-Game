// ====================================================================
// scr_pickups.gml — world pickup helpers & player interactions
// ====================================================================

/*
* Name: PickupClass
* Description: Classification for pickup behaviour.
*/
enum PickupClass
{
    Stock    = 0,
    Modifier = 1,
}

/*
* Name: pickupClampAmount
* Description: Returns a non-negative integer amount for stack counts.
*/
function pickupClampAmount(_amt)
{
    if (is_undefined(_amt)) return 0;
    return max(0, floor(_amt));
}

/*
* Name: pickupRefreshAppearance
* Description: Updates sprite tint based on pickup class/item id.
*/
function pickupRefreshAppearance(_inst)
{
    if (!instance_exists(_inst)) return;
    if (!variable_instance_exists(_inst, "pickup_kind")) return;

    switch (_inst.pickup_kind)
    {
        case PickupClass.Modifier:
        {
            var _item = ItemId.None;
            if (variable_instance_exists(_inst, "item_id"))
            {
                _item = itemCoalesce(_inst.item_id);
                _inst.item_id = _item;
            }
            var _col = itemGetColorTint(_item);
            _inst.image_blend = _col;
        }
        break;

        default:
            _inst.image_blend = c_white;
        break;
    }
}

/*
* Name: pickupCombineIntoSelf
* Description: Absorbs nearby pickups of the same type into _inst.
*/
function pickupCombineIntoSelf(_inst)
{
    if (!instance_exists(_inst)) return;
    if (!variable_instance_exists(_inst, "pickup_kind")) return;

    var _radius = 16;
    if (variable_instance_exists(_inst, "combine_radius"))
    {
        _radius = max(0, _inst.combine_radius);
    }
    if (_radius <= 0) return;

    var _list = ds_list_create();
    var _count = collision_circle_list(_inst.x, _inst.y, _radius, obj_pickup_base, false, true, _list, true);
    for (var _i = 0; _i < _count; _i++)
    {
        var _other = _list[| _i];
        if (_other == _inst) continue;
        if (!instance_exists(_other)) continue;
        if (!variable_instance_exists(_other, "pickup_kind")) continue;
        if (_other.pickup_kind != _inst.pickup_kind) continue;

        if (_inst.pickup_kind == PickupClass.Modifier)
        {
            if (!variable_instance_exists(_inst, "item_id") || !variable_instance_exists(_other, "item_id")) continue;
            if (itemCoalesce(_inst.item_id) != itemCoalesce(_other.item_id)) continue;
        }

        var _amt = pickupClampAmount(variable_instance_exists(_other, "amount") ? _other.amount : 0);
        if (_amt > 0)
        {
            if (!variable_instance_exists(_inst, "amount")) _inst.amount = 0;
            _inst.amount += _amt;
        }
        with (_other) instance_destroy();
    }
    ds_list_destroy(_list);
}

/*
* Name: pickupConfigureStock
* Description: Applies stock settings and merges duplicates.
*/
function pickupConfigureStock(_inst, _amount)
{
    if (!instance_exists(_inst)) return undefined;

    if (!variable_instance_exists(_inst, "combine_radius")) _inst.combine_radius = 16;
    _inst.pickup_kind = PickupClass.Stock;
    _inst.amount = pickupClampAmount(_amount);

    if (_inst.amount <= 0)
    {
        with (_inst) instance_destroy();
        return undefined;
    }

    pickupRefreshAppearance(_inst);
    pickupCombineIntoSelf(_inst);
    return _inst;
}

/*
* Name: pickupConfigureModifier
* Description: Applies modifier settings and merges duplicates.
*/
function pickupConfigureModifier(_inst, _item_id, _amount)
{
    if (!instance_exists(_inst)) return undefined;

    if (!variable_instance_exists(_inst, "combine_radius")) _inst.combine_radius = 16;
    _inst.pickup_kind = PickupClass.Modifier;
    _inst.item_id = itemCoalesce(_item_id);
    _inst.amount = pickupClampAmount(_amount);

    if (_inst.item_id == ItemId.None || _inst.amount <= 0)
    {
        with (_inst) instance_destroy();
        return undefined;
    }

    pickupRefreshAppearance(_inst);
    pickupCombineIntoSelf(_inst);
    pickupRefreshAppearance(_inst);
    return _inst;
}

/*
* Name: pickupResolveLayer
* Description: Returns a safe layer name for spawning pickups.
*/
function pickupResolveLayer(_layer_name)
{
    if (!is_string(_layer_name)) return "Instances";
    return layer_exists(_layer_name) ? _layer_name : "Instances";
}

/*
* Name: pickupSpawnStock
* Description: Spawns a stock pickup instance with the given amount.
*/
function pickupSpawnStock(_x, _y, _layer_name, _amount)
{
    var _lyr = pickupResolveLayer(_layer_name);
    var _inst = instance_create_layer(_x, _y, _lyr, obj_pickup_stock);
    if (_inst != noone)
    {
        pickupConfigureStock(_inst, _amount);
    }
    return _inst;
}

/*
* Name: pickupChooseModifierId
* Description: Resolves preferred modifier id or random fallback.
*/
function pickupChooseModifierId(_preferred)
{
    var _id = itemCoalesce(_preferred);
    if (_id != ItemId.None) return _id;

    if (variable_global_exists("ITEM_MODIFIER_IDS"))
    {
        var _arr = global.ITEM_MODIFIER_IDS;
        if (is_array(_arr))
        {
            var _len = array_length(_arr);
            if (_len > 0)
            {
                return _arr[irandom(_len - 1)];
            }
        }
    }
    return ItemId.None;
}

/*
* Name: pickupSpawnModifier
* Description: Spawns a modifier pickup with the specified item id and amount.
*/
function pickupSpawnModifier(_x, _y, _layer_name, _item_id, _amount)
{
    var _lyr = pickupResolveLayer(_layer_name);
    var _inst = instance_create_layer(_x, _y, _lyr, obj_pickup_modifier);
    if (_inst != noone)
    {
        pickupConfigureModifier(_inst, _item_id, _amount);
    }
    return _inst;
}

/*
* Name: pickupPlayerCollect
* Description: Applies pickup effects when the player collides with it.
*/
function pickupPlayerCollect(_player, _pickup)
{
    if (!instance_exists(_player) || !instance_exists(_pickup)) return;
    if (!variable_instance_exists(_pickup, "pickup_kind")) return;

    var _amount = pickupClampAmount(variable_instance_exists(_pickup, "amount") ? _pickup.amount : 0);
    if (_amount <= 0)
    {
        with (_pickup) instance_destroy();
        return;
    }

    switch (_pickup.pickup_kind)
    {
        case PickupClass.Stock:
        {
            if (!variable_instance_exists(_player, "ammo")) _player.ammo = 0;
            if (!variable_instance_exists(_player, "ammo_max")) _player.ammo_max = 0;
            var _need = max(0, _player.ammo_max - _player.ammo);
            if (_need <= 0) return; // inventory full, leave on ground

            var _take = min(_need, _amount);
            _player.ammo += _take;
            _pickup.amount = _amount - _take;
            if (_pickup.amount <= 0)
            {
                with (_pickup) instance_destroy();
            }
        }
        break;

        case PickupClass.Modifier:
        {
            var _item_id = itemCoalesce(variable_instance_exists(_pickup, "item_id") ? _pickup.item_id : ItemId.None);
            if (_item_id == ItemId.None)
            {
                with (_pickup) instance_destroy();
                return;
            }

            var _remain = invTryAddSimple(_item_id, _amount);
            if (_remain == _amount)
            {
                // Nothing added; inventory full.
                return;
            }
            _pickup.amount = _remain;
            if (_pickup.amount <= 0)
            {
                with (_pickup) instance_destroy();
            }
            else
            {
                pickupCombineIntoSelf(_pickup);
            }
        }
        break;
    }
}

