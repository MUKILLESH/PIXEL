# SJT exterior delivery

The implementation follows [the pre-implementation asset plan](SJT_ASSET_PLAN.md). All five local photographs and the supplied campus-map image were inspected. No external sources were fetched, no dependencies installed, and no photograph pixels used as runtime artwork.

## Launch

F5 now launches `scenes/sjt_exterior.tscn`. Open that scene for F6. The original `scenes/campus_prototype.tscn` remains intact and playable with F6. Controls are unchanged: WASD, E, E/Escape. Walk toward the entrance canopy, explore the red-edged approaches and front lawn, and find the cyan terminal to the right of spawn.

## Delivered

- Reusable SJT building scene with cream walls, repeated grouped windows, grey central inverted-U feature, projected entrance canopy, rooftop slatted structures, plain roof enclosures, simplified external stair strip and code-native name band.
- Separately sorted facade bays preserve player depth along the long diagonal front. Canopy columns collide while the space below its roof is walkable. The building footprint blocks entry; no interior was invented.
- Small outdoor region: compressed approach roads/red walks, existing trees, shrubs, lawn, curved shallow basin, and abstract monument.
- Relative map relationships retained: open SJT Ground below, lake direction lower-left, PRP direction right. Route labels indicate off-scene directions only, not implemented destinations. No compass accuracy is asserted.
- Existing player, animation, camera, HUD and terminal scenes reused without changes. Region-specific camera framing is (0, -96), giving the taller building room while keeping the player above the HUD. A 57×57-cell scenery apron covers every native viewport corner at the playable boundary.
- `docs/references/.gdignore` keeps the third-party reference directory out of Godot's resource scan. Do not ship the reference folder in a source distribution without checking its rights.

## Validation — 16 November 2026

Godot 4.7.2 Standard / Compatibility:

- 34 SJT behavioral checks passed: stable spawn, footprint, depth-sort structure, walkable canopy approach, diagonal wall collision/sliding, solid columns and landmarks, terminal approach/open/dismiss, and all 16 extreme camera-corner coverage checks.
- All 63 Phase 1.5 regression checks passed.
- 18 scripts compiled, zero broken. Default startup completed a 300-frame headless smoke run without errors.
- Graphical forecourt and entrance captures were inspected at 640×360. A 960×540 native-resolution overview was rendered for layout review, without changing the gameplay resolution.
- During development, fixed a packed-array constant parse error and expanded SJT's ground apron after the coverage tests caught two uncovered corners. The diagonal-wall test was corrected to measure wall distance/contact rather than an axis-aligned stopping position, because normal collision sliding changes both coordinates.

Run SJT checks with:

```powershell
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/validate_sjt.gd
```

Generate review images with `--path . --script res://tests/capture_sjt.gd` (graphical, not headless).

## Accuracy limits

Missing rear/opposite-side photographs, entrance close-ups, roof plan and measured site plan are listed in the asset plan. Window counts, floor/bay spacing, height, canopy dimensions, planting positions and hidden details are compressed or simplified. The sculpture and basin are motif-level interpretations. This is a recognizable game exterior, not an architectural reconstruction or navigation map. No sustained performance benchmark or full hands-on occlusion sweep was performed.

## Files

New: `scenes/sjt_exterior.tscn`, `scenes/environment/sjt_building.tscn`, five `scripts/world/sjt_*.gd` scripts, `tests/validate_sjt.gd`, `tests/capture_sjt.gd`, three SJT review PNGs, `assets/sjt_manifest.json`, the asset plan, this document, and the reference-folder ignore marker. Modified: startup scene setting and documentation. Phase 1.5 gameplay source and scenes are unchanged.

![Original SJT interpretation](../tests/sjt_overview.png)
