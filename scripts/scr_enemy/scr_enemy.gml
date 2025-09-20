/*
* Name: EnemyState
* Description: Enemy behaviour state machine values.
*/
enum EnemyState
{
    Idle   = 0,
    Active = 1,
}

/*
* Name: enemyUnstuckFromTilemap
* Description: If the collider overlaps the collision tilemap at the current position,
*              push out along the smallest displacement up to _max pixels.
*/
function enemyUnstuckFromTilemap(_tm, _max) {
    if (_tm == noone) return;

    var _max_push = max(1, _max);

    // If not overlapping, nothing to do
    if (!tmRectHitsSolid(_tm, x, y, enemy_col_w, enemy_col_h)) return;

    // Try outward pushes in small rings until free
    for (var _d = 1; _d <= _max_push; _d++) {
        // cardinal directions first (cheap + likely)
        if (!tmRectHitsSolid(_tm, x + _d, y, enemy_col_w, enemy_col_h)) { x += _d; return; }
        if (!tmRectHitsSolid(_tm, x - _d, y, enemy_col_w, enemy_col_h)) { x -= _d; return; }
        if (!tmRectHitsSolid(_tm, x, y + _d, enemy_col_w, enemy_col_h)) { y += _d; return; }
        if (!tmRectHitsSolid(_tm, x, y - _d, enemy_col_w, enemy_col_h)) { y -= _d; return; }

        // simple diagonals as a fallback if still stuck
        if (!tmRectHitsSolid(_tm, x + _d, y + _d, enemy_col_w, enemy_col_h)) { x += _d; y += _d; return; }
        if (!tmRectHitsSolid(_tm, x - _d, y + _d, enemy_col_w, enemy_col_h)) { x -= _d; y += _d; return; }
        if (!tmRectHitsSolid(_tm, x + _d, y - _d, enemy_col_w, enemy_col_h)) { x += _d; y -= _d; return; }
        if (!tmRectHitsSolid(_tm, x - _d, y - _d, enemy_col_w, enemy_col_h)) { x -= _d; y -= _d; return; }
    }
    // If we get here, still stuck — leave position as-is; movement will remain blocked until level geometry changes.
}

/*
* Name: enemyBaseInit
* Description: Initialise defaults, collider, tilemap, and fractional move remainders.
*/
function enemyBaseInit() {
    if (!variable_instance_exists(id, "enemy_speed")) enemy_speed = 1.25;
    if (!variable_instance_exists(id, "enemy_range")) enemy_range = 200;

    if (!variable_instance_exists(id, "enemy_activation_range")) enemy_activation_range = enemy_range;
    if (!variable_instance_exists(id, "enemy_leash_range")) {
        enemy_leash_range = max(enemy_activation_range + 96, enemy_activation_range);
    } else {
        enemy_leash_range = max(enemy_leash_range, enemy_activation_range);
    }

    if (!variable_instance_exists(id, "enemy_flash_duration")) {
        enemy_flash_duration = max(2, round(room_speed * 0.08));
    }
    if (!variable_instance_exists(id, "enemy_stun_duration")) {
        enemy_stun_duration = max(2, round(room_speed * 0.15));
    }

    enemy_flash_timer = 0;
    enemy_stun_timer  = 0;
    enemy_state       = EnemyState.Idle;

    var w = sprite_get_width(sprite_index);
    var h = sprite_get_height(sprite_index);
    enemy_col_w = (w > 0) ? clamp(w * 0.50, 8, 24) : 16;
    enemy_col_h = (h > 0) ? clamp(h * 0.50, 8, 24) : 16;

    enemyResolveTilemap();

    // NEW: subpixel accumulators (so speeds < 1 still move)
    enemy_move_rx = 0;
    enemy_move_ry = 0;

    // Optional safety if placed inside tiles:
    // enemyUnstuckFromTilemap(enemy_tm, 8);
}

/*
* Name: enemySetIdle
* Description: Reset behaviour state to idle and clear movement remainders/target.
*/
function enemySetIdle() {
    enemy_state = EnemyState.Idle;
    target      = noone;
    if (variable_instance_exists(id, "enemy_move_rx")) enemy_move_rx = 0;
    if (variable_instance_exists(id, "enemy_move_ry")) enemy_move_ry = 0;
}

/*
* Name: enemySetActive
* Description: Activate the enemy and assign a chase target (defaults to nearest player).
*/
function enemySetActive(_target) {
    enemy_state = EnemyState.Active;

    var _t = noone;
    if (instance_exists(_target)) {
        _t = _target;
    } else {
        _t = instance_nearest(x, y, obj_player);
    }

    target = instance_exists(_t) ? _t : noone;
}

/*
* Name: enemyChaseTarget
* Description: Move towards the provided target using tilemap-aware motion.
*/
function enemyChaseTarget(_target) {
    if (!instance_exists(_target)) return;

    var _tx = _target.x;
    var _ty = _target.y;

    var dx = _tx - x;
    var dy = _ty - y;
    var dist = point_distance(x, y, _tx, _ty);

    if (dist <= enemy_speed) return;
    if (dist <= 0) return;

    var inv = 1 / dist;
    var vx = dx * inv * enemy_speed;
    var vy = dy * inv * enemy_speed;

    moveAxisWithTilemap(enemy_tm, 0, vx, enemy_col_w, enemy_col_h);
    moveAxisWithTilemap(enemy_tm, 1, vy, enemy_col_w, enemy_col_h);
}

