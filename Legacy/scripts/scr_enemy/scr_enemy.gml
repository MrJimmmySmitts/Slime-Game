// ====================================================================
// Name: scr_enemy
// Description: Enemy behaviours and configuration
// ====================================================================

// ====================================================================
// Name: EnemyState
// Description: Enemy behaviour state machine values.
// ====================================================================
enum EnemyState {
    Idle   = 0,
    Active = 1,
    Melee = 2,
}
// ====================================================================
// Name: EnemyType
// Description: Enumerations for enemy behaviour archetypes.
// ====================================================================
enum EnemyType {
    Melee  = 0,
    Ranged = 1,
}
// ====================================================================
// Name: EnemyToughness
// Description: Enumerations for scaling health/damage tiers.
// ====================================================================
enum EnemyToughness {
    Normal = 0,
    Elite  = 1,
    Boss   = 2,
}

// ====================================================================
// Name: Enemy configuration macros
// Description: Centralised tuning values for each enemy archetype and toughness scaling.
// ====================================================================
// Subsection: General
// ====================================================================
#macro ENEMY_IDLE_PAUSE_MIN           18
#macro ENEMY_IDLE_PAUSE_MAX           54
#macro ENEMY_IDLE_TOLERANCE           4        // pixels before considering wander target reached
// ====================================================================
// Subsection: Melee Enemy
// ====================================================================
#macro ENEMY_MELEE_ATTACK_SPRITE_NAME "spr_attack"
#macro ENEMY_MELEE_HP                 5
#macro ENEMY_MELEE_MOVE_SPEED         2
#macro ENEMY_MELEE_ATTACK_COOLDOWN    50
#macro ENEMY_MELEE_ATTACK_DAMAGE      10
// ====================================================================
// Subsection: Ranged Enemy
// ====================================================================
#macro ENEMY_RANGED_HP                   5
#macro ENEMY_RANGED_MOVE_SPEED           2
#macro ENEMY_RANGED_IDLE_SPEED           1.1
#macro ENEMY_RANGED_PROJECTILE_COOLDOWN  50
#macro ENEMY_RANGED_PROJECTILE_SPEED     4
#macro ENEMY_RANGED_PROJECTILE_DAMAGE    5
// ====================================================================
// Subsection: Toughness Modifiers
// ====================================================================
#macro ENEMY_HP_NORMAL      1.0
#macro ENEMY_HP_ELITE       1.6
#macro ENEMY_HP_BOSS        2.5
#macro ENEMY_DAMAGE_NORMAL  1.0
#macro ENEMY_DAMAGE_ELITE   1.35
#macro ENEMY_DAMAGE_BOSS    1.75

// ====================================================================
// Name: enemyConfigBaseStats
// Description: Returns a struct describing base stats for the requested enemy type.
// ====================================================================
function enemyConfigBaseStats(_type) {
    switch (_type) {
        case EnemyType.Ranged:
            return {
                hp                    : ENEMY_RANGED_HP,
                move_speed            : ENEMY_RANGED_MOVE_SPEED,
                projectile_cooldown   : ENEMY_RANGED_PROJECTILE_COOLDOWN,
                projectile_speed      : ENEMY_RANGED_PROJECTILE_SPEED,
                projectile_damage     : ENEMY_RANGED_PROJECTILE_DAMAGE,
            };
        case EnemyType.Melee:
        default:
            return {
                hp                    : ENEMY_MELEE_HP,
                move_speed            : ENEMY_MELEE_MOVE_SPEED,
                melee_cooldown        : ENEMY_MELEE_ATTACK_COOLDOWN,
                melee_damage          : ENEMY_MELEE_ATTACK_DAMAGE,
            };
    }
}

// ====================================================================
// Name: enemyConfigToughnessHpMultiplier
// Description: Adjust stats for toughness
// ====================================================================
function enemyAdjustHP(_toughness) {
    switch (_toughness) {
        case EnemyToughness.Elite: return ENEMY_HP_ELITE;
        case EnemyToughness.Boss:  return ENEMY_HP_BOSS;
        default:                   return ENEMY_HP_NORMAL;
    }
}

/*
* Name: enemyConfigToughnessDamageMultiplier
* Description: Scale factor applied to outgoing damage per toughness tier.
*/
function enemyAdjustDamage(_toughness) {
    switch (_toughness) {
        case EnemyToughness.Elite: return ENEMY_DAMAGE_ELITE;
        case EnemyToughness.Boss:  return ENEMY_DAMAGE_BOSS;
        default:                   return ENEMY_DAMAGE_NORMAL;
    }
}

