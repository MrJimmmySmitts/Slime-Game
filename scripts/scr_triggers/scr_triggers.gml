// ====================================================================
// scr_triggers.gml — data-driven trigger behaviours
// ====================================================================

/*
* Name: TriggerKind
* Description: Enumerates trigger behaviour specialisations.
*/
enum TriggerKind
{
    PlayerSpawn = 0,
    EnemySpawn  = 1,
    LevelExit   = 2,
}

/*
* Name: TriggerBase
* Description: Base behaviour that exposes lifecycle hooks for obj_trigger instances.
*/
function TriggerBase(_inst) constructor
{
    inst               = _inst;
    active             = true;
    cached_layer_name  = "";
    tilemap_id         = noone;

    function setActive(_state) { active = _state; }
    function isActive() { return active; }

    function layerName()
    {
        if (!instance_exists(inst)) return "Instances";

        if (!is_string(cached_layer_name) || string_length(cached_layer_name) <= 0)
        {
            var _lid  = inst.layer;
            var _name = "";
            if (!is_undefined(_lid))
            {
                _name = layer_get_name(_lid);
            }

            if (is_string(_name) && string_length(_name) > 0)
            {
                cached_layer_name = _name;
            }
            else
            {
                cached_layer_name = "Instances";
            }
        }

        return cached_layer_name;
    }

    function resolveTilemap()
    {
        var _layer_id = layer_get_id("tm_collision");
        if (_layer_id != -1)
        {
            tilemap_id = layer_tilemap_get_id(_layer_id);
        }
        else
        {
            tilemap_id = noone;
        }
        return tilemap_id;
    }

    function onCreate()
    {
        layerName();
    }

    function onRoomStart() { }
    function onStep()      { }
    function onPlayerEnter(_player) { }
    function onDestroy()   { }
}

/*
* Name: TriggerPlayerSpawn
* Description: Spawns (or repositions) the player when the room loads.
*/
function TriggerPlayerSpawn(_inst) constructor
{
    TriggerBase(_inst);

    kind    = TriggerKind.PlayerSpawn;
    spawned = false;

    var _super_on_create     = onCreate;
    var _super_on_room_start = onRoomStart;

    function spawnPlayer()
    {
        if (!instance_exists(inst)) return;
        var _px = inst.x;
        var _py = inst.y;
        var _layer_name = layerName();

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

        spawned = true;
    }

    function onCreate()
    {
        _super_on_create();
    }

    function onRoomStart()
    {
        _super_on_room_start();
        if (!spawned)
        {
            spawnPlayer();
        }
    }
}

