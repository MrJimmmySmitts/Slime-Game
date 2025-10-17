// ====================================================================
// scr_input.gml — keyboard/controller mapping in one place
// Author: James Smith
// ====================================================================
// ====================================================================
// Name: ControlScheme
// Description: State structure for control scheme toggling
// ====================================================================
enum ControlScheme {
    KeyboardMouse = 0,
    Controller    = 1,
    KeyboardOnly  = 2,
}
// ====================================================================
// Name: inputControlSchemeKey
// Description: Returns key[???] corresponding to control scheme
// ====================================================================
function inputControlSchemeKey(_scheme) {
    switch (_scheme) {
        case ControlScheme.Controller:   
            return "controller";
        case ControlScheme.KeyboardOnly: 
            return "keyboard_only";
        case ControlScheme.KeyboardMouse: 
        default:
            return "keyboard_mouse";
    }
}
// ====================================================================
// Name: inputControlSchemeList
// Description: Used for settings menu to display radio button options
// ====================================================================
function inputControlSchemeList() {
    return [ControlScheme.KeyboardMouse, ControlScheme.Controller, ControlScheme.KeyboardOnly];
}
// ====================================================================
// Name: inputGamepadGetActive
// Description: [???]
// ====================================================================
function inputGamepadGetActive() {
    var _max = 8;
    for (var _pad = 0; _pad < _max; _pad++) {
        if (gamepad_is_connected(_pad)) return _pad;
    }
    return -1;
}
// ====================================================================
// Name: inputGamepadAllButtons
// Description: Return a list of all gamepad buttons
// ====================================================================
function inputGamepadAllButtons() {
    static _buttons = undefined;

    if (!is_array(_buttons)) {
        _buttons = [
            gp_face1, gp_face2, gp_face3, gp_face4,
            gp_shoulderl, gp_shoulderr, gp_shoulderlb, gp_shoulderrb,
            gp_stickl, gp_stickr,
            gp_padu, gp_paddown, gp_padleft, gp_padright,
            gp_select, gp_start
        ];
    }
    return _buttons;
}
// ====================================================================
// Name: inputGamepadButtonLabel
// Description: Return user friendly labels for settings menu
// ====================================================================
function inputGamepadButtonLabel(_code) {
    if (!is_real(_code)) return "(unassigned)";

    switch (_code) {
        case gp_face1:      return "Face 1 (Bottom)";
        case gp_face2:      return "Face 2 (Right)";
        case gp_face3:      return "Face 3 (Left)";
        case gp_face4:      return "Face 4 (Top)";
        case gp_shoulderl:  return "Left Bumper";
        case gp_shoulderr:  return "Right Bumper";
        case gp_shoulderlb: return "Left Trigger";
        case gp_shoulderrb: return "Right Trigger";
        case gp_stickl:     return "Left Stick Button";
        case gp_stickr:     return "Right Stick Button";
        case gp_padu:       return "D-Pad Up";
        case gp_paddown:    return "D-Pad Down";
        case gp_padleft:    return "D-Pad Left";
        case gp_padright:   return "D-Pad Right";
        case gp_select:     return "Select";
        case gp_start:      return "Start";
    }

    return "Button " + string(_code);
}
// ====================================================================
// Name: inputGamepadButtonCheck
// Description: Check gamepad button [IS THIS NEEDED?]
// ====================================================================
function inputGamepadButtonCheck(_pad, _code) {
    if (_pad < 0) return false;
    if (!is_real(_code)) return false;
    return gamepad_button_check(_pad, _code);
}
// ====================================================================
// Name: inputGamepadButtonCheckPressed
// Description: Check gamepad button pressed[IS THIS NEEDED?]
// ====================================================================
function inputGamepadButtonCheckPressed(_pad, _code) {
    if (_pad < 0) return false;
    if (!is_real(_code)) return false;
    return gamepad_button_check_pressed(_pad, _code);
}
// ====================================================================
// Name: inputGamepadDigitalAxis
// Description: Something about digital axis[???]
// ====================================================================
function inputGamepadDigitalAxis(_pad, _positive_codes, _negative_codes) {
    if (_pad < 0) return 0;

    var _value = 0;

    if (is_array(_positive_codes)) {
        var _count_pos = array_length(_positive_codes);
        for (var _i = 0; _i < _count_pos; _i++) {
            if (inputGamepadButtonCheck(_pad, _positive_codes[_i])) {
                _value += 1;
                break;
            }
        }
    }
    if (is_array(_negative_codes)) {
        var _count_neg = array_length(_negative_codes);
        for (var _j = 0; _j < _count_neg; _j++) {
            if (inputGamepadButtonCheck(_pad, _negative_codes[_j])) {
                _value -= 1;
                break;
            }
        }
    }
    return clamp(_value, -1, 1);
}
// ====================================================================
// Name: inputBindingsSchemeEnsureStruct
// Description: make sure the bindings are default[DO I NEED THIS ???]
// ====================================================================
function inputBindingsSchemeEnsureStruct(_bindings, _scheme) {
    if (!is_struct(_bindings)) _bindings = {};

    var _key = inputControlSchemeKey(_scheme);
    var _current = {};

    if (variable_struct_exists(_bindings, _key)) {
        _current = variable_struct_get(_bindings, _key);
    }

    if (!is_struct(_current)) _current = {};

    var _defs  = inputBindingActionDefinitions(_scheme);
    var _count = array_length(_defs);

    for (var _i = 0; _i < _count; _i++) {
        var _def      = _defs[_i];
        var _defaults = _def.default;
        var _slots    = array_length(_defaults);
        if (_slots <= 0) _slots = 1;

        var _array = [];
        if (variable_struct_exists(_current, _def.name)) {
            var _existing = variable_struct_get(_current, _def.name);
            if (is_array(_existing)) {
                _array = inputArrayClone(_existing);
            }
        }

        if (!is_array(_array) || array_length(_array) != _slots) {
            _array = inputArrayClone(_defaults);
        }

        for (var _s = 0; _s < _slots; _s++) {
            var _candidate = _array[_s];
            if (!is_real(_candidate)) {
                _array[_s] = _defaults[_s];
            }
        }

        variable_struct_set(_current, _def.name, _array);
    }

    variable_struct_set(_bindings, _key, _current);
    return _bindings;
}
// ====================================================================
// Name: inputArrayClone
// Description: duplicate input bindings array [DO I NEED THIS ???]
// ====================================================================
function inputArrayClone(_array) {
    if (!is_array(_array)) return [];
    var _len  = array_length(_array);
    var _copy = array_create(_len);
    for (var _i = 0; _i < _len; _i++) _copy[_i] = _array[_i];
    return _copy;
}
// ====================================================================
// Name: inputBindingActionDefinitions
// Description: Defining the Key Bindings for all control schemes for use in settings
// ====================================================================
function inputBindingActionDefinitions(_scheme) {
    switch (_scheme) {
        case ControlScheme.Controller: {
            return [
                { name: "move_up",    label: "Move Up",    group: "Movement",  slots: ["Primary"], default: [gp_padu] },
                { name: "move_down",  label: "Move Down",  group: "Movement",  slots: ["Primary"], default: [gp_padd] },
                { name: "move_left",  label: "Move Left",  group: "Movement",  slots: ["Primary"], default: [gp_padl] },
                { name: "move_right", label: "Move Right", group: "Movement",  slots: ["Primary"], default: [gp_padr] },
                { name: "dash",       label: "Dash",       group: "Movement",  slots: ["Primary"], default: [gp_face2] },

                { name: "fire",       label: "Fire",       group: "Combat",    slots: ["Primary"], default: [gp_face1] },
                { name: "melee",      label: "Melee",      group: "Combat",    slots: ["Primary"], default: [gp_shoulderl] },
                { name: "ability",    label: "Ability",    group: "Combat",    slots: ["Primary"], default: [gp_shoulderr] },
                
                { name: "inventory",  label: "Inventory",  group: "Interface", slots: ["Primary"], default: [gp_start] }
            ];
        }

        case ControlScheme.KeyboardOnly:
        {
            return [
                { name: "move_up",    label: "Move Up",    group: "Movement",  slots: ["Primary", "Alternate"], default: [ord("W"), vk_up] },
                { name: "move_down",  label: "Move Down",  group: "Movement",  slots: ["Primary", "Alternate"], default: [ord("S"), vk_down] },
                { name: "move_left",  label: "Move Left",  group: "Movement",  slots: ["Primary", "Alternate"], default: [ord("A"), vk_left] },
                { name: "move_right", label: "Move Right", group: "Movement",  slots: ["Primary", "Alternate"], default: [ord("D"), vk_right] },
                { name: "dash",       label: "Dash",       group: "Movement",  slots: ["Primary"],            default: [vk_space] },

                { name: "fire",       label: "Fire",       group: "Combat",    slots: ["Primary"],            default: [vk_control] },
                { name: "melee",      label: "Melee",      group: "Combat",    slots: ["Primary"],            default: [vk_shift] },
                { name: "ability",    label: "Ability",    group: "Combat",    slots: ["Primary"],            default: [ord("E")] },

                { name: "aim_up",     label: "Aim Up",     group: "Aim",       slots: ["Primary"],            default: [ord("I")] },
                { name: "aim_down",   label: "Aim Down",   group: "Aim",       slots: ["Primary"],            default: [ord("K")] },
                { name: "aim_left",   label: "Aim Left",   group: "Aim",       slots: ["Primary"],            default: [ord("J")] },
                { name: "aim_right",  label: "Aim Right",  group: "Aim",       slots: ["Primary"],            default: [ord("L")] },

                { name: "inventory",  label: "Inventory",  group: "Interface", slots: ["Primary"],            default: [vk_tab] }
            ];
        }
        case ControlScheme.KeyboardMouse: 
        default: {
             return [
                { name: "move_up",    label: "Move Up",    group: "Movement",  slots: ["Primary", "Alternate"], default: [ord("W"), vk_up] },
                { name: "move_down",  label: "Move Down",  group: "Movement",  slots: ["Primary", "Alternate"], default: [ord("S"), vk_down] },
                { name: "move_left",  label: "Move Left",  group: "Movement",  slots: ["Primary", "Alternate"], default: [ord("A"), vk_left] },
                { name: "move_right", label: "Move Right", group: "Movement",  slots: ["Primary", "Alternate"], default: [ord("D"), vk_right] },
                { name: "dash",       label: "Dash",       group: "Movement",  slots: ["Primary"],            default: [vk_space] },
        
                { name: "fire",       label: "Fire",       group: "Combat",    slots: ["Primary"],            default: [vk_control] },
                { name: "melee",      label: "Melee",      group: "Combat",    slots: ["Primary"],            default: [vk_shift] },
                { name: "ability",    label: "Ability",    group: "Combat",    slots: ["Primary"],            default: [ord("E")] },
        
                { name: "inventory",  label: "Inventory",  group: "Interface", slots: ["Primary"],            default: [vk_tab] }
            ];
        }
    }
}

