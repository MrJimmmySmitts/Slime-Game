# Changelog — Slime Game

---

## [0.2.1.14] — 2025-09-08 (AEST)
### Changed
- Enemy collision now resolves **only** from the tilemap layer named `tm_collision`. Removed fallback detection logic.

### Notes
- Ensure a tile layer named exactly `tm_collision` exists in relevant rooms and contains the solid collision tiles.



## [0.2.1.15] — 2025-09-14 (AEST)
### Added
- Comprehensive function reference with cross-links (`docs/documentation/functions.md`).
- Object to script usage map with links to function reference (`doc/documentation/object-script-map.md`).

### Changed
- Updated `.gitignore` and `.gitattributes` to follow GameMaker (GML) source control guidelines.
