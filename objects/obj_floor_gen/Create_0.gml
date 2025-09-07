/*
* Name: obj_floor_gen.Create
* Description: Generates a new dungeon floor at room start.
*/
var cfg_override = {
    room_count_min: 10,
    room_count_max: 14,
    seed: -1
};

floor_graph = dg_generate_floor(cfg_override);
