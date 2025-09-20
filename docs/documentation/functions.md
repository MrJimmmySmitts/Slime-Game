# Function Reference

## scr_boot

### gameInit
One-time bootstrap for globals, layers, and runtime knobs. Safe to call once at game start.
Related: [gameGetState](#gamegetstate), [gameIsPaused](#gameispaused), [gameSetState](#gamesetstate), [gameShutdown](#gameshutdown)

### gameShutdown
Initialise dialogue system and ensure a dialog renderer exists.
Related: [gameGetState](#gamegetstate), [gameInit](#gameinit), [gameIsPaused](#gameispaused), [gameSetState](#gamesetstate)

## scr_dash

### dashInit
Initialise dash state on the instance.
Related: [dashStep](#dashstep), [dashTryStart](#dashtrystart)

### dashStep
Advances dash motion/timers. Returns true if dashing this step.
Related: [dashInit](#dashinit), [dashTryStart](#dashtrystart)

### dashTryStart
Starts a dash in direction [fx, fy] if available.
Related: [dashInit](#dashinit), [dashStep](#dashstep)

## scr_dialog

### dialogDraw
Draw the dialogue box, text and buttons in GUI space.
Related: [dialogHide](#dialoghide), [dialogInit](#dialoginit), [dialogIsActive](#dialogisactive), [dialogQueuePush](#dialogqueuepush), [dialogQueuePushQuestion](#dialogqueuepushquestion), [dialogShowNext](#dialogshownext), [dialogStep](#dialogstep)

### dialogHide
Hide current dialogue and unpause (recompute). Also locks player input briefly to absorb the click.
Related: [dialogDraw](#dialogdraw), [dialogInit](#dialoginit), [dialogIsActive](#dialogisactive), [dialogQueuePush](#dialogqueuepush), [dialogQueuePushQuestion](#dialogqueuepushquestion), [dialogShowNext](#dialogshownext), [dialogStep](#dialogstep)

### dialogInit
Initialise global dialogue state and queue. Call at boot.
Related: [dialogDraw](#dialogdraw), [dialogHide](#dialoghide), [dialogIsActive](#dialogisactive), [dialogQueuePush](#dialogqueuepush), [dialogQueuePushQuestion](#dialogqueuepushquestion), [dialogShowNext](#dialogshownext), [dialogStep](#dialogstep)

### dialogIsActive
Returns true if a dialogue is currently visible.
Related: [dialogDraw](#dialogdraw), [dialogHide](#dialoghide), [dialogInit](#dialoginit), [dialogQueuePush](#dialogqueuepush), [dialogQueuePushQuestion](#dialogqueuepushquestion), [dialogShowNext](#dialogshownext), [dialogStep](#dialogstep)

### dialogQueuePush
Push a message onto the dialogue queue to be shown later.
Related: [dialogDraw](#dialogdraw), [dialogHide](#dialoghide), [dialogInit](#dialoginit), [dialogIsActive](#dialogisactive), [dialogQueuePushQuestion](#dialogqueuepushquestion), [dialogShowNext](#dialogshownext), [dialogStep](#dialogstep)

### dialogQueuePushQuestion
Queue a question dialog with Retry and Quit callbacks.
Related: [dialogDraw](#dialogdraw), [dialogHide](#dialoghide), [dialogInit](#dialoginit), [dialogIsActive](#dialogisactive), [dialogQueuePush](#dialogqueuepush), [dialogShowNext](#dialogshownext), [dialogStep](#dialogstep)

### dialogShowNext
Show the next message from the queue, pausing gameplay.
Related: [dialogDraw](#dialogdraw), [dialogHide](#dialoghide), [dialogInit](#dialoginit), [dialogIsActive](#dialogisactive), [dialogQueuePush](#dialogqueuepush), [dialogQueuePushQuestion](#dialogqueuepushquestion), [dialogStep](#dialogstep)

### dialogStep
Handle input for visible dialogues, including OK or Retry/Quit buttons.
Related: [dialogDraw](#dialogdraw), [dialogHide](#dialoghide), [dialogInit](#dialoginit), [dialogIsActive](#dialogisactive), [dialogQueuePush](#dialogqueuepush), [dialogQueuePushQuestion](#dialogqueuepushquestion), [dialogShowNext](#dialogshownext)

## scr_draw_inventory

### inv_get_slot_center
Returns { xx, yy } center coordinates for a slot index.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn)

### invDrawAll
Convenience: draw slot frames then items.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

### invDrawCursorStack
Draw the sprite for the currently dragged stack at the GUI mouse position.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

### invDrawItems
Draw item sprites in each occupied slot, scaled to fit while preserving aspect.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

### invDrawPanelBg
Draws a translucent backdrop behind the grid.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

### invDrawSlots
Draw slot frames using global.invSprSlot, scaled to slot size.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

### invDrawTooltip
Draws a simple tooltip with item name when hovering a non-empty slot.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

### invGuiMouse
Returns { x, y } mouse position in GUI coordinates (for Draw GUI).
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

### invHitTest
Returns slot index under the GUI mouse, or -1 if none.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

### invPanelGetOrigin
Returns { x, y } for the top-left of the inventory grid panel.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

### invPanelGetRect
Returns { l, t, r, b } rectangle of the grid in GUI space.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

## scr_enemy

### enemyBaseInit
Initialise defaults, collider, tilemap, and fractional move remainders.
Related: [enemyResolveTilemap](#enemyresolvetilemap), [enemySeekPlayerStep](#enemyseekplayerstep), [enemyUnstuckFromTilemap](#enemyunstuckfromtilemap)

### enemyResolveTilemap
Resolve the collision tilemap from the layer named "tm_collision".
Related: [enemyBaseInit](#enemybaseinit), [enemySeekPlayerStep](#enemyseekplayerstep), [enemyUnstuckFromTilemap](#enemyunstuckfromtilemap)

### enemySeekPlayerStep
Handle behaviour state transitions and chase the player when active.
Related: [enemyBaseInit](#enemybaseinit), [enemyResolveTilemap](#enemyresolvetilemap), [enemyUnstuckFromTilemap](#enemyunstuckfromtilemap)

### enemyUnstuckFromTilemap
If the collider overlaps the collision tilemap at the current position,
Related: [enemyBaseInit](#enemybaseinit), [enemyResolveTilemap](#enemyresolvetilemap), [enemySeekPlayerStep](#enemyseekplayerstep)

### moveAxisWithTilemap
Axis-separated movement with tilemap collision that supports fractional speeds

### tmRectHitsSolid
Check if any solid tile occupies rectangle (x,y,w,h) in tilemap coordinates.

## scr_input

### inputDashPressed
Returns true if Space is pressed this step.
Related: [inputFireHeld](#inputfireheld), [inputFirePressed](#inputfirepressed), [inputGetAimAxis](#inputgetaimaxis), [inputGetAimHeld](#inputgetaimheld), [inputGetAimPressed](#inputgetaimpressed), [inputGetMove](#inputgetmove)

### inputFireHeld
True while primary fire is held AND input isn't locked.
Related: [inputDashPressed](#inputdashpressed), [inputFirePressed](#inputfirepressed), [inputGetAimAxis](#inputgetaimaxis), [inputGetAimHeld](#inputgetaimheld), [inputGetAimPressed](#inputgetaimpressed), [inputGetMove](#inputgetmove)

### inputFirePressed
True on the frame primary fire is pressed AND input isn't locked.
Related: [inputDashPressed](#inputdashpressed), [inputFireHeld](#inputfireheld), [inputGetAimAxis](#inputgetaimaxis), [inputGetAimHeld](#inputgetaimheld), [inputGetAimPressed](#inputgetaimpressed), [inputGetMove](#inputgetmove)

### inputGetAimAxis
Returns a 2-element array [dx, dy] for current aim.
Related: [inputDashPressed](#inputdashpressed), [inputFireHeld](#inputfireheld), [inputFirePressed](#inputfirepressed), [inputGetAimHeld](#inputgetaimheld), [inputGetAimPressed](#inputgetaimpressed), [inputGetMove](#inputgetmove)

### inputGetAimHeld
Returns a normalised {dx, dy} vector from IJKL held down.
Related: [inputDashPressed](#inputdashpressed), [inputFireHeld](#inputfireheld), [inputFirePressed](#inputfirepressed), [inputGetAimAxis](#inputgetaimaxis), [inputGetAimPressed](#inputgetaimpressed), [inputGetMove](#inputgetmove)

### inputGetAimPressed
Returns a unit {dx, dy} for the *pressed this step* I/J/K/L key.
Related: [inputDashPressed](#inputdashpressed), [inputFireHeld](#inputfireheld), [inputFirePressed](#inputfirepressed), [inputGetAimAxis](#inputgetaimaxis), [inputGetAimHeld](#inputgetaimheld), [inputGetMove](#inputgetmove)

### inputGetMove
Returns a normalised {dx, dy} from WASD (and arrows as backup).
Related: [inputDashPressed](#inputdashpressed), [inputFireHeld](#inputfireheld), [inputFirePressed](#inputfirepressed), [inputGetAimAxis](#inputgetaimaxis), [inputGetAimHeld](#inputgetaimheld), [inputGetAimPressed](#inputgetaimpressed)

## scr_inventory

### invAddOrDrop
Add into INVENTORY_SLOTS or drop leftovers. Assumes inventoryBoot() already ran.
Related: [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center), [inventoryBoot](#inventoryboot)

### invDragActiveGet
Returns true if drag is flagged active; false if unset/not active.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

### invDragActiveSet
Sets the drag active flag, creating the field on first use.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

### invDragStackGet
Returns current dragged stack struct, or {id: ItemId.None, count: 0} if unset.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

### invDragStackSet
Sets the dragged stack, creating the field on first use.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

### invEmpty
Canonical empty stack value.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

### inventoryBoot
Builds the inventory subsystem once. Must be called from gameInit().
Related: [gameInit](#gameinit), [inventoryIsOpen](#inventoryisopen), [inventorySkinBoot](#inventoryskinboot), [inventoryUiBoot](#inventoryuiboot)

### inventorySkinBoot
Binds UI sprite assets to non-conflicting globals used by inventory drawers.
Related: [inventoryBoot](#inventoryboot), [inventoryIsOpen](#inventoryisopen), [inventoryUiBoot](#inventoryuiboot)

### inventoryUiBoot
Sets slot size and basic UI flags for the inventory. Call from gameInit().
Related: [gameInit](#gameinit), [inventoryBoot](#inventoryboot), [inventoryIsOpen](#inventoryisopen), [inventorySkinBoot](#inventoryskinboot)

### invHide
Hide inventory and recompute pause.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

### invShow
Show inventory and recompute pause.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

### invToggle
Toggle inventory UI and pause state.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

### invTryAddSimple
Fill existing stacks, then empty slots. Returns remaining count.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

### invWorldDropSpawn
Spawn a world pickup for leftovers.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [inv_get_slot_center](#inv_get_slot_center)

## scr_items

### invApplyMerge
Applies a merge using a rule; returns { dst_after, src_after } or undefined if it cannot fit.
Related: [invAddOrDrop](#invaddordrop), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

### invCanMerge
Returns a normalized merge rule (or undefined) for two stacks using itemMergeRuleLookup.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invTryMergeDragIntoSlot](#invtrymergedragintoslot), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center), [itemMergeRuleLookup](#itemmergerulelookup)

### invTryMergeDragIntoSlot
Attempts to merge the globally dragged stack into a given slot index.
Related: [invAddOrDrop](#invaddordrop), [invApplyMerge](#invapplymerge), [invCanMerge](#invcanmerge), [invDragActiveGet](#invdragactiveget), [invDragActiveSet](#invdragactiveset), [invDragStackGet](#invdragstackget), [invDragStackSet](#invdragstackset), [invDrawAll](#invdrawall), [invDrawCursorStack](#invdrawcursorstack), [invDrawItems](#invdrawitems), [invDrawPanelBg](#invdrawpanelbg), [invDrawSlots](#invdrawslots), [invDrawTooltip](#invdrawtooltip), [invEmpty](#invempty), [invGuiMouse](#invguimouse), [invHide](#invhide), [invHitTest](#invhittest), [invPanelGetOrigin](#invpanelgetorigin), [invPanelGetRect](#invpanelgetrect), [invShow](#invshow), [invToggle](#invtoggle), [invTryAddSimple](#invtryaddsimple), [invWorldDropSpawn](#invworlddropspawn), [inv_get_slot_center](#inv_get_slot_center)

### itemCoalesce
Returns _id if valid; otherwise ItemId.None.
Related: [itemDbGet](#itemdbget), [itemDbInit](#itemdbinit), [itemDbPut](#itemdbput), [itemGetDef](#itemgetdef), [itemGetMaxStack](#itemgetmaxstack), [itemGetName](#itemgetname), [itemGetSprite](#itemgetsprite), [itemIsValid](#itemisvalid), [itemMergeRuleLookup](#itemmergerulelookup)

### itemDbGet
Alias to itemGetDef for compatibility with older naming.
Related: [itemCoalesce](#itemcoalesce), [itemDbInit](#itemdbinit), [itemDbPut](#itemdbput), [itemGetDef](#itemgetdef), [itemGetMaxStack](#itemgetmaxstack), [itemGetName](#itemgetname), [itemGetSprite](#itemgetsprite), [itemIsValid](#itemisvalid), [itemMergeRuleLookup](#itemmergerulelookup)

### itemDbInit
Builds the item database with stack caps and data-driven merge rules.
Related: [itemCoalesce](#itemcoalesce), [itemDbGet](#itemdbget), [itemDbPut](#itemdbput), [itemGetDef](#itemgetdef), [itemGetMaxStack](#itemgetmaxstack), [itemGetName](#itemgetname), [itemGetSprite](#itemgetsprite), [itemIsValid](#itemisvalid), [itemMergeRuleLookup](#itemmergerulelookup)

### itemDbPut
Stable compile-time item identifiers used across the project.
Related: [itemCoalesce](#itemcoalesce), [itemDbGet](#itemdbget), [itemDbInit](#itemdbinit), [itemGetDef](#itemgetdef), [itemGetMaxStack](#itemgetmaxstack), [itemGetName](#itemgetname), [itemGetSprite](#itemgetsprite), [itemIsValid](#itemisvalid), [itemMergeRuleLookup](#itemmergerulelookup)

### itemGetDef
Returns the item definition struct for a given id, or undefined.
Related: [itemCoalesce](#itemcoalesce), [itemDbGet](#itemdbget), [itemDbInit](#itemdbinit), [itemDbPut](#itemdbput), [itemGetMaxStack](#itemgetmaxstack), [itemGetName](#itemgetname), [itemGetSprite](#itemgetsprite), [itemIsValid](#itemisvalid), [itemMergeRuleLookup](#itemmergerulelookup)

### itemGetMaxStack
Returns the stack cap for the given item id from the item DB. Defaults to 1; "None" stays 0.
Related: [itemCoalesce](#itemcoalesce), [itemDbGet](#itemdbget), [itemDbInit](#itemdbinit), [itemDbPut](#itemdbput), [itemGetDef](#itemgetdef), [itemGetName](#itemgetname), [itemGetSprite](#itemgetsprite), [itemIsValid](#itemisvalid), [itemMergeRuleLookup](#itemmergerulelookup)

### itemGetName
Convenience: returns display name for item_id, or "Unknown".
Related: [itemCoalesce](#itemcoalesce), [itemDbGet](#itemdbget), [itemDbInit](#itemdbinit), [itemDbPut](#itemdbput), [itemGetDef](#itemgetdef), [itemGetMaxStack](#itemgetmaxstack), [itemGetSprite](#itemgetsprite), [itemIsValid](#itemisvalid), [itemMergeRuleLookup](#itemmergerulelookup)

### itemGetSprite
Returns the icon sprite for the given item id from the DB, or `noone` if unknown.
Related: [itemCoalesce](#itemcoalesce), [itemDbGet](#itemdbget), [itemDbInit](#itemdbinit), [itemDbPut](#itemdbput), [itemGetDef](#itemgetdef), [itemGetMaxStack](#itemgetmaxstack), [itemGetName](#itemgetname), [itemIsValid](#itemisvalid), [itemMergeRuleLookup](#itemmergerulelookup)

### itemIsValid
True if the id exists in the DB.
Related: [itemCoalesce](#itemcoalesce), [itemDbGet](#itemdbget), [itemDbInit](#itemdbinit), [itemDbPut](#itemdbput), [itemGetDef](#itemgetdef), [itemGetMaxStack](#itemgetmaxstack), [itemGetName](#itemgetname), [itemGetSprite](#itemgetsprite), [itemMergeRuleLookup](#itemmergerulelookup)

### itemMergeRuleLookup
Finds a merge rule for A+B. Checks A’s rules for B, then B’s rules for A (swapping costs).
Related: [itemCoalesce](#itemcoalesce), [itemDbGet](#itemdbget), [itemDbInit](#itemdbinit), [itemDbPut](#itemdbput), [itemGetDef](#itemgetdef), [itemGetMaxStack](#itemgetmaxstack), [itemGetName](#itemgetname), [itemGetSprite](#itemgetsprite), [itemIsValid](#itemisvalid)

### ruleMake
Convenience constructor for a single merge rule entry (A + with_id -> result).

## scr_menu

### menuActivateSelection
Perform the currently selected action (same as pressing Enter).
Related: [menuGetLayout](#menugetlayout), [menuHide](#menuhide), [menuIndexAt](#menuindexat), [menuItemBounds](#menuitembounds), [menuMouseUpdate](#menumouseupdate), [menuShow](#menushow), [menuToggle](#menutoggle)

### menuGetLayout
Return menu layout in GUI space for hit-testing and drawing.
Related: [menuActivateSelection](#menuactivateselection), [menuHide](#menuhide), [menuIndexAt](#menuindexat), [menuItemBounds](#menuitembounds), [menuMouseUpdate](#menumouseupdate), [menuShow](#menushow), [menuToggle](#menutoggle)

### menuIndexAt
Menu index under the GUI-space point, or -1 if none.
Related: [menuActivateSelection](#menuactivateselection), [menuGetLayout](#menugetlayout), [menuHide](#menuhide), [menuItemBounds](#menuitembounds), [menuMouseUpdate](#menumouseupdate), [menuShow](#menushow), [menuToggle](#menutoggle)

### menuItemBounds
Clickable rect for item index (GUI space) → [left, top, right, bottom].
Related: [menuActivateSelection](#menuactivateselection), [menuGetLayout](#menugetlayout), [menuHide](#menuhide), [menuIndexAt](#menuindexat), [menuMouseUpdate](#menumouseupdate), [menuShow](#menushow), [menuToggle](#menutoggle)

### menuMouseUpdate
When menu is visible, hover to select and click (LMB) to activate.
Related: [menuActivateSelection](#menuactivateselection), [menuGetLayout](#menugetlayout), [menuHide](#menuhide), [menuIndexAt](#menuindexat), [menuItemBounds](#menuitembounds), [menuShow](#menushow), [menuToggle](#menutoggle)

## scr_pmove

### pmoveApply
Applies movement (dx,dy) with collision on a collision tilemap layer.
Related: [pmoveMoveAxis](#pmovemoveaxis), [pmovePlaceMeetingTilemap](#pmoveplacemeetingtilemap)

### pmoveMoveAxis
Moves instance along one axis with pixel sweep to avoid tunnelling on tiles.
Related: [pmoveApply](#pmoveapply), [pmovePlaceMeetingTilemap](#pmoveplacemeetingtilemap)

### pmovePlaceMeetingTilemap
Checks if bbox of the instance at (test_x, test_y) overlaps any solid tiles.
Related: [pmoveApply](#pmoveapply), [pmoveMoveAxis](#pmovemoveaxis)

### tilemapSolidAt
Returns true if the given tilemap id has a non-empty tile at (px, py).

## scr_room_generation

### dgAssignTemplates
Assigns templates to nodes based on exits.
Related: [dgBuildFloorIntoRoom](#dgbuildfloorintoroom), [dgConfigDefault](#dgconfigdefault), [dgGenerateFloor](#dggeneratefloor), [dgGraphAddNode](#dggraphaddnode), [dgGraphKey](#dggraphkey), [dgGraphNeighbors4](#dggraphneighbors4), [dgLayerRequire](#dglayerrequire), [dgLayoutBuild](#dglayoutbuild), [dgRngInit](#dgrnginit), [dgRoomTemplateNew](#dgroomtemplatenew), [dgRoomdbBuildExamples](#dgroomdbbuildexamples), [dgTemplateMatches](#dgtemplatematches), [dgTilePaintRoom](#dgtilepaintroom)

### dgBuildFloorIntoRoom
Clears + paints all rooms into layers.
Related: [dgAssignTemplates](#dgassigntemplates), [dgConfigDefault](#dgconfigdefault), [dgGenerateFloor](#dggeneratefloor), [dgGraphAddNode](#dggraphaddnode), [dgGraphKey](#dggraphkey), [dgGraphNeighbors4](#dggraphneighbors4), [dgLayerRequire](#dglayerrequire), [dgLayoutBuild](#dglayoutbuild), [dgRngInit](#dgrnginit), [dgRoomTemplateNew](#dgroomtemplatenew), [dgRoomdbBuildExamples](#dgroomdbbuildexamples), [dgTemplateMatches](#dgtemplatematches), [dgTilePaintRoom](#dgtilepaintroom)

### dgConfigDefault
Returns a struct with default generator settings.
Related: [dgAssignTemplates](#dgassigntemplates), [dgBuildFloorIntoRoom](#dgbuildfloorintoroom), [dgGenerateFloor](#dggeneratefloor), [dgGraphAddNode](#dggraphaddnode), [dgGraphKey](#dggraphkey), [dgGraphNeighbors4](#dggraphneighbors4), [dgLayerRequire](#dglayerrequire), [dgLayoutBuild](#dglayoutbuild), [dgRngInit](#dgrnginit), [dgRoomTemplateNew](#dgroomtemplatenew), [dgRoomdbBuildExamples](#dgroomdbbuildexamples), [dgTemplateMatches](#dgtemplatematches), [dgTilePaintRoom](#dgtilepaintroom)

### dgGenerateFloor
Master function to build a floor.
Related: [dgAssignTemplates](#dgassigntemplates), [dgBuildFloorIntoRoom](#dgbuildfloorintoroom), [dgConfigDefault](#dgconfigdefault), [dgGraphAddNode](#dggraphaddnode), [dgGraphKey](#dggraphkey), [dgGraphNeighbors4](#dggraphneighbors4), [dgLayerRequire](#dglayerrequire), [dgLayoutBuild](#dglayoutbuild), [dgRngInit](#dgrnginit), [dgRoomTemplateNew](#dgroomtemplatenew), [dgRoomdbBuildExamples](#dgroomdbbuildexamples), [dgTemplateMatches](#dgtemplatematches), [dgTilePaintRoom](#dgtilepaintroom)

### dgGraphAddNode
Adds node to graph.
Related: [dgAssignTemplates](#dgassigntemplates), [dgBuildFloorIntoRoom](#dgbuildfloorintoroom), [dgConfigDefault](#dgconfigdefault), [dgGenerateFloor](#dggeneratefloor), [dgGraphKey](#dggraphkey), [dgGraphNeighbors4](#dggraphneighbors4), [dgLayerRequire](#dglayerrequire), [dgLayoutBuild](#dglayoutbuild), [dgRngInit](#dgrnginit), [dgRoomTemplateNew](#dgroomtemplatenew), [dgRoomdbBuildExamples](#dgroomdbbuildexamples), [dgTemplateMatches](#dgtemplatematches), [dgTilePaintRoom](#dgtilepaintroom)

### dgGraphKey
Converts grid coords to a unique key.
Related: [dgAssignTemplates](#dgassigntemplates), [dgBuildFloorIntoRoom](#dgbuildfloorintoroom), [dgConfigDefault](#dgconfigdefault), [dgGenerateFloor](#dggeneratefloor), [dgGraphAddNode](#dggraphaddnode), [dgGraphNeighbors4](#dggraphneighbors4), [dgLayerRequire](#dglayerrequire), [dgLayoutBuild](#dglayoutbuild), [dgRngInit](#dgrnginit), [dgRoomTemplateNew](#dgroomtemplatenew), [dgRoomdbBuildExamples](#dgroomdbbuildexamples), [dgTemplateMatches](#dgtemplatematches), [dgTilePaintRoom](#dgtilepaintroom)

### dgGraphNeighbors4
NESW neighbor offsets.
Related: [dgAssignTemplates](#dgassigntemplates), [dgBuildFloorIntoRoom](#dgbuildfloorintoroom), [dgConfigDefault](#dgconfigdefault), [dgGenerateFloor](#dggeneratefloor), [dgGraphAddNode](#dggraphaddnode), [dgGraphKey](#dggraphkey), [dgLayerRequire](#dglayerrequire), [dgLayoutBuild](#dglayoutbuild), [dgRngInit](#dgrnginit), [dgRoomTemplateNew](#dgroomtemplatenew), [dgRoomdbBuildExamples](#dgroomdbbuildexamples), [dgTemplateMatches](#dgtemplatematches), [dgTilePaintRoom](#dgtilepaintroom)

### dgLayerRequire
Ensures tile layer exists.
Related: [dgAssignTemplates](#dgassigntemplates), [dgBuildFloorIntoRoom](#dgbuildfloorintoroom), [dgConfigDefault](#dgconfigdefault), [dgGenerateFloor](#dggeneratefloor), [dgGraphAddNode](#dggraphaddnode), [dgGraphKey](#dggraphkey), [dgGraphNeighbors4](#dggraphneighbors4), [dgLayoutBuild](#dglayoutbuild), [dgRngInit](#dgrnginit), [dgRoomTemplateNew](#dgroomtemplatenew), [dgRoomdbBuildExamples](#dgroomdbbuildexamples), [dgTemplateMatches](#dgtemplatematches), [dgTilePaintRoom](#dgtilepaintroom)

### dgLayoutBuild
Builds a connected layout graph.
Related: [dgAssignTemplates](#dgassigntemplates), [dgBuildFloorIntoRoom](#dgbuildfloorintoroom), [dgConfigDefault](#dgconfigdefault), [dgGenerateFloor](#dggeneratefloor), [dgGraphAddNode](#dggraphaddnode), [dgGraphKey](#dggraphkey), [dgGraphNeighbors4](#dggraphneighbors4), [dgLayerRequire](#dglayerrequire), [dgRngInit](#dgrnginit), [dgRoomTemplateNew](#dgroomtemplatenew), [dgRoomdbBuildExamples](#dgroomdbbuildexamples), [dgTemplateMatches](#dgtemplatematches), [dgTilePaintRoom](#dgtilepaintroom)

### dgRngInit
Initializes RNG based on config seed.
Related: [dgAssignTemplates](#dgassigntemplates), [dgBuildFloorIntoRoom](#dgbuildfloorintoroom), [dgConfigDefault](#dgconfigdefault), [dgGenerateFloor](#dggeneratefloor), [dgGraphAddNode](#dggraphaddnode), [dgGraphKey](#dggraphkey), [dgGraphNeighbors4](#dggraphneighbors4), [dgLayerRequire](#dglayerrequire), [dgLayoutBuild](#dglayoutbuild), [dgRoomTemplateNew](#dgroomtemplatenew), [dgRoomdbBuildExamples](#dgroomdbbuildexamples), [dgTemplateMatches](#dgtemplatematches), [dgTilePaintRoom](#dgtilepaintroom)

### dgRoomdbBuildExamples
Returns a small set of example room templates.
Related: [dgAssignTemplates](#dgassigntemplates), [dgBuildFloorIntoRoom](#dgbuildfloorintoroom), [dgConfigDefault](#dgconfigdefault), [dgGenerateFloor](#dggeneratefloor), [dgGraphAddNode](#dggraphaddnode), [dgGraphKey](#dggraphkey), [dgGraphNeighbors4](#dggraphneighbors4), [dgLayerRequire](#dglayerrequire), [dgLayoutBuild](#dglayoutbuild), [dgRngInit](#dgrnginit), [dgRoomTemplateNew](#dgroomtemplatenew), [dgTemplateMatches](#dgtemplatematches), [dgTilePaintRoom](#dgtilepaintroom)

### dgRoomTemplateNew
Creates a room template with exits + tile arrays.
Related: [dgAssignTemplates](#dgassigntemplates), [dgBuildFloorIntoRoom](#dgbuildfloorintoroom), [dgConfigDefault](#dgconfigdefault), [dgGenerateFloor](#dggeneratefloor), [dgGraphAddNode](#dggraphaddnode), [dgGraphKey](#dggraphkey), [dgGraphNeighbors4](#dggraphneighbors4), [dgLayerRequire](#dglayerrequire), [dgLayoutBuild](#dglayoutbuild), [dgRngInit](#dgrnginit), [dgRoomdbBuildExamples](#dgroomdbbuildexamples), [dgTemplateMatches](#dgtemplatematches), [dgTilePaintRoom](#dgtilepaintroom)

### dgTemplateMatches
Checks if template exits match needs.
Related: [dgAssignTemplates](#dgassigntemplates), [dgBuildFloorIntoRoom](#dgbuildfloorintoroom), [dgConfigDefault](#dgconfigdefault), [dgGenerateFloor](#dggeneratefloor), [dgGraphAddNode](#dggraphaddnode), [dgGraphKey](#dggraphkey), [dgGraphNeighbors4](#dggraphneighbors4), [dgLayerRequire](#dglayerrequire), [dgLayoutBuild](#dglayoutbuild), [dgRngInit](#dgrnginit), [dgRoomTemplateNew](#dgroomtemplatenew), [dgRoomdbBuildExamples](#dgroomdbbuildexamples), [dgTilePaintRoom](#dgtilepaintroom)

### dgTilePaintRoom
Paints a template into tilemaps.
Related: [dgAssignTemplates](#dgassigntemplates), [dgBuildFloorIntoRoom](#dgbuildfloorintoroom), [dgConfigDefault](#dgconfigdefault), [dgGenerateFloor](#dggeneratefloor), [dgGraphAddNode](#dggraphaddnode), [dgGraphKey](#dggraphkey), [dgGraphNeighbors4](#dggraphneighbors4), [dgLayerRequire](#dglayerrequire), [dgLayoutBuild](#dglayoutbuild), [dgRngInit](#dgrnginit), [dgRoomTemplateNew](#dgroomtemplatenew), [dgRoomdbBuildExamples](#dgroomdbbuildexamples), [dgTemplateMatches](#dgtemplatematches)

## scr_utils

### approxZero
Returns true if |v| <= eps.

### clampf
Clamp a value to [a,b] as float.

### gameGetState
Returns current game state; defaults safely to Playing.
Related: [gameInit](#gameinit), [gameIsPaused](#gameispaused), [gameSetState](#gamesetstate), [gameShutdown](#gameshutdown)

### gameIsPaused
True if gameplay should halt (Paused or Inventory).
Related: [gameGetState](#gamegetstate), [gameInit](#gameinit), [gameSetState](#gamesetstate), [gameShutdown](#gameshutdown)

### gameSetState
Sets the current game state.
Related: [gameGetState](#gamegetstate), [gameInit](#gameinit), [gameIsPaused](#gameispaused), [gameShutdown](#gameshutdown)

### inventoryIsOpen
Returns true if the global game state is Inventory.
Related: [inventoryBoot](#inventoryboot), [inventorySkinBoot](#inventoryskinboot), [inventoryUiBoot](#inventoryuiboot)

### keepLastNonzeroVec
If (vx,vy) != (0,0) returns it; otherwise returns last stored pair.

### menuHide
Hide pause menu and recompute pause.
Related: [menuActivateSelection](#menuactivateselection), [menuGetLayout](#menugetlayout), [menuIndexAt](#menuindexat), [menuItemBounds](#menuitembounds), [menuMouseUpdate](#menumouseupdate), [menuShow](#menushow), [menuToggle](#menutoggle)

### menuShow
Show pause menu and recompute pause.
Related: [menuActivateSelection](#menuactivateselection), [menuGetLayout](#menugetlayout), [menuHide](#menuhide), [menuIndexAt](#menuindexat), [menuItemBounds](#menuitembounds), [menuMouseUpdate](#menumouseupdate), [menuToggle](#menutoggle)

### menuToggle
Toggle pause menu and recompute pause.
Related: [menuActivateSelection](#menuactivateselection), [menuGetLayout](#menugetlayout), [menuHide](#menuhide), [menuIndexAt](#menuindexat), [menuItemBounds](#menuitembounds), [menuMouseUpdate](#menumouseupdate), [menuShow](#menushow)

### onPauseExit
Return true when the game is paused so callers can early-exit Step.

### recomputePauseState
Recompute global pause from inventory/menu/dialogue visibility.

### signNonzero
Returns sign(v) but treats 0 as 0.

### vec2Len
Returns Euclidean length of (vx, vy).
Related: [vec2Norm](#vec2norm)

### vec2Norm
Normalises (vx, vy); returns (nx, ny). If zero, returns (0,0).
Related: [vec2Len](#vec2len)

## scr_weapon

### weaponTickCooldown
Decrements fire cooldown on an instance if present.
Related: [weaponTryFire](#weapontryfire)

### weaponTryFire
Spawns a bullet if cooldown is ready and aim vector is valid.
Related: [weaponTickCooldown](#weapontickcooldown)
