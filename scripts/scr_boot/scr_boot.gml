/*
* Name: gameInit
* Description: One-time bootstrap for globals, layers, and runtime knobs. Safe to call once at game start.
*/
function gameInit()
{
    if (!variable_global_exists("gameState")) global.gameState = GameState.Playing;
        
    global.isPaused   = false; // start Paused
    global.invVisible = false; // inventory hidden by default
    global.menuVisible = true; // Start Menu

    if (!variable_global_exists("Settings"))
    {
        global.Settings = {
            master_volume:    1.0,
            screen_size_index:0,
            debug_god_mode:   false,
        };
    }
    else
    {
        if (!variable_struct_exists(global.Settings, "master_volume"))    global.Settings.master_volume    = 1.0;
        if (!variable_struct_exists(global.Settings, "screen_size_index")) global.Settings.screen_size_index = 0;
        if (!variable_struct_exists(global.Settings, "debug_god_mode"))    global.Settings.debug_god_mode   = false;
    }

    global.Settings.master_volume = clamp(global.Settings.master_volume, 0, 1);
    audio_master_gain(global.Settings.master_volume);
    recomputePauseState(); 
        
    // Create a single global namespace for the project
    if (!variable_global_exists("Game")) global.Game = {};
    var G = global.Game;

    // Basic runtime flags
    if (!variable_struct_exists(G, "paused"))      G.paused = false;
    if (!variable_struct_exists(G, "rng_seed"))    G.rng_seed = current_time;

    // Layer names centralised (uses your constants if defined)
    if (!variable_struct_exists(G, "layers"))
    {
        G.layers = {
            collide_layer_name: "Terrain_Collide",
            bullet_layer_name:  BULLET_LAYER_NAME
        };
    }

    // Cache the collision tilemap id if present (helps obj_player default)
    if (!variable_struct_exists(G, "tilemap_id"))
    {
        G.tilemap_id = -1;
        if (layer_exists(G.layers.collide_layer_name))
        {
            var tm = layer_tilemap_get_id(G.layers.collide_layer_name);
            if (tm != -1) G.tilemap_id = tm;
        }
    }

    // Randomise once at boot
    random_set_seed(G.rng_seed);
    randomize();

    // (Optional) Initialise subsystems if/when you add them; keep calls here:
    itemDbInit();
    // Allocate slots based on grid dimensions
    inventoryBoot(INV_COLS * INV_ROWS);
    inventoryUiBoot(32,32);// UI layout: each slot 32x32 px
    inventorySkinBoot();
    // e.g., audio_init(), etc.
    /*
    * Name: gameInit (dialog init)
    * Description: Initialise dialogue system and ensure a dialog renderer exists.
    */
    dialogInit();
    
    // Ensure a dialog drawer exists (place in a GUI/UI layer if you have one)
    if (!instance_exists(obj_dialog)) {
        var _ui_layer = layer_get_id("UI");
        if (_ui_layer == -1) _ui_layer = layer_create(100000, "UI"); // create GUI-ish foreground layer
        instance_create_layer(0, 0, "UI", obj_dialog);
    }
}

/*
* Name: gameShutdown
* Description: Cleanup hook for DS resources created during gameInit (currently a no-op).
*/
function gameShutdown()
{
    // Add DS map/list destroys here if you allocate them inside gameInit later.
}
