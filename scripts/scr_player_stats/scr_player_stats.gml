// ====================================================================
// scr_player_stats.gml — derive player stats from inventory modifiers
// ====================================================================

/*
* Name: playerStatsEnsureBase
* Description: Stores baseline stats for later modifier application.
*/
function playerStatsEnsureBase(_inst)
{
    if (!instance_exists(_inst)) return;
    if (variable_instance_exists(_inst, "base_stats_initialised") && _inst.base_stats_initialised) return;

    _inst.base_hp_max         = variable_instance_exists(_inst, "hp_max")   ? _inst.hp_max   : PLAYER_START_CONTAINERS;
    _inst.base_container_max  = variable_instance_exists(_inst, "base_container_max") ? _inst.base_container_max : _inst.base_hp_max;
    _inst.base_essence_per_container = variable_instance_exists(_inst, "base_essence_per_container") ? _inst.base_essence_per_container : ESSENCE_PER_CONTAINER;

    var _base_capacity = 0;
    if (variable_instance_exists(_inst, "base_essence_max")) _base_capacity = _inst.base_essence_max;
    else if (variable_instance_exists(_inst, "essence_max")) _base_capacity = _inst.essence_max;
    else _base_capacity = _inst.base_container_max * _inst.base_essence_per_container;
    _inst.base_essence_max = _base_capacity;

    var _base_from_containers = _inst.base_container_max * _inst.base_essence_per_container;
    if (variable_instance_exists(_inst, "base_essence_bonus")) _inst.base_essence_bonus = max(0, round(_inst.base_essence_bonus));
    else _inst.base_essence_bonus = max(0, round(_base_capacity - _base_from_containers));
    _inst.base_move_speed     = PLAYER_MOVE_SPEED;
    _inst.base_dash_distance  = PLAYER_DASH_DISTANCE;
    _inst.base_dash_time      = PLAYER_DASH_TIME;
    _inst.base_dash_cooldown  = PLAYER_DASH_COOLDOWN;
    _inst.base_fire_cooldown  = FIRE_COOLDOWN_STEPS;
    _inst.base_bullet_damage  = PLAYER_BASE_BULLET_DAMAGE;
    _inst.base_bullet_speed   = BULLET_SPEED;
    _inst.base_stats_initialised = true;
}

/*
* Name: playerStatsApplyBuff
* Description: Applies a buff struct multiplied by count onto stats struct.
*/
function playerStatsApplyBuff(_stats, _buff, _count)
{
    if (is_undefined(_buff) || !is_struct(_buff)) return;
    var _mult = max(0, _count);
    if (_mult <= 0) return;

    if (variable_struct_exists(_buff, "hp_max"))                _stats.container_max         += _buff.hp_max                * _mult;
    if (variable_struct_exists(_buff, "essence_containers"))    _stats.container_max         += _buff.essence_containers    * _mult;
    if (variable_struct_exists(_buff, "essence_per_container")) _stats.essence_per_container += _buff.essence_per_container * _mult;
    if (variable_struct_exists(_buff, "ammo_max"))              _stats.essence_bonus         += _buff.ammo_max              * _mult;
    if (variable_struct_exists(_buff, "essence_bonus"))         _stats.essence_bonus         += _buff.essence_bonus         * _mult;
    if (variable_struct_exists(_buff, "move_speed"))    _stats.move_speed    += _buff.move_speed    * _mult;
    if (variable_struct_exists(_buff, "dash_distance")) _stats.dash_distance += _buff.dash_distance * _mult;
    if (variable_struct_exists(_buff, "fire_cooldown")) _stats.fire_cooldown += _buff.fire_cooldown * _mult;
    if (variable_struct_exists(_buff, "bullet_damage")) _stats.bullet_damage += _buff.bullet_damage * _mult;
    if (variable_struct_exists(_buff, "bullet_speed"))  _stats.bullet_speed  += _buff.bullet_speed  * _mult;
}

/*
* Name: playerStatsRecalculate
* Description: Rebuilds derived stats from current inventory contents.
*/
function playerStatsRecalculate(_inst)
{
    if (!instance_exists(_inst)) return;
    playerStatsEnsureBase(_inst);

    var _stats = {
        container_max:         _inst.base_container_max,
        essence_per_container: _inst.base_essence_per_container,
        essence_bonus:         _inst.base_essence_bonus,
        move_speed:    _inst.base_move_speed,
        dash_distance: _inst.base_dash_distance,
        dash_time:     _inst.base_dash_time,
        dash_cooldown: _inst.base_dash_cooldown,
        fire_cooldown: _inst.base_fire_cooldown,
        bullet_damage: _inst.base_bullet_damage,
        bullet_speed:  _inst.base_bullet_speed,
    };

    if (variable_global_exists("Inventory"))
    {
        var _slots = INVENTORY_SLOTS;
        var _len   = array_length(_slots);
        for (var _i = 0; _i < _len; _i++)
        {
            var _stack = _slots[_i];
            if (is_undefined(_stack) || _stack.id == ItemId.None || _stack.count <= 0) continue;

            var _buff = itemGetBuffs(_stack.id);
            if (is_undefined(_buff)) continue;
            playerStatsApplyBuff(_stats, _buff, _stack.count);
        }
    }

    // Clamp sane ranges
    _stats.container_max         = max(0, ceil(_stats.container_max));
    _stats.essence_per_container = max(1, ceil(_stats.essence_per_container));
    _stats.essence_bonus         = max(0, floor(_stats.essence_bonus));
    _stats.move_speed    = max(0, _stats.move_speed);
    _stats.dash_distance = max(0, _stats.dash_distance);
    _stats.dash_time     = max(1, ceil(_stats.dash_time));
    _stats.dash_cooldown = max(0, ceil(_stats.dash_cooldown));
    _stats.fire_cooldown = max(1, ceil(_stats.fire_cooldown));
    _stats.bullet_damage = max(1, round(_stats.bullet_damage));
    _stats.bullet_speed  = max(0.25, _stats.bullet_speed);

    var _essence_capacity = _stats.container_max * _stats.essence_per_container + _stats.essence_bonus;
    _inst.hp_max = _stats.container_max;
    _inst.essence_per_container = _stats.essence_per_container;
    _inst.essence_max = _essence_capacity;
    if (!variable_instance_exists(_inst, "essence")) _inst.essence = _inst.essence_max;
    playerEssenceClamp(_inst);

    _inst.move_speed        = _stats.move_speed;
    _inst.dash_distance_total = _stats.dash_distance;
    _inst.dash_duration_max   = _stats.dash_time;
    _inst.dash_cooldown_max   = _stats.dash_cooldown;
    _inst.fire_cooldown_steps = _stats.fire_cooldown;

    var _base_damage = _stats.bullet_damage;
    _inst.bullet_damage = _base_damage;
    playerEssenceApplyDamageBuff(_inst, _base_damage);
    _inst.bullet_speed        = _stats.bullet_speed;
}

