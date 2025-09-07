/*
* Name: game_init
* Description: One-time bootstrap for globals, layers, and runtime knobs. Safe to call once at game start.
*/
function game_init()
{
    if (!variable_global_exists("game_state")) global.game_state = GameState.Playing;
        
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
    item_db_init();
    inventory_boot(16);
    inventory_ui_boot(32,32);// UI layout: each slot 32x32 px
    inventory_skin_boot();
    // e.g., audio_init(), etc.
}

/*
* Name: game_shutdown
* Description: Cleanup hook for DS resources created during game_init (currently a no-op).
*/
function game_shutdown()
{
    // Add DS map/list destroys here if you allocate them inside game_init later.
}
