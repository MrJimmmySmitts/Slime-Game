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
* Name: dgConfigFail
* Description: Raises a fatal dungeon-generation configuration error.
*/
function dgConfigFail(_message) {
    show_error("[DungeonGen] " + string(_message), true);
}

/*
* Name: dgFunctionExists
* Description: Compatibility wrapper for runtimes that lack function_exists().
*/
function dgFunctionExists(_name) {
    if (!is_string(_name) || _name == "") {
        return false;
    }

    if (is_undefined(global.__dgFunctionExistsCache)) {
        global.__dgFunctionExistsCache = {};
    }

    var cache = global.__dgFunctionExistsCache;
    if (variable_struct_exists(cache, _name)) {
        return variable_struct_get(cache, _name);
    }

    var override = undefined;
    if (variable_global_exists("__dgFunctionExistsOverrides")) {
        var overrides = global.__dgFunctionExistsOverrides;
        if (is_struct(overrides) && variable_struct_exists(overrides, _name)) {
            override = variable_struct_get(overrides, _name);
        }
    }

    if (is_undefined(override) && variable_global_exists("Game")) {
        var G = global.Game;
        if (is_struct(G) && variable_struct_exists(G, "runtime_features")) {
            var runtime_features = G.runtime_features;
            if (is_struct(runtime_features) && variable_struct_exists(runtime_features, _name)) {
                override = variable_struct_get(runtime_features, _name);
            }
        }
    }

    var exists = false;
    if (!is_undefined(override)) {
        exists = override;
    } else {
        var idx = asset_get_index(_name);
        if (idx != -1 && script_exists(idx)) {
            exists = true;
        }
    }

    variable_struct_set(cache, _name, exists);
    return exists;
}

/*
* Name: dgTilesetMetricsFallback
* Description: Provides manual tile dimensions when runtime queries are unavailable.
*/
function dgTilesetMetricsFallback(_tileset_id) {
    var key = string(_tileset_id);

    if (variable_global_exists("Game")) {
        var G = global.Game;
        if (is_struct(G) && variable_struct_exists(G, "dungeon_gen")) {
            var dg = G.dungeon_gen;
            if (is_struct(dg) && variable_struct_exists(dg, "tileset_metrics")) {
                var overrides = dg.tileset_metrics;
                if (is_struct(overrides) && variable_struct_exists(overrides, key)) {
                    var entry_override = variable_struct_get(overrides, key);
                    if (is_struct(entry_override)
                        && variable_struct_exists(entry_override, "w")
                        && variable_struct_exists(entry_override, "h")) {
                        return { w: entry_override.w, h: entry_override.h };
                    }
                }
            }
        }
    }

    static defaults = undefined;
    if (is_undefined(defaults)) {
        defaults = {};

        var ts_walk_id = asset_get_index("ts_walk");
        if (ts_walk_id != -1) {
            variable_struct_set(defaults, string(ts_walk_id), { w: 16, h: 16 });
        }

        var ts_coll_id = asset_get_index("ts_coll");
        if (ts_coll_id != -1) {
            variable_struct_set(defaults, string(ts_coll_id), { w: 16, h: 16 });
        }

        var ts_basic_id = asset_get_index("ts_basic");
        if (ts_basic_id != -1) {
            variable_struct_set(defaults, string(ts_basic_id), { w: 16, h: 16 });
        }
    }

    if (!is_undefined(defaults) && variable_struct_exists(defaults, key)) {
        var entry_default = variable_struct_get(defaults, key);
        return { w: entry_default.w, h: entry_default.h };
    }

    return undefined;
}

/*
* Name: dgConfigEnsureTilesetId
* Description: Resolves a tileset asset reference (numeric id or name string).
*/
function dgConfigEnsureTilesetId(_value, _field_name) {
    if (is_numeric(_value)) {
        return _value;
    }
    if (is_string(_value)) {
        var idx = asset_get_index(_value);
        if (idx == -1) {
            dgConfigFail(_field_name + " references missing tileset '" + _value + "'.");
        }
        return idx;
    }
    if (is_undefined(_value)) {
        dgConfigFail(_field_name + " is undefined; supply a valid tileset asset.");
    }
    dgConfigFail(_field_name + " must be a tileset asset id or asset name string.");
    return -1;
}

