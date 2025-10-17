// ====================================================================
// Example: obj_player Step event (drop-in)
// ====================================================================

/*
* Name: obj_player.Step
* Description: Pause gate, input, dash, movement vs. tilemap, facing, firing.
*/

// ----- Early pause gate (safe no-op hook) -----
if (onPauseExit()) exit;

// Update damage cooldowns
if (damage_cd > 0) damage_cd -= 1;
if (flash_timer > 0) flash_timer -= 1;
if (hp <= 0) {
    dialogQueuePushQuestion("You died! Retry or quit?", function() { room_restart(); }, function() { game_end(); });
    instance_destroy();
    exit;
}

// ----- Gather input -----
var mv  = inputGetMove();            // {dx,dy} WASD / arrows
var aih = inputGetAimHeld();        // {dx,dy} IJKL held
var aip = inputGetAimPressed();     // {dx,dy} IJKL pressed this step
var want_dash   = inputDashPressed();  // Space
var fire_pressed = inputFirePressed();
var fire_held    = inputFireHeld();
var want_melee   = inputMeleePressed();
var want_ability = inputAbilityPressed();

// Ensure required instance fields exist
if (!variable_instance_exists(id, "tilemap_id"))      tilemap_id      = layer_tilemap_get_id("tm_collision");
if (!variable_instance_exists(id, "dash_active"))     dash_active     = false;
if (!variable_instance_exists(id, "dash_time"))       dash_time       = 0;
if (!variable_instance_exists(id, "dash_cooldown"))   dash_cooldown   = 0;
if (!variable_instance_exists(id, "dash_dx"))         dash_dx         = 0;
if (!variable_instance_exists(id, "dash_dy"))         dash_dy         = 0;
if (!variable_instance_exists(id, "facing_x"))        facing_x        = 1;
if (!variable_instance_exists(id, "facing_y"))        facing_y        = 0;
if (!variable_instance_exists(id, "move_speed"))      move_speed      = PLAYER_MOVE_SPEED;
if (!variable_instance_exists(id, "fire_cd"))         fire_cd         = 0;
if (!variable_instance_exists(id, "dash_distance_total")) dash_distance_total = PLAYER_DASH_DISTANCE;
if (!variable_instance_exists(id, "dash_duration_max"))   dash_duration_max   = PLAYER_DASH_TIME;
if (!variable_instance_exists(id, "dash_cooldown_max"))   dash_cooldown_max   = PLAYER_DASH_COOLDOWN;
if (!variable_instance_exists(id, "fire_speed"))        fire_speed        = PLAYER_FIRE_SPEED;
if (!variable_instance_exists(id, "fire_damage"))       fire_damage       = PLAYER_FIRE_DAMAGE;
if (!variable_instance_exists(id, "fire_cooldown"))       fire_cooldown       = PLAYER_FIRE_COOLDOWN;
if (!variable_instance_exists(id, "melee_cooldown"))      melee_cooldown      = 0;
if (!variable_instance_exists(id, "melee_cooldown_max"))  melee_cooldown_max  = PLAYER_MELEE_COOLDOWN;
if (!variable_instance_exists(id, "melee_range"))         melee_range         = PLAYER_MELEE_RANGE;
if (!variable_instance_exists(id, "melee_time"))          melee_time          = PLAYER_MELEE_TIME;
if (!variable_instance_exists(id, "melee_cost"))          melee_cost          = PLAYER_MELEE_ESSENCE_COST;
if (!variable_instance_exists(id, "ability_damage_timer"))        ability_damage_timer        = 0;
if (!variable_instance_exists(id, "ability_damage_cooldown"))     ability_damage_cooldown     = 0;
if (!variable_instance_exists(id, "ability_damage_duration"))     ability_damage_duration     = PLAYER_ABILITY_DURATION;
if (!variable_instance_exists(id, "ability_damage_cooldown_max")) ability_damage_cooldown_max = PLAYER_ABILITY_COOLDOWN;
if (!variable_instance_exists(id, "ability_damage_amount"))       ability_damage_amount       = PLAYER_ABILITY_DAMAGE_BONUS;
if (!variable_instance_exists(id, "ability_damage_cost"))         ability_damage_cost         = PLAYER_ABILITY_ESSENCE_COST;
if (!variable_instance_exists(id, "ability_damage_bonus"))        ability_damage_bonus        = 0;

