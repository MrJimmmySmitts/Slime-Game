// ====================================================================
// scr_globals.gml — Core Constants and Configurables
// Author: James Smith
// ====================================================================
// ====================================================================
// [UNSORTED AND DEPRECATED]
// ====================================================================
#macro INSTANCE_LAYER_NAME     "Instances"         // Layer name for spawned objects
#macro OBJ_BULLET_NAME       "obj_player_proj"     // Resolve at runtime by string to avoid hard compile errors on rename/missing
#macro INVENTORY_SLOTS  global.Inventory.slots     // [DEPRECATED]
#macro INV_DRAG_STACK   global.Inventory.drag      // [DEPRECATED]
#macro PLAYER_HITBOX_INSET    2


// ====================================================================
// Section: Inventory
// Description: Grid layout and padding used by inventory panel & hit testing.
// ====================================================================
#macro SPRITE_SIZE      32       // Default dimension for basic sprites and tiles (In Pixels)   
#macro INV_COLS         4        // number of columns in the grid
#macro INV_ROWS         4        // number of rows in the grid
#macro INV_SLOT_PAD     4        // pixels between slots
#macro INV_PANEL_MARGIN 12       // padding from screen edges
// ====================================================================
// Subsection: InvAnchor
// Description: Anchor positions for inventory panel origin.
// ====================================================================
enum InvAnchor
{
    Center     = 0,
    TopLeft    = 1,
    TopRight   = 2,
    BottomLeft = 3,
    BottomRight= 4
}
#macro INV_PANEL_ANCHOR InvAnchor.Center            // Default anchor for inventory panel.

// ====================================================================
// Section: Key Bindings
// Description: User configurable key bindings
// ====================================================================
// Subsection: Inventory Management
// Description: Keyboard control settings for Inventory
// ====================================================================
#macro INV_KEY_UP       ord("W")
#macro INV_KEY_DOWN     ord("S")
#macro INV_KEY_LEFT     ord("A")
#macro INV_KEY_RIGHT    ord("D")
#macro INV_KEY_SELECT   vk_enter

// ====================================================================
// Section: Player Stats
// Description: Configurable Settings for player
// ====================================================================
// Subsection: Basic
// ====================================================================
#macro PLAYER_HEALTH_MAX                          5        // Default number of fillable health containers
#macro PLAYER_HEALTH_ESSENCE                      10       // Default capacity of health containers
#macro PLAYER_HEALTH_DAMAGE_BONUS                 4        // Bonus damage per non-empty health container
#macro PLAYER_MOVE_SPEED                          3        // Movement is multiplied by this factor, 1.0 = (+/-)1 per step
// ====================================================================
// Subsection: Player Fire Projectile
// ====================================================================
#macro PLAYER_FIRE_COST           1              // Essence consumed per projectile
#macro PLAYER_FIRE_SPEED          8.0            // In pixels per step [???] 
#macro PLAYER_FIRE_COOLDOWN       4              // Steps before reactivation
#macro PLAYER_FIRE_DAMAGE         2              // Base damage of projectile
// ====================================================================
// Subsection: Dash
// ====================================================================
#macro PLAYER_DASH_DISTANCE  64              // In pixels
#macro PLAYER_DASH_TIME      10              // In steps
#macro PLAYER_DASH_COOLDOWN  30              // In steps
// ====================================================================
// Subsection: Melee Attack
// ====================================================================
#macro PLAYER_MELEE_RANGE            20      // spawn offset for melee slash
#macro PLAYER_MELEE_TIME             4       // lifetime of melee attack hitbox (In steps)
#macro PLAYER_MELEE_COOLDOWN         20      // Steps before melee can be used again
#macro PLAYER_MELEE_ESSENCE_COST     5       // Essence spent per melee strike
// ====================================================================
// Subsection: Player Special Ability
// ====================================================================
#macro PLAYER_ABILITY_TYPE           0       // [UNUSED] For future expansion of ability types (0 = Attack Boost)
#macro PLAYER_ABILITY_DAMAGE_BONUS   8       // Damage added for Attack Boost ability
#macro PLAYER_ABILITY_DURATION       240     // Steps ability is active
#macro PLAYER_ABILITY_COOLDOWN       600     // Steps for Cooldown
#macro PLAYER_ABILITY_ESSENCE_COST   10      // Essence cost of ability

// ====================================================================
// Section: Game State
// Description: Centralised game state enum for pause/menus/inventory.
// ====================================================================
enum GameState
{
    Playing   = 0,
    Paused    = 1,
    Inventory = 2,
    Menu      = 3
}