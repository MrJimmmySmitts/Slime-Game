// ====================================================================
// Name: scr_boot.gml 
// Description: Game Initialisation
// Author: James Smith
// ====================================================================

// ==================================================================== 
// Name: gameInit
// Description: One-time bootstrap for globals, layers, and runtime knobs.
// Usage: called once via "obj_game_controller_Create_0.gml"
// ====================================================================
function gameInit() {
    // Initialise state variables
    global.gameState = GameState.Playing;
    global.isPaused   = false; // Game pause state, default to paused
    global.invVisible = false; // inventory hidden by default
    global.menuVisible = true; // Start Menu
    recomputePauseState();
    // Global Settings subsystem
    global.Settings = {
        master_volume:        1.0,                              // Between 0.0 and 1.0
        screen_size_index:    0,                                
        debug_god_mode:       false,                            
        control_scheme:       ControlScheme.KeyboardMouse,      
    };

    // Set all the default key bindings (In future based on accessing a database of settings for permanent changes)
    global.Settings.key_bindings = inputCreateDefaultBindings();
    
    // Set master gain to default master volume
    audio_master_gain(global.Settings.master_volume);
    
    global.rng_seed = current_time
    randomize();

    // Initialise the inventory system
    itemDbInit();
    // Allocate slots based on grid dimensions
    inventoryBoot(INV_COLS * INV_ROWS);
    inventoryUiBoot(SPRITE_SIZE, SPRITE_SIZE);
    inventorySkinBoot();
    // Initialise Dialog system
    dialogInit();
}

// ==================================================================== 
// Name: gameShutdown
// Description: [UNUSED]
// ====================================================================
function gameShutdown()  {
    // Add DS map/list destroys here
}
