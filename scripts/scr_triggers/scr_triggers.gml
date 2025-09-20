// scr_triggers.gml — trigger helper functions

// ====================================================================
// Base helpers
// ====================================================================

/*
* Name: triggerBaseSetActive
* Description: Enable or disable the trigger instance.
*/
function triggerBaseSetActive(_state)
{
    trigger_active = (_state != 0);
}

/*
* Name: triggerBaseIsActive
* Description: Returns whether the trigger should currently process logic.
*/
function triggerBaseIsActive()
{
    return trigger_active;
}

/*
* Name: triggerBaseLayerName
* Description: Resolve the instance layer name, caching the result for reuse.
*/
function triggerBaseLayerName()
{
    if (!is_string(trigger_cached_layer_name) || string_length(trigger_cached_layer_name) <= 0)
    {
        var _layer_id = layer;
        if (is_real(_layer_id) && _layer_id != -1)
        {
            var _layer_name = layer_get_name(_layer_id);
            if (is_string(_layer_name) && string_length(_layer_name) > 0)
            {
                trigger_cached_layer_name = _layer_name;
            }
        }

        if (!is_string(trigger_cached_layer_name) || string_length(trigger_cached_layer_name) <= 0)
        {
            trigger_cached_layer_name = "Instances";
        }
    }

    return trigger_cached_layer_name;
}

/*
* Name: triggerBaseResolveTilemap
* Description: Store a reference to the collision tilemap for later use.
*/
function triggerBaseResolveTilemap()
{
    var _layer_id = layer_get_id("tm_collision");
    if (_layer_id != -1)
    {
        trigger_tilemap_id = layer_tilemap_get_id(_layer_id);
    }
    else
    {
        trigger_tilemap_id = noone;
    }

    return trigger_tilemap_id;
}

/*
* Name: triggerBaseInit
* Description: Prepare shared state for trigger objects.
*/
function triggerBaseInit()
{
    trigger_active = true;
    trigger_cached_layer_name = "";
    trigger_tilemap_id = noone;

    triggerBaseLayerName();
}

/*
* Name: triggerBaseOnDestroy
* Description: Clean up cached state when the trigger is removed.
*/
function triggerBaseOnDestroy()
{
    trigger_cached_layer_name = "";
    trigger_tilemap_id = noone;
}

// ====================================================================
// Player spawn helpers
// ====================================================================

/*
* Name: triggerPlayerSpawnInit
* Description: Reset the internal spawn flag.
*/
function triggerPlayerSpawnInit()
{
    trigger_spawned = false;
}

/*
* Name: triggerPlayerSpawnSpawnPlayer
* Description: Create (or reposition) the player at the trigger's location.
*/
function triggerPlayerSpawnSpawnPlayer()
{
    var _px = x;
    var _py = y;
    var _layer_name = triggerBaseLayerName();

    if (instance_exists(obj_player))
    {
        with (obj_player)
        {
            x = _px;
            y = _py;
        }
    }
    else
    {
        instance_create_layer(_px, _py, _layer_name, obj_player);
    }

    trigger_spawned = true;
}

// ====================================================================
// Enemy spawn helpers
// ====================================================================

/*
* Name: triggerEnemySpawnInit
* Description: Configure default values for the enemy spawner.
*/
function triggerEnemySpawnInit()
{
    spawn_timer = 0;

    if (!variable_instance_exists(id, "spawn_interval_min")) spawn_interval_min = 60;
    if (!variable_instance_exists(id, "spawn_interval_max")) spawn_interval_max = 180;
    if (!variable_instance_exists(id, "spawn_radius"))        spawn_radius = 200;
    if (!variable_instance_exists(id, "spawn_attempts"))      spawn_attempts = 10;

    spawn_pool = [obj_enemy_1, obj_enemy_2];
}

/*
* Name: triggerEnemySpawnReadConfig
* Description: Sanitize user-configured spawn values.
*/
function triggerEnemySpawnReadConfig()
{
    spawn_interval_min = max(1, round(spawn_interval_min));
    spawn_interval_max = max(spawn_interval_min, round(spawn_interval_max));
    spawn_radius       = max(0, spawn_radius);
    spawn_attempts     = max(1, round(spawn_attempts));

    if (!is_array(spawn_pool) || array_length(spawn_pool) <= 0)
    {
        spawn_pool = [obj_enemy_1, obj_enemy_2];
    }
}

