# Agent Guidelines

- Use `scripts/scr_enemy_config` for default enemy stats so balancing stays centralised.
- Prefer referencing sprites by name via `asset_get_index` and provide graceful fallbacks for missing assets.
- Avoid adding binary assets (e.g., `.png`) in pull requests; reuse existing resources instead.
- When modifying shared logic under `scripts/scr_enemy`, keep helper functions documented with the existing comment headers.
