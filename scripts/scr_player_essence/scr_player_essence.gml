// ====================================================================
// scr_player_essence.gml — helpers for managing essence containers
// ====================================================================

/*
 * Name: playerEssenceContainerSize
 * Description: Returns the clamped size of each essence container.
 */
function playerEssenceContainerSize(_inst)
{
    if (!instance_exists(_inst)) return ESSENCE_PER_CONTAINER;
    if (!variable_instance_exists(_inst, "essence_per_container")) return ESSENCE_PER_CONTAINER;
    return max(1, round(_inst.essence_per_container));
}

/*
 * Name: playerEssenceActiveContainers
 * Description: Calculates the number of containers that still hold essence.
 */
function playerEssenceActiveContainers(_inst)
{
    if (!instance_exists(_inst)) return 0;
    if (!variable_instance_exists(_inst, "essence")) return 0;

    var _size = playerEssenceContainerSize(_inst);
    if (_size <= 0) return 0;

    var _amount = max(0, round(_inst.essence));
    if (_amount <= 0) return 0;

    var _containers = (_amount + _size - 1) div _size; // ceil division
    if (variable_instance_exists(_inst, "hp_max"))
    {
        var _max = max(0, ceil(_inst.hp_max));
        _containers = clamp(_containers, 0, _max);
    }
    return _containers;
}

/*
 * Name: playerEssenceClamp
 * Description: Clamps current essence, updates container state and hp.
 */
function playerEssenceClamp(_inst)
{
    if (!instance_exists(_inst)) return 0;

    if (!variable_instance_exists(_inst, "essence")) _inst.essence = 0;
    var _essence_max = 0;
    if (variable_instance_exists(_inst, "essence_max"))
    {
        _essence_max = max(0, round(_inst.essence_max));
    }
    else if (variable_instance_exists(_inst, "hp_max"))
    {
        _essence_max = max(0, ceil(_inst.hp_max)) * playerEssenceContainerSize(_inst);
    }

    _inst.essence = clamp(round(_inst.essence), 0, _essence_max);

    var _containers = playerEssenceActiveContainers(_inst);
    _inst.essence_active_containers = _containers;

    if (variable_instance_exists(_inst, "hp"))
    {
        var _hp_max = variable_instance_exists(_inst, "hp_max") ? max(0, ceil(_inst.hp_max)) : _containers;
        _inst.hp = clamp(_containers, 0, _hp_max);
    }
    else
    {
        _inst.hp = _containers;
    }

    return _containers;
}

/*
 * Name: playerEssenceSpend
 * Description: Removes a positive amount of essence and clamps state.
 */
function playerEssenceSpend(_inst, _amount)
{
    if (!instance_exists(_inst)) return 0;

    if (!variable_instance_exists(_inst, "essence")) _inst.essence = 0;
    var _cost = max(0, round(_amount));
    _inst.essence = max(0, round(_inst.essence) - _cost);
    return playerEssenceClamp(_inst);
}

/*
 * Name: playerEssenceRestore
 * Description: Restores essence up to the current capacity.
 */
function playerEssenceRestore(_inst, _amount)
{
    if (!instance_exists(_inst)) return 0;

    if (!variable_instance_exists(_inst, "essence")) _inst.essence = 0;
    var _gain = max(0, round(_amount));
    _inst.essence = max(0, round(_inst.essence)) + _gain;
    return playerEssenceClamp(_inst);
}

/*
 * Name: playerEssenceApplyDamageBuff
 * Description: Applies the damage buff based on active essence containers.
 */
function playerEssenceApplyDamageBuff(_inst, _base_damage)
{
    if (!instance_exists(_inst)) return;

    var _base = max(1, round(_base_damage));
    var _bonus = playerEssenceActiveContainers(_inst) * ESSENCE_CONTAINER_DAMAGE_BONUS;
    var _total = max(1, round(_base + _bonus));

    _inst.bullet_damage = _total;
}
