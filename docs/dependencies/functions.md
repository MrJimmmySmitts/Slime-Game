

---

## Behavior Updates — v0.2.1.14
**Generated:** 2025-09-08 08:31 (local)

- `enemy_resolve_tilemap()` now **directly** targets the tilemap layer named `tm_collision` and caches its tilemap id. No fallback or auto-detection is used.
  - Recommended implementation:
    ```gml
    /*
    * Name: enemy_resolve_tilemap
    * Description: Resolve the collision tilemap from the layer named "tm_collision".
    */
    function enemy_resolve_tilemap() {
        var _lid = layer_get_id("tm_collision");
        enemy_tm = (_lid != -1) ? layer_tilemap_get_id(_lid) : noone;
    }
    ```
