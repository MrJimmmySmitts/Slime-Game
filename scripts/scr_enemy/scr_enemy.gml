/*
* Name: enemy_unstuck_from_tilemap
* Description: If the collider overlaps the collision tilemap at the current position,
*              push out along the smallest displacement up to _max pixels.
*/
function enemy_unstuck_from_tilemap(_tm, _max) {
    if (_tm == noone) return;

    var _max_push = max(1, _max);

    // If not overlapping, nothing to do
    if (!tm_rect_hits_solid(_tm, x, y, enemy_col_w, enemy_col_h)) return;

    // Try outward pushes in small rings until free
    for (var _d = 1; _d <= _max_push; _d++) {
        // cardinal directions first (cheap + likely)
        if (!tm_rect_hits_solid(_tm, x + _d, y, enemy_col_w, enemy_col_h)) { x += _d; return; }
        if (!tm_rect_hits_solid(_tm, x - _d, y, enemy_col_w, enemy_col_h)) { x -= _d; return; }
        if (!tm_rect_hits_solid(_tm, x, y + _d, enemy_col_w, enemy_col_h)) { y += _d; return; }
        if (!tm_rect_hits_solid(_tm, x, y - _d, enemy_col_w, enemy_col_h)) { y -= _d; return; }

        // simple diagonals as a fallback if still stuck
        if (!tm_rect_hits_solid(_tm, x + _d, y + _d, enemy_col_w, enemy_col_h)) { x += _d; y += _d; return; }
        if (!tm_rect_hits_solid(_tm, x - _d, y + _d, enemy_col_w, enemy_col_h)) { x -= _d; y += _d; return; }
        if (!tm_rect_hits_solid(_tm, x + _d, y - _d, enemy_col_w, enemy_col_h)) { x += _d; y -= _d; return; }
        if (!tm_rect_hits_solid(_tm, x - _d, y - _d, enemy_col_w, enemy_col_h)) { x -= _d; y -= _d; return; }
    }
    // If we get here, still stuck — leave position as-is; movement will remain blocked until level geometry changes.
}

/*
* Name: enemy_base_init
* Description: Initialise defaults, collider, tilemap, and fractional move remainders.
*/
function enemy_base_init() {
    if (!variable_instance_exists(id, "enemy_speed")) enemy_speed = 1.25;
    if (!variable_instance_exists(id, "enemy_range")) enemy_range = 200;

    var w = sprite_get_width(sprite_index);
    var h = sprite_get_height(sprite_index);
    enemy_col_w = (w > 0) ? clamp(w * 0.50, 8, 24) : 16;
    enemy_col_h = (h > 0) ? clamp(h * 0.50, 8, 24) : 16;

    enemy_resolve_tilemap();

    // NEW: subpixel accumulators (so speeds < 1 still move)
    enemy_move_rx = 0;
    enemy_move_ry = 0;

    // Optional safety if placed inside tiles:
    // enemy_unstuck_from_tilemap(enemy_tm, 8);
}

/*
* Name: enemy_seek_player_step
* Description: Avoid tiny oscillations when very close to the player.
*/
function enemy_seek_player_step() {
    if (on_pause_exit()) return;
    if (!instance_exists(obj_player)) return;

    var p = instance_nearest(x, y, obj_player);
    if (p == noone) return;

    var dx = p.x - x;
    var dy = p.y - y;
    var dist = point_distance(x, y, p.x, p.y);

    // NEW: if we're closer than one "speed" step, don't move this frame
    if (dist <= enemy_speed) return;

    if (dist <= enemy_range) {
        var fx = dx / dist;
        var fy = dy / dist;
        var vx = fx * enemy_speed;
        var vy = fy * enemy_speed;

        move_axis_with_tilemap(enemy_tm, 0, vx, enemy_col_w, enemy_col_h);
        move_axis_with_tilemap(enemy_tm, 1, vy, enemy_col_w, enemy_col_h);
    }
}


/*
* Name: enemy_resolve_tilemap
* Description: Resolve the collision tilemap from the layer named "tm_collision".
*/
function enemy_resolve_tilemap() {
    var _lid = layer_get_id("tm_collision");
    enemy_tm = (_lid != -1) ? layer_tilemap_get_id(_lid) : noone;
}

/*
* Name: tm_rect_hits_solid
* Description: Check if any solid tile occupies rectangle (x,y,w,h) in tilemap coordinates.
*/
function tm_rect_hits_solid(_tm, _x, _y, _w, _h) {
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
* Name: move_axis_with_tilemap
* Description: Axis-separated movement with tilemap collision that supports fractional speeds
*              via per-instance accumulators (enemy_move_rx / enemy_move_ry). No overshoot.
*/
function move_axis_with_tilemap(_tm, _axis, _amount, _w, _h) {
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

        if (tm_rect_hits_solid(_tm, x, y, _w, _h)) {
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