function inputBindingFindDefinition(_action, _scheme)
{
    var _defs  = inputBindingActionDefinitions(_scheme);
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
    var _result  = {};
    var _schemes = inputControlSchemeList();
    var _count   = array_length(_schemes);

    for (var _i = 0; _i < _count; _i++)
    {
        var _scheme = _schemes[_i];
        var _key    = inputControlSchemeKey(_scheme);
        var _defs   = inputBindingActionDefinitions(_scheme);
        var _def_count = array_length(_defs);
        var _map    = {};

        for (var _d = 0; _d < _def_count; _d++)
        {
            var _def   = _defs[_d];
            var _array = inputArrayClone(_def.default);
            variable_struct_set(_map, _def.name, _array);
        }

        variable_struct_set(_result, _key, _map);
    }

    return _result;
}

function inputBindingsClone(_source)
{
    var _clone   = {};
    var _schemes = inputControlSchemeList();
    var _count   = array_length(_schemes);

    for (var _i = 0; _i < _count; _i++)
    {
        var _scheme = _schemes[_i];
        var _key    = inputControlSchemeKey(_scheme);
        var _defs   = inputBindingActionDefinitions(_scheme);
        var _map    = {};
        var _def_count = array_length(_defs);

        var _source_map = {};
        if (is_struct(_source) && variable_struct_exists(_source, _key))
        {
            _source_map = variable_struct_get(_source, _key);
        }

        for (var _d = 0; _d < _def_count; _d++)
        {
            var _def      = _defs[_d];
            var _defaults = _def.default;
            var _slots    = array_length(_defaults);
            var _array    = array_create(_slots);

            for (var _s = 0; _s < _slots; _s++)
            {
                var _value = undefined;
                if (is_struct(_source_map) && variable_struct_exists(_source_map, _def.name))
                {
                    var _src_array = variable_struct_get(_source_map, _def.name);
                    if (is_array(_src_array) && _s < array_length(_src_array))
                    {
                        var _candidate = _src_array[_s];
                        if (is_real(_candidate)) _value = _candidate;
                    }
                }

                if (!is_real(_value)) _value = _defaults[_s];
                _array[_s] = _value;
            }

            variable_struct_set(_map, _def.name, _array);
        }

        variable_struct_set(_clone, _key, _map);
    }

    return _clone;
}

