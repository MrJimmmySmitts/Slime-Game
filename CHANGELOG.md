# Changelog — Slime Game

---

## [0.2.1.14] — 2025-09-08 (AEST)
### Changed
- Enemy collision now resolves **only** from the tilemap layer named `tm_collision`. Removed fallback detection logic.

### Notes
- Ensure a tile layer named exactly `tm_collision` exists in relevant rooms and contains the solid collision tiles.