// ====================================================================
// Name: enemyInit
// Description: Initialise defaults, collider, tilemap, and behavioural timers.
// ====================================================================
function enemyInit(_stats, _type) {
    enemyResolveTilemap();
    _stats = enemyConfigBaseStats(_type);
    
    enemy_flash_duration     = 2;
    enemy_stun_duration      = 2;
    enemy_flash_timer        = 0;
    enemy_stun_timer         = 0;
    hp_max                   = ENEMY_MELEE_HP;
    hp                       = hp_max;
    is_dead                  = false;


    // subpixel accumulators (so speeds < 1 still move)
    enemy_move_rx = 0;
    enemy_move_ry = 0;
}
// ====================================================================
// Name: enemySetIdle
// Description: Reset behaviour state to idle and clear movement remainders/target.
// ====================================================================
function enemySetIdle() {
    enemy_state                    = EnemyState.Idle;
    target                         = noone;
    enemy_behavior_delay_timer     = 0;
    enemy_idle_has_target          = false;
    enemy_idle_pause_timer         = irandom_range(enemy_idle_pause_min, enemy_idle_pause_max);
    
    // subpixel accumulators (so speeds < 1 still move)
    enemy_move_rx                  = 0;
    enemy_move_ry                  = 0;
}

// ====================================================================
// Name: enemySetActive
// Description: Activate the enemy and assign a chase target (defaults to nearest player).
// ====================================================================
function enemySetActive(_target) {
    enemy_state               = EnemyState.Active;
    enemy_idle_has_target     = false;
    enemy_idle_pause_timer    = 0;
    enemy_behavior_delay_timer = enemy_active_delay_max;

    var _t = noone;
    _t = instance_nearest(x, y, obj_player);
    
    target = instance_exists(_t) ? _t : noone;
}

/*
* Name: enemyChaseTarget
* Description: Move towards the provided target using tilemap-aware motion.
*/
function enemyChaseTarget(_target, _speed)
{
    if (!instance_exists(_target)) return;

    var _spd = (is_real(_speed) && _speed != 0) ? _speed : enemy_speed;
    if (_spd <= 0) return;

    var _tx = _target.x;
    var _ty = _target.y;

    var dx = _tx - x;
    var dy = _ty - y;
    var dist = point_distance(x, y, _tx, _ty);

    if (dist <= 0) return;

    var inv = 1 / dist;
    var vx = dx * inv * _spd;
    var vy = dy * inv * _spd;

    moveAxisWithTilemap(enemy_tm, 0, vx, enemy_col_w, enemy_col_h);
    moveAxisWithTilemap(enemy_tm, 1, vy, enemy_col_w, enemy_col_h);
}

/*
* Name: enemyRetreatFromTarget
* Description: Move directly away from the provided target.
*/
function enemyRetreatFromTarget(_target, _speed)
{
    if (!instance_exists(_target)) return;

    var _spd = (is_real(_speed) && _speed != 0) ? _speed : enemy_speed;
    if (_spd <= 0) return;

    var dx = _target.x - x;
    var dy = _target.y - y;
    var dist = point_distance(x, y, _target.x, _target.y);

    var vx, vy;
    if (dist <= 0)
    {
        var dir = irandom_range(0, 359);
        vx = lengthdir_x(_spd, dir);
        vy = lengthdir_y(_spd, dir);
    }
    else
    {
        var inv = 1 / dist;
        vx = -dx * inv * _spd;
        vy = -dy * inv * _spd;
    }

    moveAxisWithTilemap(enemy_tm, 0, vx, enemy_col_w, enemy_col_h);
    moveAxisWithTilemap(enemy_tm, 1, vy, enemy_col_w, enemy_col_h);
}

/*
* Name: enemyIdleChooseTarget
* Description: Pick a new wander target around the idle origin.
*/
function enemyIdleChooseTarget()
{
    var _radius = max(4, enemy_wander_radius);
    var _angle  = irandom_range(0, 359);
    var _dist   = random_range(enemy_idle_tolerance, _radius);

    enemy_idle_target_x = enemy_idle_origin_x + lengthdir_x(_dist, _angle);
    enemy_idle_target_y = enemy_idle_origin_y + lengthdir_y(_dist, _angle);
    enemy_idle_has_target = true;
}