function inputBindingsEnsureDefaults(_bindings)
{
    if (!is_struct(_bindings)) _bindings = {};

    var _schemes = inputControlSchemeList();
    var _count   = array_length(_schemes);

    for (var _i = 0; _i < _count; _i++)
    {
        var _scheme = _schemes[_i];
        _bindings = inputBindingsSchemeEnsureStruct(_bindings, _scheme);
    }

    return _bindings;
}

function inputBindingsEqual(_lhs, _rhs)
{
    var _left    = inputBindingsClone(_lhs);
    var _right   = inputBindingsClone(_rhs);
    var _schemes = inputControlSchemeList();
    var _count   = array_length(_schemes);

    for (var _i = 0; _i < _count; _i++)
    {
        var _scheme = _schemes[_i];
        var _key    = inputControlSchemeKey(_scheme);

        var _left_map  = variable_struct_get(_left,  _key);
        var _right_map = variable_struct_get(_right, _key);

        var _defs = inputBindingActionDefinitions(_scheme);
        var _def_count = array_length(_defs);

        for (var _d = 0; _d < _def_count; _d++)
        {
            var _def    = _defs[_d];
            var _left_a = variable_struct_get(_left_map,  _def.name);
            var _right_a= variable_struct_get(_right_map, _def.name);
            var _len    = array_length(_left_a);

            for (var _j = 0; _j < _len; _j++)
            {
                if (_left_a[_j] != _right_a[_j]) return false;
            }
        }
    }

    return true;
}
function inputControlSchemeGet() {
    return 
}
function inputBindingsGetKeys(_action, _scheme)
{
    global.Settings.key_bindings = inputCreateDefaultBindings();
    global.Settings.key_bindings = inputBindingsEnsureDefaults(global.Settings.key_bindings);

    var _key = inputControlSchemeKey(_scheme);
    if (!variable_struct_exists(global.Settings.key_bindings, _key)) return [];

    var _map = variable_struct_get(global.Settings.key_bindings, _key);
    if (!is_struct(_map)) return [];

    if (!variable_struct_exists(_map, _action)) return [];

    var _keys = variable_struct_get(_map, _action);
    if (!is_array(_keys)) return [];
    return _keys;
}

