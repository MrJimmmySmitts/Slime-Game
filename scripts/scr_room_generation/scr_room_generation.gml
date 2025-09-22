/*
* Name: dgConfigDefault
* Description: Returns a struct with default generator settings.
*/
function dgConfigDefault() {
    return {
        room_count_min: 8,
        room_count_max: 12,
        grid_radius: 8,

        room_cell_w: 16,
        room_cell_h: 12,

        walk_tileset: ts_walk,
        coll_tileset: ts_coll,

        walk_layer_name: "tm_floor",
        coll_layer_name: "tm_collision",

        allow_room_rotation: false,
        seed: -1
    };
}

/*
* Name: dgRngInit
* Description: Initializes RNG based on config seed.
*/
function dgRngInit(_cfg) {
    if (_cfg.seed != -1) random_set_seed(_cfg.seed);
    else randomize();
}
/*
* Name: dgRoomTemplateNew
* Description: Creates a room template with exits + tile arrays.
*/
function dgRoomTemplateNew(_name, _exN, _exE, _exS, _exW, _walk_grid, _coll_grid) {
    return {
        name: _name,
        exitN: _exN, exitE: _exE, exitS: _exS, exitW: _exW,
        walk: _walk_grid,
        coll: _coll_grid
    };
}
/*
* Name: dgRoomdbBuildExamples
* Description: Returns a small set of example room templates.
*/
function dgRoomdbBuildExamples(_cfg) {
    var w = _cfg.room_cell_w;
    var h = _cfg.room_cell_h;

    function make_room(_name, _exN, _exE, _exS, _exW, _w, _h) {
        var walk = array_create(_h);
        for (var r = 0; r < _h; r++) {
            walk[r] = array_create(_w, 1);
        }
        var coll = array_create(_h);
        for (var r = 0; r < _h; r++) coll[r] = array_create(_w, 0);

        // walls around border
        for (var c = 0; c < _w; c++) { coll[0][c] = 2; coll[_h-1][c] = 2; }
        for (var r2 = 0; r2 < _h; r2++) { coll[r2][0] = 2; coll[r2][_w-1] = 2; }

        var midx = _w div 2;
        var midy = _h div 2;

        if (_exN) coll[0][midx] = 0;
        if (_exS) coll[_h-1][midx] = 0;
        if (_exW) coll[midy][0] = 0;
        if (_exE) coll[midy][_w-1] = 0;

        return dgRoomTemplateNew(_name, _exN, _exE, _exS, _exW, walk, coll);
    }

    return [
        make_room("Cross", true, true, true, true, w, h),
        make_room("NS", true, false, true, false, w, h),
        make_room("EW", false, true, false, true, w, h),
        make_room("Corner_NE", true, true, false, false, w, h),
        make_room("Corner_ES", false, true, true, false, w, h),
        make_room("Corner_SW", false, false, true, true, w, h),
        make_room("Corner_WN", true, false, false, true, w, h),
        make_room("DeadN", true, false, false, false, w, h),
        make_room("DeadE", false, true, false, false, w, h),
        make_room("DeadS", false, false, true, false, w, h),
        make_room("DeadW", false, false, false, true, w, h)
    ];
}
/*
* Name: dgGraphKey
* Description: Converts grid coords to a unique key.
*/
function dgGraphKey(_gx, _gy) {
    return string(_gx) + ":" + string(_gy);
}

/*
* Name: dgGraphAddNode
* Description: Adds node to graph.
*/
function dgGraphAddNode(_map, _gx, _gy) {
    var key = dgGraphKey(_gx, _gy);
    if (!ds_map_exists(_map, key)) {
        var node = {
            gx: _gx, gy: _gy,
            N: undefined, E: undefined, S: undefined, W: undefined,
            tmpl_index: -1
        };
        ds_map_add(_map, key, node);
    }
    return key;
}