/*
* Name: enemyIdleWanderStep
* Description: Move randomly within the idle radius while respecting collisions.
*/
function enemyIdleWanderStep()
{
    if (enemy_idle_pause_timer > 0)
    {
        enemy_idle_pause_timer -= 1;
        return;
    }

    if (!enemy_idle_has_target)
    {
        enemyIdleChooseTarget();
        return;
    }

    var _tx = enemy_idle_target_x;
    var _ty = enemy_idle_target_y;
    var _dist = point_distance(x, y, _tx, _ty);

    if (_dist <= enemy_idle_tolerance)
    {
        enemy_idle_has_target = false;
        enemy_idle_pause_timer = irandom_range(enemy_idle_pause_min, enemy_idle_pause_max);
        return;
    }

    if (_dist <= 0) return;

    var inv = 1 / _dist;
    var vx = (enemy_idle_target_x - x) * inv * enemy_idle_speed;
    var vy = (enemy_idle_target_y - y) * inv * enemy_idle_speed;

    moveAxisWithTilemap(enemy_tm, 0, vx, enemy_col_w, enemy_col_h);
    moveAxisWithTilemap(enemy_tm, 1, vy, enemy_col_w, enemy_col_h);
}

/*
* Name: enemySpawnMeleeAttack
* Description: Spawn the melee attack hitbox and animation.
*/
function enemySpawnMeleeAttack(_dir)
{
    if (!object_exists(obj_enemy_melee_attack)) return;

    var _layer_name = layer_get_name(layer);
    if (!layer_exists(_layer_name))
    {
        var _lid = layer_get_id_at_depth(0);
        if (_lid != -1) _layer_name = layer_get_name(_lid);
    }

    var _dist = enemy_melee_attack_distance;
    var _sx = x + lengthdir_x(_dist, _dir);
    var _sy = y + lengthdir_y(_dist, _dir);

    var _attack = instance_create_layer(_sx, _sy, _layer_name, obj_enemy_melee_attack);
    if (!instance_exists(_attack)) return;

    var _sprite = enemy_melee_attack_sprite;

    _attack.owner = id;
    _attack.damage = enemy_melee_damage;
    _attack.life = max(1, enemy_melee_attack_duration);

    if (is_real(_sprite) && _sprite >= 0)
    {
        _attack.sprite_index = _sprite;
    }

    if (_attack.sprite_index != -1)
    {
        var _frames = max(1, sprite_get_number(_attack.sprite_index));
        _attack.image_index = 0;
        _attack.image_speed = _frames / max(1, _attack.life);
    }
    else
    {
        _attack.image_speed = 0;
    }

    _attack.image_angle = _dir;
}

/*
* Name: enemyPerformMeleeAttack
* Description: Attempt to trigger a melee strike if the cooldown has elapsed.
*/
function enemyPerformMeleeAttack(_target)
{
    if (enemy_melee_cooldown_timer > 0) return;

    var _dir = 0;
    if (instance_exists(_target))
    {
        _dir = point_direction(x, y, _target.x, _target.y);
    }
    else
    {
        _dir = image_angle;
    }

    enemySpawnMeleeAttack(_dir);

    if (toughness == EnemyToughness.Boss && enemy_melee_extra_attacks > 0)
    {
        for (var i = 1; i <= enemy_melee_extra_attacks; i++)
        {
            var _offset = enemy_melee_extra_spread * i;
            enemySpawnMeleeAttack(_dir + _offset);
            enemySpawnMeleeAttack(_dir - _offset);
        }
    }

    enemy_melee_cooldown_timer = enemy_melee_cooldown_max;
}

/*
* Name: enemyResolveProjectileLayer
* Description: Determine a safe layer for spawning enemy projectiles.
*/
function enemyResolveProjectileLayer()
{
    var _spawn_layer = INSTANCE_LAYER_NAME;
    if (layer_exists(_spawn_layer)) return _spawn_layer;

    // Try the enemy's current layer before falling back to depth 0.
    var _self_layer_id = layer;
    var _self_layer_name = undefined;
    if (is_real(_self_layer_id))
    {
        _self_layer_name = layer_get_name(_self_layer_id);
    }
    else if (is_string(_self_layer_id))
    {
        _self_layer_name = _self_layer_id;
    }

    if (is_string(_self_layer_name) && layer_exists(_self_layer_name)) return _self_layer_name;

    var _lid = layer_get_id_at_depth(0);
    if (_lid != -1)
    {
        var _fallback = layer_get_name(_lid);
        if (is_string(_fallback) && layer_exists(_fallback)) return _fallback;
    }

    return undefined;
}

