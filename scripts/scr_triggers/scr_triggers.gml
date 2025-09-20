
// scr_triggers.gml — trigger behaviour structs and helpers

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


// --------------------------------------------------------------------
// TriggerBase helpers
// --------------------------------------------------------------------

function TriggerBase_setActive(_state)
{
    self.active = (_state != 0);
}

function TriggerBase_isActive()
{
    return self.active;
}

function TriggerBase_layerName()
{
    if (!instance_exists(self.inst))
    {
        return "Instances";
    }

    if (!is_string(self.cached_layer_name) || string_length(self.cached_layer_name) <= 0)
    {
        var _layer_id = self.inst.layer;
        if (is_real(_layer_id) && _layer_id != -1)
        {
            var _layer_name = layer_get_name(_layer_id);
            if (is_string(_layer_name) && string_length(_layer_name) > 0)
            {
                self.cached_layer_name = _layer_name;
            }
        }

        if (!is_string(self.cached_layer_name) || string_length(self.cached_layer_name) <= 0)
        {
            self.cached_layer_name = "Instances";
        }
    }

    return self.cached_layer_name;
}

function TriggerBase_resolveTilemap()
{
    var _layer_id = layer_get_id("tm_collision");
    if (_layer_id != -1)
    {
        self.tilemap_id = layer_tilemap_get_id(_layer_id);
    }
    else
    {
        self.tilemap_id = noone;
    }
    return self.tilemap_id;
}

function TriggerBase_onCreate()
{
    self.cached_layer_name = "";
    self.layerName();
}

function TriggerBase_onRoomStart() { }
function TriggerBase_onStep()      { }
function TriggerBase_onPlayerEnter(_player) { }

function TriggerBase_onDestroy()
{
    self.inst = undefined;
}

/*
* Name: TriggerBase
* Description: Base behaviour struct shared by all trigger kinds.
*/
function TriggerBase(_inst) constructor
{
    inst              = _inst;
    active            = true;
    cached_layer_name = "";
    tilemap_id        = noone;

    setActive      = method(self, TriggerBase_setActive);
    isActive       = method(self, TriggerBase_isActive);
    layerName      = method(self, TriggerBase_layerName);
    resolveTilemap = method(self, TriggerBase_resolveTilemap);
    onCreate       = method(self, TriggerBase_onCreate);
    onRoomStart    = method(self, TriggerBase_onRoomStart);
    onStep         = method(self, TriggerBase_onStep);
    onPlayerEnter  = method(self, TriggerBase_onPlayerEnter);
    onDestroy      = method(self, TriggerBase_onDestroy);
}

// --------------------------------------------------------------------
// TriggerPlayerSpawn helpers
// --------------------------------------------------------------------

function TriggerPlayerSpawn_spawnPlayer()
{
    if (!instance_exists(self.inst))
    {
        return;
    }

    var _px = self.inst.x;
    var _py = self.inst.y;
    var _layer_name = self.layerName();

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

    self.spawned = true;
}

function TriggerPlayerSpawn_onCreate()
{
    if (!is_undefined(self._base_on_create))
    {
        self._base_on_create();
    }
    self.spawned = false;
}

function TriggerPlayerSpawn_onRoomStart()
{
    if (!is_undefined(self._base_on_room_start))
    {
        self._base_on_room_start();
    }

    if (!self.spawned)
    {
        self.spawnPlayer();
    }
}

/*
* Name: TriggerPlayerSpawn
* Description: Spawns (or repositions) the player when the room loads.
*/
function TriggerPlayerSpawn(_inst) constructor
{
    TriggerBase(_inst);

    spawned = false;

    spawnPlayer = method(self, TriggerPlayerSpawn_spawnPlayer);

    _base_on_create = self.onCreate;
    onCreate = method(self, TriggerPlayerSpawn_onCreate);

    _base_on_room_start = self.onRoomStart;
    onRoomStart = method(self, TriggerPlayerSpawn_onRoomStart);
}

// --------------------------------------------------------------------
// TriggerEnemySpawn helpers
// --------------------------------------------------------------------

function TriggerEnemySpawn_readConfig()
{
    if (!instance_exists(self.inst))
    {
        return;
    }

    if (variable_instance_exists(self.inst, "spawn_interval_min"))
    {
        self.spawn_interval_min = max(1, round(self.inst.spawn_interval_min));
    }

    if (variable_instance_exists(self.inst, "spawn_interval_max"))
    {
        self.spawn_interval_max = max(self.spawn_interval_min, round(self.inst.spawn_interval_max));
    }
    else if (self.spawn_interval_max < self.spawn_interval_min)
    {
        self.spawn_interval_max = self.spawn_interval_min;
    }

    if (variable_instance_exists(self.inst, "spawn_radius"))
    {
        self.spawn_radius = max(0, self.inst.spawn_radius);
    }

    if (variable_instance_exists(self.inst, "spawn_attempts"))
    {
        self.spawn_attempts = max(1, round(self.inst.spawn_attempts));
    }
}

function TriggerEnemySpawn_resetTimer()
{
    self.spawn_timer = irandom_range(self.spawn_interval_min, self.spawn_interval_max);
}