function inputBindingCheckHeld(_action, _scheme)
{
    var _keys  = inputBindingsGetKeys(_action, _scheme);
    var _count = array_length(_keys);
    for (var _i = 0; _i < _count; _i++)
    {
        var _key = _keys[_i];
        if (!is_real(_key)) continue;

        if (_scheme == ControlScheme.Controller)
        {
            var _pad = inputGamepadGetActive();
            if (inputGamepadButtonCheck(_pad, _key)) return true;
        }
        else
        {
            if (keyboard_check(_key)) return true;
        }
    }
    return false;
}

function inputBindingCheckPressed(_action, _scheme)
{
    var _keys  = inputBindingsGetKeys(_action, _scheme);
    var _count = array_length(_keys);
    for (var _i = 0; _i < _count; _i++)
    {
        var _key = _keys[_i];
        if (!is_real(_key)) continue;

        if (_scheme == ControlScheme.Controller)
        {
            var _pad = inputGamepadGetActive();
            if (inputGamepadButtonCheckPressed(_pad, _key)) return true;
        }
        else
        {
            if (keyboard_check_pressed(_key)) return true;
        }
    }
    return false;
}

/*
* Name: inputGetMove
* Description: Returns a normalised {dx, dy} from the configured movement bindings.
*/
function inputGetMove()
{
    var _scheme = inputControlSchemeGet();

    if (_scheme == ControlScheme.Controller) 
    {
        var _pad = inputGamepadGetActive();
        var _dx  = 0;
        var _dy  = 0;

        if (_pad != -1)
        {
            var _analog_x = gamepad_axis_value(_pad, gp_axislh);
            var _analog_y = gamepad_axis_value(_pad, gp_axislv);
            var _analog_len_sq = _analog_x * _analog_x + _analog_y * _analog_y;
            var _deadzone = 0.25;

            if (_analog_len_sq >= _deadzone * _deadzone)
            {
                _dx = _analog_x;
                _dy = _analog_y;
            }

            var _digital_dx = inputGamepadDigitalAxis(_pad, inputBindingsGetKeys("move_right", ControlScheme.Controller), inputBindingsGetKeys("move_left", ControlScheme.Controller));
            var _digital_dy = inputGamepadDigitalAxis(_pad, inputBindingsGetKeys("move_down",  ControlScheme.Controller), inputBindingsGetKeys("move_up",   ControlScheme.Controller));

            _dx += _digital_dx;
            _dy += _digital_dy;
        }

        if (_dx != 0 || _dy != 0)
        {
            var _norm_ctrl = vec2Norm(_dx, _dy);
            return { dx: _norm_ctrl[0], dy: _norm_ctrl[1] };
        }

        // Fallback: allow keyboard movement if controller is idle or absent
        _scheme = ControlScheme.KeyboardOnly;
    }

    var mv_dx = (inputBindingCheckHeld("move_right", _scheme) ? 1 : 0) - (inputBindingCheckHeld("move_left",  _scheme) ? 1 : 0);
    var mv_dy = (inputBindingCheckHeld("move_down",  _scheme) ? 1 : 0) - (inputBindingCheckHeld("move_up",    _scheme) ? 1 : 0);

    var n = vec2Norm(mv_dx, mv_dy);
    return { dx: n[0], dy: n[1] };
}