playerAbilityStep(id);
playerMeleeStep(id);
if (want_ability)
{
    playerAbilityTryActivate(id);
}

playerStatsRecalculate(id);

// ----- Facing calculation -----
var new_face = keepLastNonzeroVec(aih.dx, aih.dy, facing_x, facing_y);
facing_x = new_face[0];
facing_y = new_face[1];
if (approxZero(facing_x, 0.00001) && approxZero(facing_y, 0.00001))
{
    // Fallback to movement direction if aim is zero and nothing remembered yet
    new_face = keepLastNonzeroVec(mv.dx, mv.dy, 1, 0);
    facing_x = new_face[0];
    facing_y = new_face[1];
}

var melee_face = keepLastNonzeroVec(aih.dx, aih.dy, facing_x, facing_y);
if (approxZero(melee_face[0], 0.00001) && approxZero(melee_face[1], 0.00001))
{
    melee_face = keepLastNonzeroVec(mv.dx, mv.dy, facing_x, facing_y);
}

if (want_melee)
{
    playerMeleeTryAttack(id, melee_face[0], melee_face[1]);
}

// ----- Sprite orientation -----
// The player sprite should remain upright regardless of WASD input.
// Remove rotation based on movement by keeping a constant angle.
image_angle = 0;

// ----- Dash -----
var dash_face = [facing_x, facing_y];
if (approxZero(dash_face[0], 0.00001) && approxZero(dash_face[1], 0.00001))
{
    var dash_fallback = keepLastNonzeroVec(mv.dx, mv.dy, 1, 0);
    dash_face[0] = dash_fallback[0];
    dash_face[1] = dash_fallback[1];
}

if (want_dash) 
{
    playerDashTryStart(id, dash_face[0], dash_face[1]);
}

var dash_state = playerDashStep(id);

var step_dx = 0;
var step_dy = 0;

if (dash_state.active)
{
    step_dx = dash_state.dx;
    step_dy = dash_state.dy;
}
else
{
    // Regular movement
    step_dx = mv.dx * move_speed;
    step_dy = mv.dy * move_speed;
}

// ----- Apply movement with tilemap collision -----
pMoveApply(id, step_dx, step_dy, tilemap_id, PLAYER_HITBOX_INSET);

// ----- Firing -----
weaponTickCooldown(id);

// (A) Immediate directional shot on I/J/K/L press
var shot_vec_x = aip.dx;
var shot_vec_y = aip.dy;

// (B) Autofire while held or alternate triggers (mouse/Ctrl) if aim is held
if ((approxZero(shot_vec_x, 0.00001) && approxZero(shot_vec_y, 0.00001)))
{
    if ((fire_pressed || (fire_held && fire_cd <= 0)) && (!approxZero(aih.dx, 0.00001) || !approxZero(aih.dy, 0.00001)))
    {
        shot_vec_x = aih.dx;
        shot_vec_y = aih.dy;
    }
}

// Fallback: allow firing in current facing if player clicks and no aim keys are held
if ((fire_pressed || (fire_held && fire_cd <= 0)) && approxZero(shot_vec_x, 0.00001) && approxZero(shot_vec_y, 0.00001))
{
    shot_vec_x = facing_x;
    shot_vec_y = facing_y;
}

if (!approxZero(shot_vec_x, 0.00001) || !approxZero(shot_vec_y, 0.00001))
{
    var spawn_off = 10; // offset so bullet doesn't collide with our own bbox
    var spawn_x = x + shot_vec_x * spawn_off;
    var spawn_y = y + shot_vec_y * spawn_off;

    weaponTryFire(id, spawn_x, spawn_y, shot_vec_x, shot_vec_y);
}
