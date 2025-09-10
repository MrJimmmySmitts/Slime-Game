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
* Description: Moves instance along one axis with pixel sweep to avoid tunnelling on tiles.
*/
function pmoveMoveAxis(inst, tilemap_id, axis_dx, axis_dy, inset)
{
    var remaining_x = axis_dx;
    var remaining_y = axis_dy;

    // Move X axis
    if (remaining_x != 0)
    {
        var step_x = signNonzero(remaining_x);
        repeat (abs(floor(remaining_x)))
        {
            var next_x = inst.x + step_x;
            if (!pmovePlaceMeetingTilemap(inst, tilemap_id, next_x, inst.y, inset))
                inst.x = next_x;
            else
                break;
        }
        // Fractional remainder
        var fract_x = remaining_x - floor(remaining_x);
        if (fract_x != 0)
        {
            var next_fx = inst.x + fract_x;
            if (!pmovePlaceMeetingTilemap(inst, tilemap_id, next_fx, inst.y, inset))
                inst.x = next_fx;
        }
    }

    // Move Y axis
    if (remaining_y != 0)
    {
        var step_y = signNonzero(remaining_y);
        repeat (abs(floor(remaining_y)))
        {
            var next_y = inst.y + step_y;
            if (!pmovePlaceMeetingTilemap(inst, tilemap_id, inst.x, next_y, inset))
                inst.y = next_y;
            else
                break;
        }
        var fract_y = remaining_y - floor(remaining_y);
        if (fract_y != 0)
        {
            var next_fy = inst.y + fract_y;
            if (!pmovePlaceMeetingTilemap(inst, tilemap_id, inst.x, next_fy, inset))
                inst.y = next_fy;
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
