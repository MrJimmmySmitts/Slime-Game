/*
* Name: dg_config_default
* Description: Returns a struct with default generator settings.
*/
function dg_config_default() {
    return {
        room_count_min: 8,
        room_count_max: 12,
        grid_radius: 8,

        room_cell_w: 16,
        room_cell_h: 12,

        walk_tileset: ts_ground,
        coll_tileset: ts_walls,

        walk_layer_name: "Terrain_Walk",
        coll_layer_name: "Terrain_Collide",

        allow_room_rotation: false,
        seed: -1
    };
}

/*
* Name: dg_rng_init
* Description: Initializes RNG based on config seed.
*/
function dg_rng_init(_cfg) {
    if (_cfg.seed != -1) random_set_seed(_cfg.seed);
    else randomize();
}
/*
* Name: dg_room_template_new
* Description: Creates a room template with exits + tile arrays.
*/
function dg_room_template_new(_name, _exN, _exE, _exS, _exW, _walk_grid, _coll_grid) {
    return {
        name: _name,
        exitN: _exN, exitE: _exE, exitS: _exS, exitW: _exW,
        walk: _walk_grid,
        coll: _coll_grid
    };
}
/*
* Name: dg_roomdb_build_examples
* Description: Returns a small set of example room templates.
*/
function dg_roomdb_build_examples(_cfg) {
    var w = _cfg.room_cell_w;
    var h = _cfg.room_cell_h;

    var ground = array_create(h);
    for (var r = 0; r < h; r++) ground[r] = array_create(w, 1);

    function make_room(_name, _exN, _exE, _exS, _exW) {
        var walk = ground;
        var coll = array_create(h);
        for (var r = 0; r < h; r++) coll[r] = array_create(w, 0);

        // walls around border
        for (var c = 0; c < w; c++) { coll[0][c] = 2; coll[h-1][c] = 2; }
        for (var r2 = 0; r2 < h; r2++) { coll[r2][0] = 2; coll[r2][w-1] = 2; }

        var midx = w div 2;
        var midy = h div 2;

        if (_exN) coll[0][midx] = 0;
        if (_exS) coll[h-1][midx] = 0;
        if (_exW) coll[midy][0] = 0;
        if (_exE) coll[midy][w-1] = 0;

        return dg_room_template_new(_name, _exN, _exE, _exS, _exW, walk, coll);
    }

    return [
        make_room("Cross", true, true, true, true),
        make_room("NS", true, false, true, false),
        make_room("EW", false, true, false, true),
        make_room("Corner_NE", true, true, false, false),
        make_room("Corner_ES", false, true, true, false),
        make_room("Corner_SW", false, false, true, true),
        make_room("Corner_WN", true, false, false, true),
        make_room("DeadN", true, false, false, false),
        make_room("DeadE", false, true, false, false),
        make_room("DeadS", false, false, true, false),
        make_room("DeadW", false, false, false, true)
    ];
}
/*
* Name: dg_graph_key
* Description: Converts grid coords to a unique key.
*/
function dg_graph_key(_gx, _gy) {
    return string(_gx) + ":" + string(_gy);
}

/*
* Name: dg_graph_add_node
* Description: Adds node to graph.
*/
function dg_graph_add_node(_map, _gx, _gy) {
    var key = dg_graph_key(_gx, _gy);
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
* Name: dg_graph_neighbors4
* Description: NESW neighbor offsets.
*/
function dg_graph_neighbors4() {
    return [
        { dx: 0, dy: -1, side: "N", opp: "S" },
        { dx: 1, dy:  0, side: "E", opp: "W" },
        { dx: 0, dy:  1, side: "S", opp: "N" },
        { dx: -1, dy: 0, side: "W", opp: "E" }
    ];
}
/*
* Name: dg_layout_build
* Description: Builds a connected layout graph.
*/
function dg_layout_build(_cfg) {
    var target = irandom_range(_cfg.room_count_min, _cfg.room_count_max);
    var graph = ds_map_create();

    var cur_gx = 0, cur_gy = 0;
    dg_graph_add_node(graph, cur_gx, cur_gy);

    var stack = ds_list_create();
    ds_list_add(stack, { gx: cur_gx, gy: cur_gy });

    var dirs = dg_graph_neighbors4();

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
            var k = dg_graph_key(nx, ny);

            if (!ds_map_exists(graph, k) && abs(nx) <= _cfg.grid_radius && abs(ny) <= _cfg.grid_radius) {
                dg_graph_add_node(graph, nx, ny);

                var cur_key = dg_graph_key(cur_gx, cur_gy);
                var node_cur = ds_map_find_value(graph, cur_key);
                var node_new = ds_map_find_value(graph, k);

                node_cur[? d.side] = k;
                node_new[? d.opp] = cur_key;

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
* Name: dg_template_matches
* Description: Checks if template exits match needs.
*/
function dg_template_matches(_tmpl, _n, _e, _s, _w) {
    return (_tmpl.exitN == _n)
        && (_tmpl.exitE == _e)
        && (_tmpl.exitS == _s)
        && (_tmpl.exitW == _w);
}
/*
* Name: dg_assign_templates
* Description: Assigns templates to nodes based on exits.
*/
function dg_assign_templates(_cfg, _graph, _roomdb) {
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
            if (dg_template_matches(_roomdb[t], needN, needE, needS, needW)) {
                array_push(options, t);
            }
        }

        if (array_length(options) == 0) options[0] = 0;
        node.tmpl_index = options[irandom(array_length(options)-1)];
    }
}
/*
* Name: dg_layer_require
* Description: Ensures tile layer exists.
*/
function dg_layer_require(_name, _tileset) {
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
* Name: dg_tile_paint_room
* Description: Paints a template into tilemaps.
*/
function dg_tile_paint_room(_cfg, _node, _tmpl, _walk_tm, _coll_tm) {
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
* Name: dg_build_floor_into_room
* Description: Clears + paints all rooms into layers.
*/
function dg_build_floor_into_room(_cfg, _graph, _roomdb) {
    var walk_tm = dg_layer_require(_cfg.walk_layer_name, _cfg.walk_tileset);
    var coll_tm = dg_layer_require(_cfg.coll_layer_name, _cfg.coll_tileset);

    var keys = ds_map_keys(_graph);
    for (var i = 0; i < array_length(keys); i++) {
        var node = ds_map_find_value(_graph, keys[i]);
        var tmpl = _roomdb[node.tmpl_index];
        dg_tile_paint_room(_cfg, node, tmpl, walk_tm, coll_tm);
    }
}
/*
* Name: dg_generate_floor
* Description: Master function to build a floor.
*/
function dg_generate_floor(_cfg_override) {
    var cfg = dg_config_default();
    if (is_struct(_cfg_override)) {
        var keys = variable_struct_get_names(_cfg_override);
        for (var i = 0; i < array_length(keys); i++) {
            var k = keys[i];
            if (variable_struct_exists(cfg, k)) variable_struct_set(cfg, k, variable_struct_get(_cfg_override, k));
        }
    }

    dg_rng_init(cfg);

    var graph = dg_layout_build(cfg);
    var roomdb = dg_roomdb_build_examples(cfg);
    dg_assign_templates(cfg, graph, roomdb);
    dg_build_floor_into_room(cfg, graph, roomdb);

    return graph;
}