/*
* Name: TriggerEnemySpawn
* Description: Spawns enemies around the trigger while respecting tile collision.
*/
function TriggerEnemySpawn(_inst) constructor
{
    TriggerBase(_inst);

    kind                = TriggerKind.EnemySpawn;
    spawn_timer         = 0;
    spawn_interval_min  = 60;
    spawn_interval_max  = 180;
    spawn_radius        = 200;
    spawn_attempts      = 10;
    spawn_pool          = [obj_enemy_1, obj_enemy_2];

    var _super_on_create = onCreate;
    var _super_on_step   = onStep;

    function readConfig()
    {
        if (!instance_exists(inst)) return;

        if (variable_instance_exists(inst, "spawn_interval_min"))
        {
            spawn_interval_min = max(1, round(inst.spawn_interval_min));
        }
        if (variable_instance_exists(inst, "spawn_interval_max"))
        {
            spawn_interval_max = max(spawn_interval_min, round(inst.spawn_interval_max));
        }
        else if (spawn_interval_max < spawn_interval_min)
        {
            spawn_interval_max = spawn_interval_min;
        }

        if (variable_instance_exists(inst, "spawn_radius"))
        {
            spawn_radius = max(0, inst.spawn_radius);
        }
        if (variable_instance_exists(inst, "spawn_attempts"))
        {
            spawn_attempts = max(1, round(inst.spawn_attempts));
        }
    }

    function resetTimer()
    {
        spawn_timer = irandom_range(spawn_interval_min, spawn_interval_max);
    }

    function pickEnemyObject()
    {
        if (is_array(spawn_pool) && array_length(spawn_pool) > 0)
        {
            var _idx = irandom(array_length(spawn_pool) - 1);
            var _obj = spawn_pool[_idx];
            if (!is_undefined(_obj) && _obj != noone) return _obj;
        }
        return obj_enemy_1;
    }

    function spawnOnce()
    {
        if (!instance_exists(inst)) return;

        var _tilemap    = tilemap_id;
        var _attempts   = max(1, spawn_attempts);
        var _layer_name = layerName();

        while (_attempts > 0)
        {
            var _sx = inst.x + irandom_range(-spawn_radius, spawn_radius);
            var _sy = inst.y + irandom_range(-spawn_radius, spawn_radius);

            var _blocked = false;
            if (_tilemap != noone && _tilemap != -1)
            {
                var _dist  = point_distance(inst.x, inst.y, _sx, _sy);
                var _steps = max(1, ceil(_dist / 16));
                for (var _i = 0; _i <= _steps; _i++)
                {
                    var _t  = (_steps <= 0) ? 0 : (_i / _steps);
                    var _px = lerp(inst.x, _sx, _t);
                    var _py = lerp(inst.y, _sy, _t);
                    if (tilemapSolidAt(_tilemap, _px, _py))
                    {
                        _blocked = true;
                        break;
                    }
                }
            }

            if (!_blocked)
            {
                var _enemy_obj = pickEnemyObject();
                instance_create_layer(_sx, _sy, _layer_name, _enemy_obj);
                break;
            }

            _attempts -= 1;
        }

        resetTimer();
    }

    function onCreate()
    {
        _super_on_create();
        readConfig();
        resolveTilemap();
        resetTimer();
    }

    function onStep()
    {
        _super_on_step();
        if (!active) return;
        if (onPauseExit()) return;

        if (spawn_timer > 0) spawn_timer -= 1;
        if (spawn_timer <= 0)
        {
            spawnOnce();
        }
    }
}

/*
* Name: TriggerLevel
* Description: Handles level completion and final victory dialogue.
*/
function TriggerLevel(_inst) constructor
{
    TriggerBase(_inst);

    kind      = TriggerKind.LevelExit;
    triggered = false;

    var _super_on_create = onCreate;

    function markTriggered()
    {
        triggered = true;
        setActive(false);
    }

    function safeString(_value, _fallback)
    {
        var _text = string(_value);
        if (string_length(_text) <= 0) return _fallback;
        return _text;
    }

    function onCreate()
    {
        _super_on_create();
    }

    function onPlayerEnter(_player)
    {
        if (triggered) return;
        if (!instance_exists(_player)) return;

        markTriggered();

        var _inst = inst;
        var _default_msg = "Exit reached! Prepare for the next area.";
        var _message = _default_msg;
        if (instance_exists(_inst) && variable_instance_exists(_inst, "level_message"))
        {
            _message = safeString(_inst.level_message, _default_msg);
        }

        var _next_room = room_next(room);
        if (_next_room != -1)
        {
            dialogQueuePush(_message, function() {
                room_goto(_next_room);
            });
        }
        else
        {
            var _default_win = "You win! What would you like to do?";
            var _win_text = _default_win;
            if (instance_exists(_inst) && variable_instance_exists(_inst, "level_final_message"))
            {
                _win_text = safeString(_inst.level_final_message, _default_win);
            }

            dialogQueuePushWin(
                _win_text,
                function() {
                    menuShow();
                    room_goto(rm_start);
                },
                function() {
                    room_restart();
                },
                function() {
                    game_end();
                }
            );
        }
    }
}

/*
* Name: triggerCreateBehaviour
* Description: Factory helper for obj_trigger to build the correct behaviour struct.
*/
function triggerCreateBehaviour(_inst, _kind)
{
    switch (_kind)
    {
        case TriggerKind.PlayerSpawn:
            return TriggerPlayerSpawn(_inst);

        case TriggerKind.EnemySpawn:
            return TriggerEnemySpawn(_inst);

        case TriggerKind.LevelExit:
        default:
            return TriggerLevel(_inst);
    }
}
