# GFX-5 — Dawnspire Mountain

Completed from 530504c. Checkpoint: checkpoint/gfx5-before-530504c. Scope is Dawnspire rendering only; the separate GFX-6 worktree was not accessed. No Windows export was rebuilt.

## Implementation

- Cached original pixel art: nine architecture states, a separate chapel interior and one terrain/background texture.
- Layered distant peaks, visible escarpments and ravine facets, frost, granite tongues, alpine grass clusters and irregular pine silhouettes. The eastern x=280 and southern y=210 fall-reset thresholds are explicitly marked.
- Skybridge plank grain, chains, winch gears and counterweights; broken decking and uneven weights become a continuous crossing with balanced weights when the existing repair flag changes.
- Pilgrim chapel: bronze-framed stained glass, timber roof courses, candles, benches, memorial stones and warm floor treatment around Elena's existing journal.
- Observatory: nested bronze astrolabe rings, indexed rim, Sun/Moon/Star reliefs, stepped mosaic platform and engraved pillar accents.
- Sanctuary and Great Bell Gate: taller fluted columns, bronze chains, cornices, faceted crystals and lit/unlit portal textures. The existing three channels, rune effects and progression flags remain intact.
- Static art is baked; small wind/bridge/magic drawing remains separate. New atmosphere updates at 8 Hz and stays outside the hazard lane. Ground sits below the existing cutaway chapel layer. Nearest filtering and native 640×360 rendering are preserved.

All art is locally authored GDScript geometry, rasterized through Godot. References informed shape and palette only; no external pixels, dependencies or downloads were used. See [asset manifest](asset_manifest.json), [contact sheet](asset_sheet.png), [sprite QA](asset_report.json) and [ground QA](ground_report.json).

## Matching comparisons

Normal views are 640×360; overview is 960×720. Both runs use identical positions, framing and progression flags. The harness freezes movement and hazard recovery only for captures, without changing production behavior.

| View | Before | After |
| --- | --- | --- |
| Foothills | [Before](before_foothills.png) | [After](after_foothills.png) |
| Whispering Cliffs | [Before](before_cliffs.png) | [After](after_cliffs.png) |
| Broken Skybridge | [Before](before_bridge_broken.png) | [After](after_bridge_broken.png) |
| Repaired Skybridge | [Before](before_bridge_repaired.png) | [After](after_bridge_repaired.png) |
| Pilgrim's Refuge | [Before](before_refuge.png) | [After](after_refuge.png) |
| Observatory | [Before](before_observatory.png) | [After](after_observatory.png) |
| Sanctuary inactive | [Before](before_sanctuary_inactive.png) | [After](after_sanctuary_inactive.png) |
| Sanctuary activated | [Before](before_sanctuary_active.png) | [After](after_sanctuary_active.png) |
| Great Bell Gate | [Before](before_gate.png) | [After](after_gate.png) |
| Full overview | [Before](before_overview.png) | [After](after_overview.png) |

All ten views were inspected at native scale, along with the asset sheet. Review fixes included chapel layer visibility, reduced background contrast and smaller translucent building shadows.

## Validation

- Headless Godot import: clean.
- tests/validate_phase5.gd: **113 checks, 0 failures**. Includes wind/checkpoint recovery, Skybridge and celestial puzzles, Chapter 4 progression, save restore, legacy migration and backup recovery.
- Focused physics reachability: **23/23 targets**, 2,903 cells, **0 failures**. Six-pixel-radius probe on an eight-pixel grid, within 28 pixels of each target, with progression blockers opened.
- Raster checks: **11 textures**, correct dimensions; transparent sprite margins; no palette-budget failures (maximum 256 colors).
- Bounded Dawnspire startup and final graphical capture/profile: clean; ten captures completed.
- Preservation audit: building/prop collision setup, interactable behavior and wind/checkpoint drawing compare unchanged. dawnspire_region.gd, dawnspire_mountain.tscn and quest_manager.gd have no diff. Player, inventory, save architecture, dialogue, NPC relocation, transitions and other chapters were not edited.

Logs are retained in this directory. The capture helper stops the existing audio manager before exit; it does not change the audio system.

## Performance

Godot 4.7.2 Compatibility/OpenGL on NVIDIA RTX 4050 Laptop GPU, native 640×360, window 1280×720. Each sample uses 240 frame intervals after one second of warmup. Locations are stationary; effects run, movement/recovery is frozen by the harness. Both paced and uncapped samples use the same setup before and after.

| Location | Before uncapped mean / p95 / max ms | After uncapped mean / p95 / max ms | After paced mean / p95 / max ms |
| --- | --- | --- | --- |
| Cliffs | 0.71 / 0.82 / 0.95 | 1.02 / 1.19 / 1.31 | 16.66 / 16.70 / 16.76 |
| Observatory | 0.84 / 1.17 / 1.84 | 1.08 / 1.21 / 1.44 | 16.66 / 16.70 / 16.97 |
| Sanctuary | 0.78 / 0.91 / 1.17 | 1.04 / 1.19 / 1.47 | 16.66 / 16.69 / 16.73 |

The art adds modest frame cost while these samples retain substantial headroom beneath 16.67 ms. Paced results are consistent with 60 FPS. These are short end-to-end frame interval samples, not isolated GPU measurements or a whole-playthrough benchmark.

## Files

Modified:
- scripts/world/dawnspire_building.gd — cached architecture and cutaway interior
- scripts/world/dawnspire_landscape.gd — cached terrain plus original state overlays
- scripts/world/dawnspire_prop.gd — pine rendering
- scripts/interactables/dawnspire_interactable.gd — visual-only relief, ring and crystal overlays

Created:
- scripts/world/dawnspire_art.gd — original drawing primitives, architecture, bridge and pine source
- scripts/world/dawnspire_ground.gd — offline terrain source
- scripts/world/dawnspire_air.gd — bounded local atmosphere
- scripts/tools/bake_dawnspire_art.gd — offline raster generator
- assets/dawnspire/*.png and import metadata — all 11 assets listed in the manifest
- tests/capture_gfx5.gd, tests/validate_gfx5.gd — reproducible captures/profile and focused validation
- docs/gfx5/ — comparisons, manifest, report and logs

## Launch and regeneration

Open scenes/dawnspire_mountain.tscn and press F6. F5 retains the existing game startup and progression.

From the project root:
    ./Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/validate_gfx5.gd
    ./Godot_v4.7.2-stable_win64_console.exe --path . --script res://tests/capture_gfx5.gd --quit-after 12000 -- --measure

After editing static art sources, run scripts/tools/bake_dawnspire_art.gd with the graphical engine, then reimport. Normal gameplay never runs the generator.

## Remaining manual checks

Walk the complete route with active wind to review moving occlusion and hazard-edge readability, especially beside the shelter and chapel. Test puzzle panels and sanctuary cinematics visually during a normal playthrough. Existing HUD objective text in the fixed-state captures still reflects the initial quest because the harness sets flags without replaying story progression.

Terrain deliberately preserves the compact rectangular navigation footprint; it does not introduce real vertical traversal. The cliff strata and background peaks remain stylized and somewhat repetitive at overview scale. New non-blocking scenery does not redefine collision boundaries. The short stationary profiling samples do not establish performance on other machines.