/*
* Name: inputGetAimHeld
* Description: Returns a normalised {dx, dy} vector from configured aim bindings.
*/
function inputGetAimHeld()
{
    var _scheme = inputControlSchemeGet();

    if (_scheme == ControlScheme.KeyboardMouse)
    {
        var _mx = device_mouse_x(0);
        var _my = device_mouse_y(0);
        var _dx = _mx - x;
        var _dy = _my - y;
        var _norm_mouse = vec2Norm(_dx, _dy);
        return { dx: _norm_mouse[0], dy: _norm_mouse[1] };
    }

    if (_scheme == ControlScheme.Controller)
    {
        var _pad = inputGamepadGetActive();
        var _dx  = 0;
        var _dy  = 0;

        if (_pad != -1)
        {
            var _analog_x = gamepad_axis_value(_pad, gp_axisrh);
            var _analog_y = gamepad_axis_value(_pad, gp_axisrv);
            var _analog_len_sq = _analog_x * _analog_x + _analog_y * _analog_y;
            var _deadzone = 0.25;

            if (_analog_len_sq >= _deadzone * _deadzone)
            {
                _dx = _analog_x;
                _dy = _analog_y;
            }
            else
            {
                var _digital_dx = inputGamepadDigitalAxis(_pad, inputBindingsGetKeys("aim_right", ControlScheme.Controller), inputBindingsGetKeys("aim_left", ControlScheme.Controller));
                var _digital_dy = inputGamepadDigitalAxis(_pad, inputBindingsGetKeys("aim_down",  ControlScheme.Controller), inputBindingsGetKeys("aim_up",   ControlScheme.Controller));
                _dx = _digital_dx;
                _dy = _digital_dy;
            }
        }

        if (_dx != 0 || _dy != 0)
        {
            var _norm_ctrl = vec2Norm(_dx, _dy);
            return { dx: _norm_ctrl[0], dy: _norm_ctrl[1] };
        }

        // Allow keyboard fallback when the stick is neutral
        _scheme = ControlScheme.KeyboardOnly;
    }

    var aim_dx = (inputBindingCheckHeld("aim_right", _scheme) ? 1 : 0) - (inputBindingCheckHeld("aim_left", _scheme) ? 1 : 0);
    var aim_dy = (inputBindingCheckHeld("aim_down",  _scheme) ? 1 : 0) - (inputBindingCheckHeld("aim_up",   _scheme) ? 1 : 0);
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
    var _scheme = inputControlSchemeGet();

    if (_scheme == ControlScheme.KeyboardMouse)
    {
        return { dx: 0, dy: 0 };
    }

    if (_scheme == ControlScheme.Controller)
    {
        if (inputBindingCheckPressed("aim_up", ControlScheme.Controller))    return { dx:  0, dy: -1 };
        if (inputBindingCheckPressed("aim_left", ControlScheme.Controller))  return { dx: -1, dy:  0 };
        if (inputBindingCheckPressed("aim_down", ControlScheme.Controller))  return { dx:  0, dy:  1 };
        if (inputBindingCheckPressed("aim_right", ControlScheme.Controller)) return { dx:  1, dy:  0 };

        _scheme = ControlScheme.KeyboardOnly;
    }

    if (inputBindingCheckPressed("aim_up", _scheme))    return { dx:  0, dy: -1 };
    if (inputBindingCheckPressed("aim_left", _scheme))  return { dx: -1, dy:  0 };
    if (inputBindingCheckPressed("aim_down", _scheme))  return { dx:  0, dy:  1 };
    if (inputBindingCheckPressed("aim_right", _scheme)) return { dx:  1, dy:  0 };
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
    var _scheme = inputControlSchemeGet();
    if (inputBindingCheckPressed("dash", _scheme)) return true;
    if (_scheme == ControlScheme.Controller) return inputBindingCheckPressed("dash", ControlScheme.KeyboardOnly);
    return false;
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
    var _scheme = inputControlSchemeGet();

    if (_scheme == ControlScheme.KeyboardMouse)
    {
        if (mouse_check_button_pressed(mb_left)) return true;
        return inputBindingCheckPressed("fire", ControlScheme.KeyboardMouse);
    }

    if (_scheme == ControlScheme.Controller)
    {
        if (inputBindingCheckPressed("fire", ControlScheme.Controller)) return true;
        return inputBindingCheckPressed("fire", ControlScheme.KeyboardOnly);
    }

    if (mouse_check_button_pressed(mb_left)) return true;
    return inputBindingCheckPressed("fire", ControlScheme.KeyboardOnly);
}

