// ====================================================================
// scr_input.gml — keyboard mapping in one place
// ====================================================================

function inputArrayClone(_array)
{
    if (!is_array(_array)) return [];
    var _len  = array_length(_array);
    var _copy = array_create(_len);
    for (var _i = 0; _i < _len; _i++) _copy[_i] = _array[_i];
    return _copy;
}

function inputBindingActionDefinitions()
{
    static _defs = [
        { name: "move_up",    label: "Move Up",    group: "Movement",  slots: ["Primary", "Alternate"], default: [ord("W"), vk_up] },
        { name: "move_down",  label: "Move Down",  group: "Movement",  slots: ["Primary", "Alternate"], default: [ord("S"), vk_down] },
        { name: "move_left",  label: "Move Left",  group: "Movement",  slots: ["Primary", "Alternate"], default: [ord("A"), vk_left] },
        { name: "move_right", label: "Move Right", group: "Movement",  slots: ["Primary", "Alternate"], default: [ord("D"), vk_right] },
        { name: "dash",       label: "Dash",       group: "Movement",  slots: ["Primary"],            default: [vk_space] },

        { name: "melee",      label: "Melee",      group: "Combat",    slots: ["Primary"],            default: [vk_shift] },
        { name: "ability",    label: "Ability",    group: "Combat",    slots: ["Primary"],            default: [ord("E")] },

        { name: "aim_up",     label: "Aim Up",     group: "Aim",       slots: ["Primary"],            default: [ord("I")] },
        { name: "aim_down",   label: "Aim Down",   group: "Aim",       slots: ["Primary"],            default: [ord("K")] },
        { name: "aim_left",   label: "Aim Left",   group: "Aim",       slots: ["Primary"],            default: [ord("J")] },
        { name: "aim_right",  label: "Aim Right",  group: "Aim",       slots: ["Primary"],            default: [ord("L")] },

        { name: "inventory",  label: "Inventory",  group: "Interface", slots: ["Primary"],            default: [vk_tab] }
    ];

    return _defs;
}

function inputBindingFindDefinition(_action)
{
    var _defs  = inputBindingActionDefinitions();
    var _count = array_length(_defs);
    for (var _i = 0; _i < _count; _i++)
    {
        var _def = _defs[_i];
        if (_def.name == _action) return _def;
    }
    return undefined;
}

function inputCreateDefaultBindings()
{
    var _defs    = inputBindingActionDefinitions();
    var _count   = array_length(_defs);
    var _result  = {};

    for (var _i = 0; _i < _count; _i++)
    {
        var _def   = _defs[_i];
        var _array = inputArrayClone(_def.default);
        variable_struct_set(_result, _def.name, _array);
    }

    return _result;
}

function inputBindingsClone(_source)
{
    var _clone = {};
    var _defs  = inputBindingActionDefinitions();
    var _count = array_length(_defs);

    for (var _i = 0; _i < _count; _i++)
    {
        var _def      = _defs[_i];
        var _defaults = _def.default;
        var _slots    = array_length(_defaults);
        var _array    = array_create(_slots);

        for (var _s = 0; _s < _slots; _s++)
        {
            var _value = undefined;
            if (is_struct(_source) && variable_struct_exists(_source, _def.name))
            {
                var _src_array = variable_struct_get(_source, _def.name);
                if (is_array(_src_array) && _s < array_length(_src_array))
                {
                    var _candidate = _src_array[_s];
                    if (is_real(_candidate)) _value = _candidate;
                }
            }

            if (!is_real(_value)) _value = _defaults[_s];
            _array[_s] = _value;
        }

        variable_struct_set(_clone, _def.name, _array);
    }

    return _clone;
}

function inputBindingsEnsureDefaults(_bindings)
{
    if (!is_struct(_bindings)) _bindings = {};
    return inputBindingsClone(_bindings);
}

function inputBindingsEqual(_lhs, _rhs)
{
    var _left  = inputBindingsClone(_lhs);
    var _right = inputBindingsClone(_rhs);
    var _defs  = inputBindingActionDefinitions();
    var _count = array_length(_defs);

    for (var _i = 0; _i < _count; _i++)
    {
        var _def    = _defs[_i];
        var _left_a = variable_struct_get(_left,  _def.name);
        var _right_a= variable_struct_get(_right, _def.name);
        var _len    = array_length(_left_a);

        for (var _j = 0; _j < _len; _j++)
        {
            if (_left_a[_j] != _right_a[_j]) return false;
        }
    }

    return true;
}

function inputBindingsGetKeys(_action)
{
    if (!variable_global_exists("Settings")) return [];

    if (!variable_struct_exists(global.Settings, "key_bindings") || !is_struct(global.Settings.key_bindings))
    {
        global.Settings.key_bindings = inputCreateDefaultBindings();
    }

    global.Settings.key_bindings = inputBindingsEnsureDefaults(global.Settings.key_bindings);

    if (!variable_struct_exists(global.Settings.key_bindings, _action)) return [];

    var _keys = variable_struct_get(global.Settings.key_bindings, _action);
    if (!is_array(_keys)) return [];
    return _keys;
}