/*
* Name: enemySpawnProjectileInDirection
* Description: Spawn a projectile aimed in the specified direction if possible.
*/
function enemySpawnProjectileInDirection(_origin_x, _origin_y, _dir, _spawn_layer)
{
    if (!layer_exists(_spawn_layer)) return;

    var _aim = vec2Norm(lengthdir_x(1, _dir), lengthdir_y(1, _dir));
    var _bullet = instance_create_layer(_origin_x, _origin_y, _spawn_layer, obj_enemy_bullet);
    if (!instance_exists(_bullet)) return;

    _bullet.dirx   = _aim[0];
    _bullet.diry   = _aim[1];
    _bullet.spd    = enemy_projectile_speed;
    _bullet.damage = enemy_projectile_damage;
    _bullet.owner  = id;
    _bullet.life   = max(1, enemy_projectile_life);
}

/*
* Name: enemyRangedFireProjectiles
* Description: Fire projectiles at the target with optional boss spread.
*/
function enemyRangedFireProjectiles(_target)
{
    if (enemy_projectile_cooldown > 0) return;
    if (!instance_exists(_target)) return;

    var _dist = point_distance(x, y, _target.x, _target.y);
    if (enemy_projectile_range > 0 && _dist > enemy_projectile_range) return;

    var _spawn_layer = enemyResolveProjectileLayer();
    if (!is_string(_spawn_layer)) return;

    var _base_dir = point_direction(x, y, _target.x, _target.y);
    enemySpawnProjectileInDirection(x, y, _base_dir, _spawn_layer);

    if (toughness == EnemyToughness.Boss && enemy_projectile_boss_extra > 0)
    {
        for (var i = 1; i <= enemy_projectile_boss_extra; i++)
        {
            var _offset = enemy_projectile_boss_spread * i;
            enemySpawnProjectileInDirection(x, y, _base_dir + _offset, _spawn_layer);
            enemySpawnProjectileInDirection(x, y, _base_dir - _offset, _spawn_layer);
        }
    }

    enemy_projectile_cooldown = enemy_projectile_cooldown_max;
}

/*
* Name: enemyApplyDamage
* Description: Apply damage with stun/flash feedback and ensure the enemy becomes active.
*/
function enemyApplyDamage(_amount, _source)
{
    if (!variable_instance_exists(id, "hp")) return;

    var _dmg = is_real(_amount) ? _amount : 0;
    _dmg = max(0, _dmg);
    hp = max(0, hp - _dmg);

    if (!variable_instance_exists(id, "enemy_flash_duration"))
    {
        enemy_flash_duration = 2;
    }
    if (!variable_instance_exists(id, "enemy_stun_duration"))
    {
        enemy_stun_duration = 2;
    }

    enemy_flash_timer = max(enemy_flash_timer, enemy_flash_duration);
    enemy_stun_timer  = max(enemy_stun_timer, enemy_stun_duration);

    var _attacker = noone;
    if (instance_exists(_source))
    {
        if (_source.object_index == obj_player)
        {
            _attacker = _source;
        }
        else if (variable_instance_exists(_source, "owner") && instance_exists(_source.owner))
        {
            if (_source.owner.object_index == obj_player)
            {
                _attacker = _source.owner;
            }
        }
    }

    if (!instance_exists(_attacker))
    {
        _attacker = instance_nearest(x, y, obj_player);
    }

    if (instance_exists(_attacker))
    {
        enemySetActive(_attacker);
    }
    else
    {
        enemySetActive(noone);
    }
}