/*
* Name: inputFireHeld
* Description: True while primary fire is held AND input isn't locked.
*/
function inputFireHeld()
{
    var _locked = variable_instance_exists(id, "input_locked") && input_locked;
    if (_locked) return false;
    var _scheme = inputControlSchemeGet();

    if (_scheme == ControlScheme.KeyboardMouse)
    {
        if (mouse_check_button(mb_left)) return true;
        return inputBindingCheckHeld("fire", ControlScheme.KeyboardMouse);
    }

    if (_scheme == ControlScheme.Controller)
    {
        if (inputBindingCheckHeld("fire", ControlScheme.Controller)) return true;
        return inputBindingCheckHeld("fire", ControlScheme.KeyboardOnly);
    }

    if (mouse_check_button(mb_left)) return true;
    return inputBindingCheckHeld("fire", ControlScheme.KeyboardOnly);
}

/*
 * Name: inputMeleePressed
 * Description: True on the frame the melee binding is pressed while input is unlocked.
 */
function inputMeleePressed()
{
    var _locked = variable_instance_exists(id, "input_locked") && input_locked;
    if (_locked) return false;
    var _scheme = inputControlSchemeGet();
    if (inputBindingCheckPressed("melee", _scheme)) return true;
    if (_scheme == ControlScheme.Controller) return inputBindingCheckPressed("melee", ControlScheme.KeyboardOnly);
    return false;
}

/*
 * Name: inputAbilityPressed
 * Description: True on the frame the ability binding is pressed while input is unlocked.
 */
function inputAbilityPressed()
{
    var _locked = variable_instance_exists(id, "input_locked") && input_locked;
    if (_locked) return false;
    var _scheme = inputControlSchemeGet();
    if (inputBindingCheckPressed("ability", _scheme)) return true;
    if (_scheme == ControlScheme.Controller) return inputBindingCheckPressed("ability", ControlScheme.KeyboardOnly);
    return false;
}