function TriggerEnemySpawn_pickEnemyObject()
{
    if (is_array(self.spawn_pool) && array_length(self.spawn_pool) > 0)
    {
        var _idx = irandom(array_length(self.spawn_pool) - 1);
        var _candidate = self.spawn_pool[_idx];
        if (!is_undefined(_candidate) && _candidate != noone)
        {
            return _candidate;
        }
    }

    return obj_enemy_1;
}

function TriggerEnemySpawn_spawnOnce()
{
    if (!instance_exists(self.inst))
    {
        self.resetTimer();
        return;
    }

    var _tilemap    = self.tilemap_id;
    var _attempts   = max(1, self.spawn_attempts);
    var _layer_name = self.layerName();

    while (_attempts > 0)
    {
        var _sx = self.inst.x + irandom_range(-self.spawn_radius, self.spawn_radius);
        var _sy = self.inst.y + irandom_range(-self.spawn_radius, self.spawn_radius);

        var _blocked = false;
        if (_tilemap != noone && _tilemap != -1)
        {
            var _distance = point_distance(self.inst.x, self.inst.y, _sx, _sy);
            var _steps = max(1, ceil(_distance / 16));
            for (var _i = 0; _i <= _steps; ++_i)
            {
                var _t = (_steps <= 0) ? 0 : (_i / _steps);
                var _px = lerp(self.inst.x, _sx, _t);
                var _py = lerp(self.inst.y, _sy, _t);
                if (tilemapSolidAt(_tilemap, _px, _py))
                {
                    _blocked = true;
                    break;
                }
            }
        }

        if (!_blocked)
        {
            var _enemy_obj = self.pickEnemyObject();
            instance_create_layer(_sx, _sy, _layer_name, _enemy_obj);
            break;
        }

        _attempts -= 1;
    }

    self.resetTimer();
}

function TriggerEnemySpawn_onCreate()
{
    if (!is_undefined(self._base_on_create))
    {
        self._base_on_create();
    }
    self.readConfig();
}

function TriggerEnemySpawn_onRoomStart()
{
    if (!is_undefined(self._base_on_room_start))
    {
        self._base_on_room_start();
    }
    self.resolveTilemap();
    self.resetTimer();
}

function TriggerEnemySpawn_onStep()
{
    if (!is_undefined(self._base_on_step))
    {
        self._base_on_step();
    }
    if (!self.isActive())
    {
        return;
    }
    if (onPauseExit())
    {
        return;
    }

    if (self.spawn_timer > 0)
    {
        self.spawn_timer -= 1;
    }

    if (self.spawn_timer <= 0)
    {
        self.spawnOnce();
    }
}

/*
* Name: TriggerEnemySpawn
* Description: Spawns enemies around the trigger while respecting tile collision.
*/
function TriggerEnemySpawn(_inst) constructor
{
    TriggerBase(_inst);

    spawn_timer        = 0;
    spawn_interval_min = 60;
    spawn_interval_max = 180;
    spawn_radius       = 200;
    spawn_attempts     = 10;
    spawn_pool         = [obj_enemy_1, obj_enemy_2];

    readConfig      = method(self, TriggerEnemySpawn_readConfig);
    resetTimer      = method(self, TriggerEnemySpawn_resetTimer);
    pickEnemyObject = method(self, TriggerEnemySpawn_pickEnemyObject);
    spawnOnce       = method(self, TriggerEnemySpawn_spawnOnce);

    _base_on_create = self.onCreate;
    onCreate = method(self, TriggerEnemySpawn_onCreate);

    _base_on_room_start = self.onRoomStart;
    onRoomStart = method(self, TriggerEnemySpawn_onRoomStart);

    _base_on_step = self.onStep;
    onStep = method(self, TriggerEnemySpawn_onStep);
}

// --------------------------------------------------------------------
// TriggerLevel helpers
// --------------------------------------------------------------------

function TriggerLevel_markTriggered()
{
    self.triggered = true;
    self.setActive(false);
}

function TriggerLevel_safeMessage(_property_name, _default_value)
{
    if (instance_exists(self.inst) && variable_instance_exists(self.inst, _property_name))
    {
        var _text = string(self.inst[_property_name]);
        if (string_length(_text) > 0)
        {
            return _text;
        }
    }
    return _default_value;
}

function TriggerLevel_onPlayerEnter(_player)
{
    if (!is_undefined(self._base_on_player_enter))
    {
        self._base_on_player_enter(_player);
    }

    if (self.triggered)
    {
        return;
    }
    if (!instance_exists(_player))
    {
        return;
    }

    self.markTriggered();

    var _message = self.safeMessage("level_message", "Exit reached! Prepare for the next area.");
    var _next_room = room_next(room);
    if (_next_room != -1)
    {
        dialogQueuePush(_message, function() { room_goto(_next_room); });
    }
    else
    {
        var _win_text = self.safeMessage("level_final_message", "You win! What would you like to do?");
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

/*
* Name: TriggerLevel
* Description: Handles level completion and final victory dialogue.
*/
function TriggerLevel(_inst) constructor
{
    TriggerBase(_inst);

    triggered = false;

    markTriggered = method(self, TriggerLevel_markTriggered);
    safeMessage   = method(self, TriggerLevel_safeMessage);

    _base_on_player_enter = self.onPlayerEnter;
    onPlayerEnter = method(self, TriggerLevel_onPlayerEnter);
}

// --------------------------------------------------------------------
// Factory helper
// --------------------------------------------------------------------


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
