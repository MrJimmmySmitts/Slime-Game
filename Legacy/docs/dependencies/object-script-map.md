# Slime Game — Object → Script Usage Map (v0.2.1.15)

**Generated:** 2025-09-08 08:36 (local)
This table lists each object/event and the _repository-defined_ functions it calls (GameMaker built-ins omitted).

| Object | Event | Calls / Key Scripts |
|---|---|---|
| `obj_player` | `Create_0.gml` | _(no external script calls detected)_ |
| `obj_player` | `Step_0.gml` | `on_pause_exit()`, `input_get_move_axis()`, `input_get_aim_axis()`, `input_dash_pressed()`, `pmove_apply()`, `weapon_fire_bullet()` |
| `obj_player` | `Draw_0.gml` | `input_get_aim_axis()` |
| `obj_player` | `Collision_obj_slime_1.gml` | `inv_add_or_drop()` |
| `obj_player` | `Collision_obj_slime_2.gml` | `inv_add_or_drop()` |
| `obj_inventory` | `Create_0.gml` | _(no external script calls detected)_ |
| `obj_inventory` | `Step_0.gml` | _(no external script calls detected)_ |
| `obj_inventory` | `Draw_64.gml` | `inv_panel_get_origin()` |
| `obj_bullet` | `Create_0.gml` | _(no external script calls detected)_ |
| `obj_bullet` | `Step_0.gml` | `on_pause_exit()` |
| `obj_bullet` | `Collision_obj_enemy.gml` | _(no external script calls detected)_ |
| `obj_bullet` | `Collision_obj_enemy_parent.gml` | _(no external script calls detected)_ |
| `obj_enemy` | `Create_0.gml` | `enemy_base_init()`, `enemy_resolve_tilemap()` |
| `obj_enemy` | `Step_0.gml` | `on_pause_exit()`, `enemy_seek_player_step()` |
| `obj_enemy_1` | `Create_0.gml` | _(no external script calls detected)_ |
| `obj_enemy_2` | `Create_0.gml` | _(no external script calls detected)_ |
| `obj_game_controller` | `Create_0.gml` | `game_init()` |
| `obj_menu_controller` | `Create_0.gml` | _(no external script calls detected)_ |
| `obj_menu_controller` | `Step_0.gml` | `inv_toggle()`, `menu_toggle()` |
| `obj_menu_controller` | `Draw_64.gml` | _(no external script calls detected)_ |
| `obj_floor_gen` | `Create_0.gml` | `dg_generate_floor()` |
| `obj_spawner` | `Create_0.gml` | _(no external script calls detected)_ |
| `obj_spawner` | `Step_0.gml` | `on_pause_exit()` |
| `obj_slime_1` | `Create_0.gml` | _(no external script calls detected)_ |
| `obj_slime_2` | `Create_0.gml` | _(no external script calls detected)_ |
| `obj_slime_3` | `Create_0.gml` | _(no external script calls detected)_ |
