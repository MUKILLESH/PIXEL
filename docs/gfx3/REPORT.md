# GFX-3 — Floodmill visual overhaul

Original region-local artwork for Chapter 2, built with the installed Godot 4.7.2 Compatibility renderer. The supplied images informed weathered mill architecture, drowned streets, cutaway shelves and reclaimed stone. No reference-image pixels, downloaded assets or new dependencies are included.

## Implementation

- Shaded roof shingles, missing tiles, cracked masonry, damp plaster, timber braces, boarded doors, hinges, tower windows and moss. Existing building origins, doors and collision polygons are retained.
- Larger 19-pixel-radius mill wheel (previously 16), with thickness, radial spokes, paddles, support braces and hub. The unrepaired wheel is stationary with missing paddles; the restored wheel turns, fills its paddles and gains foam and warm windows.
- Wet cobbles, shallow flooded gardens, silt, broken planks, stepped canal banks, reeds, algae and directional highlights. The original sluice state renderer still controls the submerged/drained crossing.
- Archive floorboards and threshold, varied book heights and spine bands, cracked gallery columns, reading bench, parchment and candles. Existing independently sorted bookshelf bays remain intact.
- Stepped Second Beacon platform, runic paving, ornamental pillars, faceted crystal, gold framing and a narrow restored light column with sparse motes.
- Clustered marsh willows, moving reeds and low mist. A stall, overturned cart, wooden toy boat, torn notice and family memorial form small non-blocking story vignettes.

Native scale stays 640 x 360, nearest-filtered and integer-scaled. The palette uses blue-gray stone, gray-green marsh vegetation, weathered ochre timber, dark teal water and restrained amber/cyan accents.

## Rendering and asset manifest

Static terrain and buildings are rendered offline to RGBA PNGs. Runtime drawing retains texture references in a region-local cache. The wheel redraws independently at 10 Hz, water at 10 Hz, and air effects approximately 8 Hz. No full building redraw occurs for wheel rotation.

| Family | Count | Dimensions / origin | Source |
| --- | --- | --- | --- |
| Building textures | 5, including both mill states | 192 x 192, feet (96,160) | floodmill_building.gd |
| Prop textures | 7 | 128 x 128, feet (64,112) | floodmill_prop.gd / floodmill_art.gd |
| Static floor | 1 | 2048 x 1024, world origin (1024,512) | floodmill_ground.gd |
| Marsh tiles | 6 in one atlas | 64 x 32 diamonds | generate_floodmill_tiles.gd |

All artwork is original project code-generated art, authorized by the brief; no third-party asset licence is required. All 13 baked textures pass dimension and transparent-border checks. Source art is retained.

Regenerate from the project directory using the installed Godot console executable:

1. --headless --path . --script res://scripts/tools/generate_floodmill_tiles.gd --quit-after 120
2. --path . --script res://scripts/tools/bake_floodmill_art.gd --quit-after 2000 -- --bake-floodmill
3. --headless --path . --import --quit-after 500

The bake step needs graphical rendering. It never reads or writes player saves.

## Before / after

Identical player positions, camera framing, viewport sizes and progression flags. Close views are 640 x 360; overview is 960 x 540. Animation phase may differ. The objective intentionally remains the same in all captures.

| View | Before | After |
| --- | --- | --- |
| Entrance / village square | [Before](before_square.png) | [After](after_square.png) |
| Broken mill | [Before](before_mill_broken.png) | [After](after_mill_broken.png) |
| Running mill | [Before](before_mill_running.png) | [After](after_mill_running.png) |
| Flooded canal | [Before](before_canal_flooded.png) | [After](after_canal_flooded.png) |
| Drained canal | [Before](before_canal_drained.png) | [After](after_canal_drained.png) |
| Archive | [Before](before_archive.png) | [After](after_archive.png) |
| Dormant beacon | [Before](before_beacon_dormant.png) | [After](after_beacon_dormant.png) |
| Restored beacon | [Before](before_beacon_restored.png) | [After](after_beacon_restored.png) |
| Overview | [Before](before_overview.png) | [After](after_overview.png) |

Use tests/capture_gfx3.gd with --quit-after 6000; append -- --measure for timing. Baseline branch: checkpoint/gfx3-before-59f659b (copy the capture helper into that checkout when reproducing baseline images).

## Validation and scope

- Headless import and bounded Floodmill startup smoke: clean.
- validate_phase3.gd: **129 checks, 0 failures**, including physical movement, repair, sluices, archive records, ledger, beacon, transitions, save/reload, v1 migration and backup recovery.
- validate_gfx3.gd: **18/18 interaction approaches reachable**, 5,074 physics-space cells explored with drained causeway; **13/13 raster contracts passed**.
- Collision setup, archive structure and world-state synchronization methods compared unchanged against the checkpoint; see preservation_audit.log.
- Shared quest/save logic (versions 1–5), dialogue, movement, inventory and other chapters are untouched.
- All nine views inspected for missing textures, player visibility, prompt overlap and progression-state differences. A temporary texture-lifetime rendering bug was fixed before final validation.

Open scenes/floodmill_village.tscn and press F6 to review directly. F5 still starts Bellhaven. No Windows executable was rebuilt.

## Remaining limitations

Architecture keeps the original compact footprints and silhouettes, limiting readable detail at native resolution. Repeated paving and vegetation remain visible at overview scale. Decorative vignettes are intentionally non-blocking. Prompts retain their existing placement and can cross tall artwork. Full manual free-roaming occlusion inspection and extended traversal profiling remain outside this focused pass.

## Measured performance

RTX 4050 Laptop GPU, Compatibility/OpenGL, native 640 x 360 in a 1280 x 720 window. Each position has one second of warmup and 240 process-frame wall-clock samples, with restored mill and beacon animation active. Tests were not running concurrently with the final profile.

| Position | Mean ms | p95 ms | Maximum ms |
| --- | ---: | ---: | ---: |
| Old Watermill | 16.67 | 16.69 | 16.79 |
| Forgotten Archive | 16.67 | 16.69 | 16.79 |
| Second Beacon | 16.67 | 16.69 | 16.70 |

These samples support approximately 60 FPS at the three measured stationary views, rather than inferring performance from the cap. They are short samples, not GPU profiler timings or a guarantee for all traversal situations. See performance.log for raw output (before the final ground-label-only adjustment).
