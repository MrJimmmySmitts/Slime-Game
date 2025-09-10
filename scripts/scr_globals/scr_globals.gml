// ====================================================================
// scr_globals.gml — core constants & knobs for "Plop"
// ====================================================================

/*
* Name: Inventory UI constants
* Description: Grid layout and padding used by inventory panel & hit testing.
*/
#macro INV_COLS         8        // number of columns in the grid
#macro INV_ROWS         8        // number of rows in the grid
#macro INV_SLOT_PAD     4        // pixels between slots
#macro INV_PANEL_MARGIN 12       // padding from screen edges

// Default key bindings for inventory navigation (can be remapped)
#macro INV_KEY_UP       ord("W")
#macro INV_KEY_DOWN     ord("S")
#macro INV_KEY_LEFT     ord("A")
#macro INV_KEY_RIGHT    ord("D")
#macro INV_KEY_SELECT   vk_enter

/*
* Name: InvAnchor
* Description: Anchor positions for inventory panel origin.
*/
enum InvAnchor
{
    Center     = 0,
    TopLeft    = 1,
    TopRight   = 2,
    BottomLeft = 3,
    BottomRight= 4
}

/*
* Name: INV_PANEL_ANCHOR
* Description: Default anchor for inventory panel.
*/
#macro INV_PANEL_ANCHOR InvAnchor.Center

/*
* Name: Globals (constants)
* Description: Central place for gameplay tunables. Keep values in one spot for consistency.
*/

#macro PLAYER_MOVE_SPEED     2.8
#macro PLAYER_DASH_DISTANCE  64      // pixels per full dash
#macro PLAYER_DASH_TIME      10      // steps
#macro PLAYER_DASH_COOLDOWN  30      // steps
#macro PLAYER_HITBOX_INSET   2       // for corner sampling vs tilemap

#macro BULLET_SPEED          8.0
#macro FIRE_COOLDOWN_STEPS   8       // autofire rate
#macro BULLET_LAYER_NAME     "Instances"   // change if your bullet layer differs

// Resolve at runtime by string to avoid hard compile errors on rename/missing
#macro OBJ_BULLET_NAME       "obj_bullet"
/*
* Name: GameState
* Description: Centralised game state enum for pause/menus/inventory.
*/
enum GameState
{
    Playing   = 0,
    Paused    = 1,
    Inventory = 2,
    Menu      = 3
}

/*
* Name: Inventory macros
* Description: Stable aliases so old code compiles while we migrate to global.Inventory.
*/
#macro INVENTORY_SLOTS  global.Inventory.slots
#macro INV_DRAG_STACK   global.Inventory.drag