/*
* Name: enemyApplyDamage
* Description: Apply damage with stun/flash feedback and ensure the enemy becomes active.
*/
function enemyApplyDamage(_amount, _source) {
    if (!variable_instance_exists(id, "hp")) return;

    var _dmg = is_real(_amount) ? _amount : 0;
    _dmg = max(0, _dmg);
    hp = max(0, hp - _dmg);

    if (!variable_instance_exists(id, "enemy_flash_duration")) {
        enemy_flash_duration = max(2, round(room_speed * 0.08));
    }
    if (!variable_instance_exists(id, "enemy_stun_duration")) {
        enemy_stun_duration = max(2, round(room_speed * 0.15));
    }

    enemy_flash_timer = max(enemy_flash_timer, enemy_flash_duration);
    enemy_stun_timer  = max(enemy_stun_timer, enemy_stun_duration);

    var _attacker = noone;
    if (instance_exists(_source)) {
        if (_source.object_index == obj_player) {
            _attacker = _source;
        } else if (variable_instance_exists(_source, "owner") && instance_exists(_source.owner)) {
            if (_source.owner.object_index == obj_player) {
                _attacker = _source.owner;
            }
        }
    }

    if (!instance_exists(_attacker)) {
        _attacker = instance_nearest(x, y, obj_player);
    }

    if (instance_exists(_attacker)) {
        enemySetActive(_attacker);
    } else {
        enemySetActive(noone);
    }
}

/*
* Name: enemySeekPlayerStep
* Description: Handle behaviour state transitions and chase the player when active.
*/
function enemySeekPlayerStep() {
    if (onPauseExit()) return;
    if (!instance_exists(obj_player)) return;

    var _player = instance_nearest(x, y, obj_player);
    if (_player == noone) {
        enemySetIdle();
        return;
    }

    switch (enemy_state) {
        case EnemyState.Idle:
            if (point_distance(x, y, _player.x, _player.y) <= enemy_activation_range) {
                enemySetActive(_player);
            }
            break;

        case EnemyState.Active:
            if (!instance_exists(target) || target.object_index != obj_player) {
                target = _player;
            }

            if (!instance_exists(target)) {
                enemySetIdle();
                break;
            }

            var _dist = point_distance(x, y, target.x, target.y);
            if (_dist > enemy_leash_range) {
                enemySetIdle();
                break;
            }

            if (enemy_stun_timer <= 0) {
                enemyChaseTarget(target);
            }
            break;
    }
}


/*
* Name: enemyResolveTilemap
* Description: Resolve the collision tilemap from the layer named "tm_collision".
*/
function enemyResolveTilemap() {
    var _lid = layer_get_id("tm_collision");
    enemy_tm = (_lid != -1) ? layer_tilemap_get_id(_lid) : noone;
}

/*
* Name: tmRectHitsSolid
* Description: Check if any solid tile occupies rectangle (x,y,w,h) in tilemap coordinates.
*/
function tmRectHitsSolid(_tm, _x, _y, _w, _h) {
    if (_tm == noone) return false;
    var left   = floor(_x - _w * 0.5);
    var right  = floor(_x + _w * 0.5);
    var top    = floor(_y - _h * 0.5);
    var bottom = floor(_y + _h * 0.5);

    // Sample in a coarse grid (corners + midpoints)
    var sx = [left, (left+right)>>1, right];
    var sy = [top,  (top+bottom)>>1, bottom];

    for (var ix = 0; ix < 3; ix++) {
        for (var iy = 0; iy < 3; iy++) {
            var tile = tilemap_get_at_pixel(_tm, sx[ix], sy[iy]);
            if (tile != 0) return true;
        }
    }
    return false;
}

/*
* Name: moveAxisWithTilemap
* Description: Axis-separated movement with tilemap collision that supports fractional speeds
*              via per-instance accumulators (enemy_move_rx / enemy_move_ry). No overshoot.
*/
function moveAxisWithTilemap(_tm, _axis, _amount, _w, _h) {
    if (_tm == noone || _amount == 0) return;

    // Gather remainder + this frame's desired amount
    var _rem   = (_axis == 0) ? enemy_move_rx : enemy_move_ry;
    var _total = _rem + _amount;

    // Whole pixels we can attempt this frame (sign says direction)
    var _dir   = sign(_total);
    var _steps = floor(abs(_total));
    var _moved = 0;
    var _hit   = false;

    // Step pixel-by-pixel; stop if we hit a solid
    for (var _i = 0; _i < _steps; _i++) {
        if (_axis == 0) x += _dir; else y += _dir;

        if (tmRectHitsSolid(_tm, x, y, _w, _h)) {
            // undo the last step; we are blocked
            if (_axis == 0) x -= _dir; else y -= _dir;
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