/*
* Name: dgGraphNeighbors4
* Description: NESW neighbor offsets.
*/
function dgGraphNeighbors4() {
    return [
        { dx: 0, dy: -1, side: "N", opp: "S" },
        { dx: 1, dy:  0, side: "E", opp: "W" },
        { dx: 0, dy:  1, side: "S", opp: "N" },
        { dx: -1, dy: 0, side: "W", opp: "E" }
    ];
}
/*
* Name: dgLayoutBuild
* Description: Builds a connected layout graph.
*/
function dgLayoutBuild(_cfg) {
    var target = irandom_range(_cfg.room_count_min, _cfg.room_count_max);
    var graph = ds_map_create();

    var cur_gx = 0, cur_gy = 0;
    dgGraphAddNode(graph, cur_gx, cur_gy);

    var stack = ds_list_create();
    ds_list_add(stack, { gx: cur_gx, gy: cur_gy });

    var dirs = dgGraphNeighbors4();

    while (ds_map_size(graph) < target && ds_list_size(stack) > 0) {
        var idx = irandom(ds_list_size(stack)-1);
        var cur = stack[| idx];
        cur_gx = cur.gx; cur_gy = cur.gy;

        var order = [0,1,2,3];
        array_shuffle(order);

        var placed = false;
        for (var i = 0; i < 4 && !placed; i++) {
            var d = dirs[order[i]];
            var nx = cur_gx + d.dx;
            var ny = cur_gy + d.dy;
            var k = dgGraphKey(nx, ny);

            if (!ds_map_exists(graph, k) && abs(nx) <= _cfg.grid_radius && abs(ny) <= _cfg.grid_radius) {
                dgGraphAddNode(graph, nx, ny);

                var cur_key = dgGraphKey(cur_gx, cur_gy);
                var node_cur = ds_map_find_value(graph, cur_key);
                var node_new = ds_map_find_value(graph, k);

                variable_struct_set(node_cur, d.side, k);
                variable_struct_set(node_new, d.opp, cur_key);

                ds_list_add(stack, { gx: nx, gy: ny });
                placed = true;
            }
        }

        if (!placed) ds_list_delete(stack, idx);
    }

    ds_list_destroy(stack);
    return graph;
}
/*
* Name: dgTemplateMatches
* Description: Checks if template exits match needs.
*/
function dgTemplateMatches(_tmpl, _n, _e, _s, _w) {
    return (_tmpl.exitN == _n)
        && (_tmpl.exitE == _e)
        && (_tmpl.exitS == _s)
        && (_tmpl.exitW == _w);
}
/*
* Name: dgAssignTemplates
* Description: Assigns templates to nodes based on exits.
*/
function dgAssignTemplates(_cfg, _graph, _roomdb) {
    var keys = ds_map_keys(_graph);
    for (var i = 0; i < array_length(keys); i++) {
        var key = keys[i];
        var node = ds_map_find_value(_graph, key);

        var needN = is_string(node.N);
        var needE = is_string(node.E);
        var needS = is_string(node.S);
        var needW = is_string(node.W);

        var options = [];
        for (var t = 0; t < array_length(_roomdb); t++) {
            if (dgTemplateMatches(_roomdb[t], needN, needE, needS, needW)) {
                array_push(options, t);
            }
        }

        if (array_length(options) == 0) options[0] = 0;
        node.tmpl_index = options[irandom(array_length(options)-1)];
    }
}
/*
* Name: dgLayerRequire
* Description: Ensures tile layer exists.
*/
function dgLayerRequire(_name, _tileset) {
    var lid = layer_get_id(_name);
    if (lid == -1) {
        lid = layer_create(-100);
        layer_set_name(lid, _name);
    }
    var tid = layer_tilemap_get_id(lid);
    if (tid == -1) {
        tid = layer_tilemap_create(lid, 0, 0, _tileset, 32, 32);
    } else {
        tilemap_set_tileset(tid, _tileset);
    }
    return tid;
}
/*
* Name: dgTilePaintRoom
* Description: Paints a template into tilemaps.
*/
function dgTilePaintRoom(_cfg, _node, _tmpl, _walk_tm, _coll_tm) {
    var w = _cfg.room_cell_w;
    var h = _cfg.room_cell_h;
    var base_c = _node.gx * w;
    var base_r = _node.gy * h;

    for (var r = 0; r < h; r++) {
        for (var c = 0; c < w; c++) {
            tilemap_set(_walk_tm, base_c+c, base_r+r, _tmpl.walk[r][c]);
            tilemap_set(_coll_tm, base_c+c, base_r+r, _tmpl.coll[r][c]);
        }
    }
}
/*
* Name: dgBuildFloorIntoRoom
* Description: Clears + paints all rooms into layers.
*/
function dgBuildFloorIntoRoom(_cfg, _graph, _roomdb) {
    var walk_tm = dgLayerRequire(_cfg.walk_layer_name, _cfg.walk_tileset);
    var coll_tm = dgLayerRequire(_cfg.coll_layer_name, _cfg.coll_tileset);

    var keys = ds_map_keys(_graph);
    for (var i = 0; i < array_length(keys); i++) {
        var node = ds_map_find_value(_graph, keys[i]);
        var tmpl = _roomdb[node.tmpl_index];
        dgTilePaintRoom(_cfg, node, tmpl, walk_tm, coll_tm);
    }
}
/*
* Name: dgGenerateFloor
* Description: Master function to build a floor.
*/
function dgGenerateFloor(_cfg_override) {
    var cfg = dgConfigDefault();
    if (is_struct(_cfg_override)) {
        var keys = variable_struct_get_names(_cfg_override);
        for (var i = 0; i < array_length(keys); i++) {
            var k = keys[i];
            if (variable_struct_exists(cfg, k)) variable_struct_set(cfg, k, variable_struct_get(_cfg_override, k));
        }
    }

    dgRngInit(cfg);

    var graph = dgLayoutBuild(cfg);
    var roomdb = dgRoomdbBuildExamples(cfg);
    dgAssignTemplates(cfg, graph, roomdb);
    dgBuildFloorIntoRoom(cfg, graph, roomdb);

    return graph;
}
