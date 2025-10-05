// ====================================================================
// scr_player_combat.gml — combat helpers for dash, melee, and abilities
// ====================================================================

/*
 * Name: playerDashEnsureState
 * Description: Ensure dash-related variables exist with sane defaults.
 */
function playerDashEnsureState(_inst)
{
    if (!instance_exists(_inst)) return;

    if (!variable_instance_exists(_inst, "dash_active"))          _inst.dash_active = false;
    if (!variable_instance_exists(_inst, "dash_time"))            _inst.dash_time = 0;
    if (!variable_instance_exists(_inst, "dash_cooldown"))        _inst.dash_cooldown = 0;
    if (!variable_instance_exists(_inst, "dash_dx"))              _inst.dash_dx = 0;
    if (!variable_instance_exists(_inst, "dash_dy"))              _inst.dash_dy = 0;
    if (!variable_instance_exists(_inst, "dash_distance_total"))  _inst.dash_distance_total = PLAYER_DASH_DISTANCE;
    if (!variable_instance_exists(_inst, "dash_duration_max"))    _inst.dash_duration_max = PLAYER_DASH_TIME;
    if (!variable_instance_exists(_inst, "dash_cooldown_max"))    _inst.dash_cooldown_max = PLAYER_DASH_COOLDOWN;
}

/*
 * Name: playerDashTryStart
 * Description: Attempt to start a dash using the provided direction.
 */
function playerDashTryStart(_inst, _dir_x, _dir_y)
{
    if (!instance_exists(_inst)) return false;
    playerDashEnsureState(_inst);

    if (_inst.dash_active) return false;
    if (_inst.dash_cooldown > 0) return false;

    var _dist_total = max(0, _inst.dash_distance_total);
    var _time_total = max(1, round(_inst.dash_duration_max));
    if (_dist_total <= 0) return false;

    var _norm = vec2Norm(_dir_x, _dir_y);
    var _nx = _norm[0];
    var _ny = _norm[1];
    if (approxZero(_nx, 0.00001) && approxZero(_ny, 0.00001)) return false;

    _inst.dash_dx = _nx * (_dist_total / _time_total);
    _inst.dash_dy = _ny * (_dist_total / _time_total);
    _inst.dash_time = _time_total;
    _inst.dash_active = true;
    _inst.dash_cooldown = max(0, round(_inst.dash_cooldown_max));
    return true;
}

/*
 * Name: playerDashStep
 * Description: Advance dash timers and return the dash offset for this step.
 */
function playerDashStep(_inst)
{
    var _result = { active: false, dx: 0, dy: 0 };
    if (!instance_exists(_inst)) return _result;

    playerDashEnsureState(_inst);

    if (_inst.dash_cooldown > 0) _inst.dash_cooldown -= 1;
    if (_inst.dash_cooldown < 0) _inst.dash_cooldown = 0;

    if (_inst.dash_active)
    {
        var _dx = _inst.dash_dx;
        var _dy = _inst.dash_dy;

        _inst.dash_time -= 1;
        if (_inst.dash_time <= 0)
        {
            _inst.dash_active = false;
            _inst.dash_time = 0;
            _inst.dash_dx = 0;
            _inst.dash_dy = 0;
        }

        _result.active = true;
        _result.dx = _dx;
        _result.dy = _dy;
    }

    return _result;
}

/*
 * Name: playerMeleeEnsureState
 * Description: Ensure melee-related variables exist.
 */
function playerMeleeEnsureState(_inst)
{
    if (!instance_exists(_inst)) return;

    if (!variable_instance_exists(_inst, "melee_cooldown"))      _inst.melee_cooldown = 0;
    if (!variable_instance_exists(_inst, "melee_cooldown_max"))  _inst.melee_cooldown_max = PLAYER_MELEE_COOLDOWN;
    if (!variable_instance_exists(_inst, "melee_range"))         _inst.melee_range = PLAYER_MELEE_RANGE;
    if (!variable_instance_exists(_inst, "melee_life"))          _inst.melee_life = PLAYER_MELEE_LIFE;
    if (!variable_instance_exists(_inst, "melee_cost"))          _inst.melee_cost = PLAYER_MELEE_ESSENCE_COST;
}

/*
 * Name: playerMeleeStep
 * Description: Tick melee cooldown timers.
 */
function playerMeleeStep(_inst)
{
    if (!instance_exists(_inst)) return;
    playerMeleeEnsureState(_inst);
    if (_inst.melee_cooldown > 0) _inst.melee_cooldown -= 1;
}

/*
 * Name: playerMeleeTryAttack
 * Description: Attempt to spawn a melee hitbox using the provided direction.
 */
