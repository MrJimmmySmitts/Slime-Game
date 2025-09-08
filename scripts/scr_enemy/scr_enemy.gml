/*
* Name: enemy_base_init
* Description: Initialise default enemy properties and cache collision tilemap + collider size.
*/
function enemy_base_init() {
    if (!variable_instance_exists(id, "enemy_speed")) enemy_speed = 1.25;   // px/step (children override)
    if (!variable_instance_exists(id, "enemy_range")) enemy_range = 200;    // px (children override)

    // Collider size (fallback to sprite bbox if available)
    var w = sprite_get_width(sprite_index);
    var h = sprite_get_height(sprite_index);
    enemy_col_w = (w > 0) ? clamp(w * 0.50, 8, 24) : 16;
    enemy_col_h = (h > 0) ? clamp(h * 0.50, 8, 24) : 16;

    // Resolve and cache the collision tilemap
    enemy_resolve_tilemap();
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
* Description: Move along one axis with collision against a tilemap (axis-separated).
*/
function move_axis_with_tilemap(_tm, _axis, _amount, _w, _h) {
    if (_amount == 0) return;
    var step = sign(_amount);
    var remaining = abs(_amount);

    repeat (remaining) {
        if (_axis == 0) { x += step; } else { y += step; }
        if (tm_rect_hits_solid(_tm, x, y, _w, _h)) {
            if (_axis == 0) { x -= step; } else { y -= step; }
            break;
        }
    }
}

/*
* Name: enemy_seek_player_step
* Description: When the player is within enemy_range, move toward them at enemy_speed using tilemap collision.
*/
function enemy_seek_player_step() {
    // early-outs
    if (on_pause_exit()) return;
    if (!instance_exists(obj_player)) return;

    // get nearest player
    var p = instance_nearest(x, y, obj_player);
    if (p == noone) return;

    var dx = p.x - x;
    var dy = p.y - y;
    var dist = point_distance(x, y, p.x, p.y);
    if (dist <= enemy_range && dist > 0) {
        var fx = dx / dist;
        var fy = dy / dist;

        var vx = fx * enemy_speed;
        var vy = fy * enemy_speed;

        // ensure we have a tilemap + collider
        if (!variable_instance_exists(id, "enemy_tm") || enemy_tm == undefined) enemy_resolve_tilemap();
        var tm = enemy_tm;
        var cw = enemy_col_w;
        var ch = enemy_col_h;

        // axis-separated movement
        move_axis_with_tilemap(tm, 0, vx, cw, ch);
        move_axis_with_tilemap(tm, 1, vy, cw, ch);
    }
}