/*
* Name: enemySeekPlayerStep
* Description: Handle behaviour state transitions and archetype-specific logic.
*/
function enemySeekPlayerStep()
{
    if (onPauseExit()) return;
    if (!instance_exists(obj_player)) return;
    
    // Need to have overridden function for enemy seek player step
    if (enemy_flash_timer > 0) enemy_flash_timer -= 1;
    if (enemy_stun_timer  > 0) enemy_stun_timer  -= 1;
    if (enemy_behavior_delay_timer > 0) enemy_behavior_delay_timer -= 1;
    if (enemy_melee_cooldown_timer > 0) enemy_melee_cooldown_timer -= 1;
    if (enemy_projectile_cooldown > 0) enemy_projectile_cooldown -= 1;

    var _player = instance_nearest(x, y, obj_player);
    if (_player == noone)
    {
        enemySetIdle();
        return;
    }

    switch (enemy_state)
    {
        case EnemyState.Idle:
            if (point_distance(x, y, _player.x, _player.y) <= enemy_activation_range)
            {
                enemySetActive(_player);
            }
            else
            {
                enemyIdleWanderStep();
            }
            break;

        case EnemyState.Active:
            if (!instance_exists(target) || target.object_index != obj_player)
            {
                target = _player;
            }

            if (!instance_exists(target))
            {
                enemySetIdle();
                break;
            }

            var _dist = point_distance(x, y, target.x, target.y);
            if (_dist > enemy_leash_range)
            {
                enemySetIdle();
                break;
            }

            if (enemy_stun_timer > 0)
            {
                break;
            }

            if (type == EnemyType.Ranged)
            {
                if (enemy_retreat_radius > 0 && _dist <= enemy_retreat_radius)
                {
                    enemyRetreatFromTarget(target, enemy_retreat_speed);
                }

                if (enemy_behavior_delay_timer <= 0)
                {
                    enemyRangedFireProjectiles(target);
                }
            }
            else
            {
                if (enemy_behavior_delay_timer <= 0)
                {
                    if (_dist <= enemy_melee_range)
                    {
                        enemyPerformMeleeAttack(target);
                    }
                    else
                    {
                        enemyChaseTarget(target, enemy_speed);
                    }
                }
                else
                {
                    // Once engaged, step closer even during windup
                    enemyChaseTarget(target, enemy_speed);
                }
            }
            break;
    }
}

/*
* Name: enemyResolveTilemap
* Description: Resolve the collision tilemap from the layer named "tm_collision".
*/
function enemyResolveTilemap()
{
    var _lid = layer_get_id("tm_collision");
    enemy_tm = (_lid != -1) ? layer_tilemap_get_id(_lid) : noone;
}

/*
* Name: tmRectHitsSolid
* Description: Check if any solid tile occupies rectangle (x,y,w,h) in tilemap coordinates.
*/
function tmRectHitsSolid(_tm, _x, _y, _w, _h)
{
    if (_tm == noone) return false;
    var left   = floor(_x - _w * 0.5);
    var right  = floor(_x + _w * 0.5);
    var top    = floor(_y - _h * 0.5);
    var bottom = floor(_y + _h * 0.5);

    // Sample in a coarse grid (corners + midpoints)
    var sx = [left, (left+right)>>1, right];
    var sy = [top,  (top+bottom)>>1, bottom];

    for (var ix = 0; ix < 3; ix++)
    {
        for (var iy = 0; iy < 3; iy++)
        {
            var tile = tilemap_get_at_pixel(_tm, sx[ix], sy[iy]);
            if (tile != 0) return true;
        }
    }
    return false;
}

/*
* Name: moveAxisWithTilemap
* Description: Axis-separated movement with tilemap collision that supports fractional speeds
*              via per-instance accumulators (enemy_move_rx / enemy_move_ry) and blocks the player.
*/
function moveAxisWithTilemap(_tm, _axis, _amount, _w, _h)
{
    if (_tm == noone || _amount == 0) return;

    // Gather remainder + this frame's desired amount
    var _rem   = (_axis == 0) ? enemy_move_rx : enemy_move_ry;
    var _total = _rem + _amount;

    // Whole pixels we can attempt this frame (sign says direction)
    var _dir   = sign(_total);
    var _steps = floor(abs(_total));
    var _moved = 0;
    var _hit   = false;
    var _block_player = object_exists(obj_player);

    // Step pixel-by-pixel; stop if we hit a solid
    for (var _i = 0; _i < _steps; _i++)
    {
        var _prev_x = x;
        var _prev_y = y;
        if (_axis == 0) x += _dir; else y += _dir;

        var _blocked = tmRectHitsSolid(_tm, x, y, _w, _h);
        if (!_blocked && _block_player)
        {
            var _player_hit = instance_place(x, y, obj_player);
            _blocked = (_player_hit != noone);
        }

        if (_blocked)
        {
            // undo the last step; we are blocked
            x = _prev_x;
            y = _prev_y;
            _hit = true;
            break;
        }
        _moved += _dir;
    }

    // Remainder = what we wanted minus what we actually moved
    var _leftover = _total - _moved;

    // If we hit a wall, kill remainder on that axis so we don't "push" next frame
    if (_hit) _leftover = 0;

    if (_axis == 0) enemy_move_rx = _leftover; else enemy_move_ry = _leftover;
}