function playerMeleeTryAttack(_inst, _dir_x, _dir_y)
{
    if (!instance_exists(_inst)) return false;
    playerMeleeEnsureState(_inst);

    if (_inst.melee_cooldown > 0) return false;
    if (!playerEssenceCanSpend(_inst, _inst.melee_cost)) return false;

    var _norm = vec2Norm(_dir_x, _dir_y);
    var _nx = _norm[0];
    var _ny = _norm[1];
    if (approxZero(_nx, 0.00001) && approxZero(_ny, 0.00001)) return false;

    if (!object_exists(obj_player_melee_attack)) return false;

    var _layer_name = layer_get_name(_inst.layer);
    if (!layer_exists(_layer_name))
    {
        var _fallback = layer_get_id_at_depth(0);
        if (_fallback != -1) _layer_name = layer_get_name(_fallback);
    }

    var _range = max(0, _inst.melee_range);
    var _spawn_x = _inst.x + _nx * _range;
    var _spawn_y = _inst.y + _ny * _range;

    var _slash = instance_create_layer(_spawn_x, _spawn_y, _layer_name, obj_player_melee_attack);
    if (!instance_exists(_slash)) return false;

    playerEssenceSpend(_inst, _inst.melee_cost);

    _slash.owner = _inst;
    _slash.damage = max(1, round(_inst.bullet_damage));
    _slash.life = max(1, round(_inst.melee_life));
    _slash.image_angle = point_direction(_inst.x, _inst.y, _spawn_x, _spawn_y);

    var _sprite = asset_get_index("spr_attack");
    if (_sprite != -1) _slash.sprite_index = _sprite;

    if (_slash.sprite_index != -1)
    {
        var _frames = max(1, sprite_get_number(_slash.sprite_index));
        _slash.image_index = 0;
        _slash.image_speed = _frames / max(1, _slash.life);
    }
    else
    {
        _slash.image_speed = 0;
    }

    _inst.melee_cooldown = max(1, round(_inst.melee_cooldown_max));
    return true;
}

/*
 * Name: playerAbilityEnsureState
 * Description: Ensure ability variables exist with defaults.
 */
function playerAbilityEnsureState(_inst)
{
    if (!instance_exists(_inst)) return;

    if (!variable_instance_exists(_inst, "ability_damage_timer"))        _inst.ability_damage_timer = 0;
    if (!variable_instance_exists(_inst, "ability_damage_cooldown"))     _inst.ability_damage_cooldown = 0;
    if (!variable_instance_exists(_inst, "ability_damage_duration"))     _inst.ability_damage_duration = PLAYER_ABILITY_DURATION;
    if (!variable_instance_exists(_inst, "ability_damage_cooldown_max")) _inst.ability_damage_cooldown_max = PLAYER_ABILITY_COOLDOWN;
    if (!variable_instance_exists(_inst, "ability_damage_amount"))       _inst.ability_damage_amount = PLAYER_ABILITY_DAMAGE_BONUS;
    if (!variable_instance_exists(_inst, "ability_damage_cost"))         _inst.ability_damage_cost = PLAYER_ABILITY_ESSENCE_COST;
    if (!variable_instance_exists(_inst, "ability_damage_bonus"))        _inst.ability_damage_bonus = 0;
}

/*
 * Name: playerAbilityStep
 * Description: Advance ability timers and update the active damage bonus.
 */
function playerAbilityStep(_inst)
{
    if (!instance_exists(_inst)) return;
    playerAbilityEnsureState(_inst);

    if (_inst.ability_damage_timer > 0)
    {
        _inst.ability_damage_timer -= 1;
        if (_inst.ability_damage_timer > 0)
        {
            _inst.ability_damage_bonus = _inst.ability_damage_amount;
        }
        else
        {
            _inst.ability_damage_timer = 0;
            _inst.ability_damage_bonus = 0;
        }
    }
    else
    {
        _inst.ability_damage_bonus = 0;
    }

    if (_inst.ability_damage_cooldown > 0) _inst.ability_damage_cooldown -= 1;
    if (_inst.ability_damage_cooldown < 0) _inst.ability_damage_cooldown = 0;
}

/*
 * Name: playerAbilityTryActivate
 * Description: Spend essence to activate the damage buff ability if ready.
 */
function playerAbilityTryActivate(_inst)
{
    if (!instance_exists(_inst)) return false;
    playerAbilityEnsureState(_inst);

    if (_inst.ability_damage_timer > 0) return false;
    if (_inst.ability_damage_cooldown > 0) return false;
    if (!playerEssenceCanSpend(_inst, _inst.ability_damage_cost)) return false;

    playerEssenceSpend(_inst, _inst.ability_damage_cost);

    _inst.ability_damage_timer = max(1, round(_inst.ability_damage_duration));
    _inst.ability_damage_cooldown = max(1, round(_inst.ability_damage_cooldown_max));
    _inst.ability_damage_bonus = _inst.ability_damage_amount;
    return true;
}