function inputBindingCheckHeld(_action)
{
    var _keys  = inputBindingsGetKeys(_action);
    var _count = array_length(_keys);
    for (var _i = 0; _i < _count; _i++)
    {
        var _key = _keys[_i];
        if (is_real(_key) && keyboard_check(_key)) return true;
    }
    return false;
}

function inputBindingCheckPressed(_action)
{
    var _keys  = inputBindingsGetKeys(_action);
    var _count = array_length(_keys);
    for (var _i = 0; _i < _count; _i++)
    {
        var _key = _keys[_i];
        if (is_real(_key) && keyboard_check_pressed(_key)) return true;
    }
    return false;
}

/*
* Name: inputGetMove
* Description: Returns a normalised {dx, dy} from the configured movement bindings.
*/
function inputGetMove()
{
    var mv_dx = (inputBindingCheckHeld("move_right") ? 1 : 0) - (inputBindingCheckHeld("move_left")  ? 1 : 0);
    var mv_dy = (inputBindingCheckHeld("move_down")  ? 1 : 0) - (inputBindingCheckHeld("move_up")   ? 1 : 0);

    var n = vec2Norm(mv_dx, mv_dy);
    return { dx: n[0], dy: n[1] };
}

/*
* Name: inputGetAimHeld
* Description: Returns a normalised {dx, dy} vector from configured aim bindings.
*/
function inputGetAimHeld()
{
    var aim_dx = (inputBindingCheckHeld("aim_right") ? 1 : 0) - (inputBindingCheckHeld("aim_left") ? 1 : 0);
    var aim_dy = (inputBindingCheckHeld("aim_down")  ? 1 : 0) - (inputBindingCheckHeld("aim_up")   ? 1 : 0);
    var n = vec2Norm(aim_dx, aim_dy);
    return { dx: n[0], dy: n[1] };
}

/*
* Name: inputGetAimPressed
* Description: Returns a unit {dx, dy} for the *pressed this step* aim binding.
*              Priority order: Up, Left, Down, Right.
*/
function inputGetAimPressed()
{
    if (inputBindingCheckPressed("aim_up"))    return { dx:  0, dy: -1 };
    if (inputBindingCheckPressed("aim_left"))  return { dx: -1, dy:  0 };
    if (inputBindingCheckPressed("aim_down"))  return { dx:  0, dy:  1 };
    if (inputBindingCheckPressed("aim_right")) return { dx:  1, dy:  0 };
    return { dx: 0, dy: 0 };
}

/*
* Name: inputDashPressed
* Description: Returns true if the configured dash binding is pressed this step.
*/
function inputDashPressed()
{
    var _locked = variable_instance_exists(id, "input_locked") && input_locked;
    if (_locked) return false;
    return inputBindingCheckPressed("dash");
}

/*
* Name: inputGetAimAxis
* Description: Returns a 2-element array [dx, dy] for current aim.
*              Uses configured aim bindings if pressed; otherwise falls back to the instance's facing_x/facing_y.
*/
function inputGetAimAxis()
{
    var held = inputGetAimHeld(); // {dx, dy}
    if (held.dx != 0 || held.dy != 0) return [held.dx, held.dy];

    // Fallback to facing if available on the calling instance
    if (variable_instance_exists(id, "facing_x") && variable_instance_exists(id, "facing_y"))
        return [facing_x, facing_y];

    // Final fallback: aim right
    return [1, 0];
}

/*
* Name: inputFirePressed
* Description: True on the frame primary fire is pressed AND input isn't locked.
*/
function inputFirePressed()
{
    var _locked = variable_instance_exists(id, "input_locked") && input_locked;
    if (_locked) return false;
    return mouse_check_button_pressed(mb_left);
}

/*
* Name: inputFireHeld
* Description: True while primary fire is held AND input isn't locked.
*/
function inputFireHeld()
{
    var _locked = variable_instance_exists(id, "input_locked") && input_locked;
    if (_locked) return false;
    return mouse_check_button(mb_left);
}

/*
 * Name: inputMeleePressed
 * Description: True on the frame the melee binding is pressed while input is unlocked.
 */
function inputMeleePressed()
{
    var _locked = variable_instance_exists(id, "input_locked") && input_locked;
    if (_locked) return false;
    return inputBindingCheckPressed("melee");
}

/*
 * Name: inputAbilityPressed
 * Description: True on the frame the ability binding is pressed while input is unlocked.
 */
function inputAbilityPressed()
{
    var _locked = variable_instance_exists(id, "input_locked") && input_locked;
    if (_locked) return false;
    return inputBindingCheckPressed("ability");
}