/*
* Name: triggerEnemySpawnResetTimer
* Description: Randomise the next spawn time.
*/
function triggerEnemySpawnResetTimer()
{
    spawn_timer = irandom_range(spawn_interval_min, spawn_interval_max);
}

/*
* Name: triggerEnemySpawnPickEnemyObject
* Description: Choose an enemy object from the configured pool.
*/
function triggerEnemySpawnPickEnemyObject()
{
    if (is_array(spawn_pool) && array_length(spawn_pool) > 0)
    {
        var _idx = irandom(array_length(spawn_pool) - 1);
        var _candidate = spawn_pool[_idx];
        if (!is_undefined(_candidate) && _candidate != noone)
        {
            return _candidate;
        }
    }

    return obj_enemy_1;
}

/*
* Name: triggerEnemySpawnSpawnOnce
* Description: Attempt to spawn a single enemy, respecting collision tiles.
*/
function triggerEnemySpawnSpawnOnce()
{
    var _tilemap    = trigger_tilemap_id;
    var _attempts   = max(1, spawn_attempts);
    var _layer_name = triggerBaseLayerName();

    while (_attempts > 0)
    {
        var _sx = x + irandom_range(-spawn_radius, spawn_radius);
        var _sy = y + irandom_range(-spawn_radius, spawn_radius);

        var _blocked = false;
        if (_tilemap != noone && _tilemap != -1)
        {
            var _distance = point_distance(x, y, _sx, _sy);
            var _steps = max(1, ceil(_distance / 16));
            for (var _i = 0; _i <= _steps; ++_i)
            {
                var _t = (_steps <= 0) ? 0 : (_i / _steps);
                var _px = lerp(x, _sx, _t);
                var _py = lerp(y, _sy, _t);
                if (tilemapSolidAt(_tilemap, _px, _py))
                {
                    _blocked = true;
                    break;
                }
            }
        }

        if (!_blocked)
        {
            var _enemy_obj = triggerEnemySpawnPickEnemyObject();
            instance_create_layer(_sx, _sy, _layer_name, _enemy_obj);
            break;
        }

        _attempts -= 1;
    }

    triggerEnemySpawnResetTimer();
}

// ====================================================================
// Level exit helpers
// ====================================================================

/*
* Name: triggerLevelInit
* Description: Reset level exit bookkeeping variables.
*/
function triggerLevelInit()
{
    trigger_triggered = false;
}

/*
* Name: triggerLevelMarkTriggered
* Description: Mark the trigger as completed and disable further use.
*/
function triggerLevelMarkTriggered()
{
    trigger_triggered = true;
    triggerBaseSetActive(false);
}

/*
* Name: triggerLevelSafeMessage
* Description: Retrieve a custom message while providing a sensible fallback.
*/
function triggerLevelSafeMessage(_property_name, _default_value)
{
    if (variable_instance_exists(id, _property_name))
    {
        var _text = string(self[_property_name]);
        if (string_length(_text) > 0)
        {
            return _text;
        }
    }
    return _default_value;
}

/*
* Name: triggerLevelHandlePlayer
* Description: Handle the player entering the exit trigger.
*/
function triggerLevelHandlePlayer(_player)
{
    if (trigger_triggered)
    {
        return;
    }
    if (!instance_exists(_player))
    {
        return;
    }

    triggerLevelMarkTriggered();

    var _message = triggerLevelSafeMessage("level_message", "Exit reached! Prepare for the next area.");
    var _next_room = room_next(room);
    if (_next_room != -1)
    {
        dialogQueuePush(_message, function() { room_goto(_next_room); });
    }
    else
    {
        var _win_text = triggerLevelSafeMessage("level_final_message", "You win! What would you like to do?");
        dialogQueuePushWin(
            _win_text,
            function()
            {
                menuShow();
                room_goto(rm_start);
            },
            function()
            {
                room_restart();
            },
            function()
            {
                game_end();
            }
        );
    }
}
