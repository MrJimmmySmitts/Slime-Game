// ====================================================================
// scr_pmove.gml — simple tilemap collision movement helpers
// ====================================================================

/*
* Name: tilemapSolidAt
* Description: Returns true if the given tilemap id has a non-empty tile at (px, py).
*/
function tilemapSolidAt(tilemap_id, px, py)
{
    // Treat any non-zero tile-id as solid on the collision tilemap.
    return tilemap_get_at_pixel(tilemap_id, px, py) != 0;
}

/*
* Name: pmovePlaceMeetingTilemap
* Description: Checks if bbox of the instance at (test_x, test_y) overlaps any solid tiles.
*/
function pmovePlaceMeetingTilemap(inst, tilemap_id, test_x, test_y, inset)
{
    var bb_left   = inst.bbox_left   - inst.x + test_x + inset;
    var bb_right  = inst.bbox_right  - inst.x + test_x - inset;
    var bb_top    = inst.bbox_top    - inst.y + test_y + inset;
    var bb_bottom = inst.bbox_bottom - inst.y + test_y - inset;

    // Sample four corners
    if (tilemapSolidAt(tilemap_id, bb_left,  bb_top))    return true;
    if (tilemapSolidAt(tilemap_id, bb_right, bb_top))    return true;
    if (tilemapSolidAt(tilemap_id, bb_left,  bb_bottom)) return true;
    if (tilemapSolidAt(tilemap_id, bb_right, bb_bottom)) return true;

    return false;
}

/*
* Name: pmoveMoveAxis
* Description: Moves instance along one axis with pixel sweep to avoid tunnelling on tiles and enemies.
*/
function pmoveMoveAxis(inst, tilemap_id, axis_dx, axis_dy, inset)
{
    var remaining_x = axis_dx;
    var remaining_y = axis_dy;
    var block_enemy = object_exists(obj_enemy);

    // Move X axis
    if (remaining_x != 0)
    {
        var step_x = signNonzero(remaining_x);
        var blocked_x = false;
        repeat (abs(floor(remaining_x)))
        {
            var next_x = inst.x + step_x;
            if (!pmovePlaceMeetingTilemap(inst, tilemap_id, next_x, inst.y, inset))
            {
                var prev_x = inst.x;
                inst.x = next_x;
                if (block_enemy)
                {
                    var hit_enemy = instance_place(inst.x, inst.y, obj_enemy);
                    if (hit_enemy != noone)
                    {
                        inst.x = prev_x;
                        blocked_x = true;
                        break;
                    }
                }
            }
            else
            {
                blocked_x = true;
                break;
            }
        }
        // Fractional remainder
        if (!blocked_x)
        {
            var fract_x = remaining_x - floor(remaining_x);
            if (fract_x != 0)
            {
                var next_fx = inst.x + fract_x;
                if (!pmovePlaceMeetingTilemap(inst, tilemap_id, next_fx, inst.y, inset))
                {
                    var prev_fx = inst.x;
                    inst.x = next_fx;
                    if (block_enemy)
                    {
                        var hit_enemy_frac = instance_place(inst.x, inst.y, obj_enemy);
                        if (hit_enemy_frac != noone)
                        {
                            inst.x = prev_fx;
                        }
                    }
                }
            }
        }
    }

    // Move Y axis
    if (remaining_y != 0)
    {
        var step_y = signNonzero(remaining_y);
        var blocked_y = false;
        repeat (abs(floor(remaining_y)))
        {
            var next_y = inst.y + step_y;
            if (!pmovePlaceMeetingTilemap(inst, tilemap_id, inst.x, next_y, inset))
            {
                var prev_y = inst.y;
                inst.y = next_y;
                if (block_enemy)
                {
                    var hit_enemy_y = instance_place(inst.x, inst.y, obj_enemy);
                    if (hit_enemy_y != noone)
                    {
                        inst.y = prev_y;
                        blocked_y = true;
                        break;
                    }
                }
            }
            else
            {
                blocked_y = true;
                break;
            }
        }
        if (!blocked_y)
        {
            var fract_y = remaining_y - floor(remaining_y);
            if (fract_y != 0)
            {
                var next_fy = inst.y + fract_y;
                if (!pmovePlaceMeetingTilemap(inst, tilemap_id, inst.x, next_fy, inset))
                {
                    var prev_fy = inst.y;
                    inst.y = next_fy;
                    if (block_enemy)
                    {
                        var hit_enemy_frac_y = instance_place(inst.x, inst.y, obj_enemy);
                        if (hit_enemy_frac_y != noone)
                        {
                            inst.y = prev_fy;
                        }
                    }
                }
            }
        }
    }
}

/*
* Name: pmoveApply
* Description: Applies movement (dx,dy) with collision on a collision tilemap layer.
*/
function pmoveApply(inst, dx, dy, tilemap_id, inset)
{
    pmoveMoveAxis(inst, tilemap_id, dx, 0, inset);
    pmoveMoveAxis(inst, tilemap_id, 0, dy, inset);
}