/*
* Name: dgConfigValidate
* Description: Validates and normalizes dungeon generator configuration.
*/
function dgConfigValidate(_cfg) {
    if (!is_numeric(_cfg.room_count_min)) {
        dgConfigFail("room_count_min must be an integer >= 1.");
    }
    _cfg.room_count_min = floor(_cfg.room_count_min);
    if (_cfg.room_count_min < 1) {
        dgConfigFail("room_count_min must be >= 1.");
    }

    if (!is_numeric(_cfg.room_count_max)) {
        dgConfigFail("room_count_max must be an integer >= room_count_min.");
    }
    _cfg.room_count_max = floor(_cfg.room_count_max);
    if (_cfg.room_count_max < _cfg.room_count_min) {
        dgConfigFail("room_count_max must be >= room_count_min.");
    }

    if (!is_numeric(_cfg.grid_radius)) {
        dgConfigFail("grid_radius must be an integer >= 1.");
    }
    _cfg.grid_radius = floor(_cfg.grid_radius);
    if (_cfg.grid_radius < 1) {
        dgConfigFail("grid_radius must be >= 1.");
    }

    if (!is_numeric(_cfg.room_cell_w)) {
        dgConfigFail("room_cell_w must be an integer >= 1.");
    }
    _cfg.room_cell_w = floor(_cfg.room_cell_w);
    if (_cfg.room_cell_w < 1) {
        dgConfigFail("room_cell_w must be >= 1.");
    }

    if (!is_numeric(_cfg.room_cell_h)) {
        dgConfigFail("room_cell_h must be an integer >= 1.");
    }
    _cfg.room_cell_h = floor(_cfg.room_cell_h);
    if (_cfg.room_cell_h < 1) {
        dgConfigFail("room_cell_h must be >= 1.");
    }

    if (!is_string(_cfg.walk_layer_name) || _cfg.walk_layer_name == "") {
        dgConfigFail("walk_layer_name must be a non-empty string.");
    }

    if (!is_string(_cfg.coll_layer_name) || _cfg.coll_layer_name == "") {
        dgConfigFail("coll_layer_name must be a non-empty string.");
    }

    if (!is_numeric(_cfg.seed)) {
        dgConfigFail("seed must be numeric (use -1 for randomise).");
    }
    _cfg.seed = floor(_cfg.seed);

    if (_cfg.allow_room_rotation != true && _cfg.allow_room_rotation != false) {
        dgConfigFail("allow_room_rotation must be true or false.");
    }

    _cfg.walk_tileset = dgConfigEnsureTilesetId(_cfg.walk_tileset, "walk_tileset");
    _cfg.coll_tileset = dgConfigEnsureTilesetId(_cfg.coll_tileset, "coll_tileset");

    return _cfg;
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
    var key = ds_map_find_first(_graph);
    while (!is_undefined(key)) {
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
        key = ds_map_find_next(_graph, key);
    }
}
/*
* Name: dgTilesetMetrics
* Description: Resolves and caches tile dimensions for a tileset.
*/
function dgTilesetMetrics(_tileset_id, _layer_name, _existing_tid) {
    if (is_undefined(global.__dgTilesetMetrics)) {
        global.__dgTilesetMetrics = {};
    }

    var key = string(_tileset_id);
    if (variable_struct_exists(global.__dgTilesetMetrics, key)) {
        return variable_struct_get(global.__dgTilesetMetrics, key);
    }

    if (dgFunctionExists("tileset_get_tile_width") && dgFunctionExists("tileset_get_tile_height")) {
        var builtin_w = tileset_get_tile_width(_tileset_id);
        var builtin_h = tileset_get_tile_height(_tileset_id);
        if (builtin_w > 0 && builtin_h > 0) {
            var metrics_builtin = { w: builtin_w, h: builtin_h };
            variable_struct_set(global.__dgTilesetMetrics, key, metrics_builtin);
            return metrics_builtin;
        }
    }

    if (_existing_tid != -1) {
        if (dgFunctionExists("tilemap_get_tile_width") && dgFunctionExists("tilemap_get_tile_height")) {
            var width = tilemap_get_tile_width(_existing_tid);
            var height = tilemap_get_tile_height(_existing_tid);
            if (width > 0 && height > 0) {
                var metrics_existing = { w: width, h: height };
                variable_struct_set(global.__dgTilesetMetrics, key, metrics_existing);
                return metrics_existing;
            }
        }
    }

    var metrics_fallback = dgTilesetMetricsFallback(_tileset_id);
    if (!is_undefined(metrics_fallback)) {
        variable_struct_set(global.__dgTilesetMetrics, key, metrics_fallback);
        return metrics_fallback;
    }

    dgConfigFail("Unable to determine tile dimensions for tileset id " + string(_tileset_id)
        + " while binding layer '" + _layer_name + "'. Ensure a tile layer exists in the room or configure a fallback via global.Game.dungeon_gen.tileset_metrics.");
    return { w: 0, h: 0 };
}
/*
* Name: dgLayerRequire
* Description: Ensures tile layer exists.
*/
function dgLayerRequire(_name, _tileset) {
    var tileset_id = dgConfigEnsureTilesetId(_tileset, "layer '" + _name + "'");
    var lid = layer_get_id(_name);
    if (lid == -1) {
        lid = layer_create(-100);
        layer_set_name(lid, _name);
    }
    var tid = layer_tilemap_get_id(lid);

    var has_tilemap_set_tile_width = dgFunctionExists("tilemap_set_tile_width");
    var has_tilemap_set_tile_height = dgFunctionExists("tilemap_set_tile_height");
    var has_tilemap_set_tileset = dgFunctionExists("tilemap_set_tileset");
    var has_tilemap_get_tileset = dgFunctionExists("tilemap_get_tileset");

    var need_metrics = (tid == -1)
        || has_tilemap_set_tile_width
        || has_tilemap_set_tile_height;
    var metrics = undefined;
    if (need_metrics) {
        metrics = dgTilesetMetrics(tileset_id, _name, tid);
    }

    if (tid == -1) {
        tid = layer_tilemap_create(lid, 0, 0, tileset_id, metrics.w, metrics.h);
    } else {
        if (has_tilemap_set_tileset) {
            tilemap_set_tileset(tid, tileset_id);
            if (has_tilemap_set_tile_width && !is_undefined(metrics)) tilemap_set_tile_width(tid, metrics.w);
            if (has_tilemap_set_tile_height && !is_undefined(metrics)) tilemap_set_tile_height(tid, metrics.h);
        } else {
            if (has_tilemap_get_tileset) {
                var current_tileset = tilemap_get_tileset(tid);
                if (current_tileset != tileset_id) {
                    dgConfigFail("layer '" + _name + "' is bound to an unexpected tileset and the runtime lacks tilemap_set_tileset().");
                }
            }
        }
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

    var key = ds_map_find_first(_graph);
    while (!is_undefined(key)) {
        var node = ds_map_find_value(_graph, key);
        var tmpl = _roomdb[node.tmpl_index];
        dgTilePaintRoom(_cfg, node, tmpl, walk_tm, coll_tm);
        key = ds_map_find_next(_graph, key);
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

    dgConfigValidate(cfg);
    dgRngInit(cfg);

    var graph = dgLayoutBuild(cfg);
    var roomdb = dgRoomdbBuildExamples(cfg);
    dgAssignTemplates(cfg, graph, roomdb);
    dgBuildFloorIntoRoom(cfg, graph, roomdb);

    return graph;
}
