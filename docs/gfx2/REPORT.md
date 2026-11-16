# Briarwood GFX-2

Original, region-local graphics implementation for Chapter 1. Source artwork is authored in GDScript and baked with the installed Godot 4.7.2 Compatibility renderer. The six user-supplied images informed canopy density, mossy ruins, material contrast and restrained cyan magic; none of their pixels are shipped. No downloads or dependencies.

## Visual changes

- Three broadleaf and three pine sprite variants with irregular crowns, leaf clusters, bark, branches, roots and moss. Additional perimeter groves are non-blocking and feet-sorted.
- Low-contrast 64 x 32 grass tiles remove the old diamond checkerboard. Paths retain their original routes, with stones, litter, ferns and mushrooms at the edges.
- Irregular creek banks, rocks and reeds, animated water, timber grain, fasteners and rope-bound bridge supports. Broken and repaired spans remain distinct.
- Diamond ritual paving, cracks and runes, broken arches, carved mirror stands, stepped beacon pedestal, faceted crystal and restrained elevated activation light.
- Weathered tents, abandoned supplies, pottery fragments, bedrolls and small memorials.
- Nearby tree opacity drops when a player is behind the crown. No collider, interaction position, dialogue, quest, transition or shared camera/HUD changes.

## Technical frame and asset manifest

Native 640 x 360, integer viewport scaling, nearest filtering, feet-based Y sorting, unchanged gameplay scale. Trees rise approximately 100 pixels; palette: pine/teal shadows, olive highlights, earth and subdued brass, cyan for magic. The selected production direction is irregular clustered foliage framing readable warm trails, rather than full-screen lighting effects.

| Asset family | Count / size | Origin / pivot | Role |
| --- | --- | --- | --- |
| assets/forest/prop_0_*.png | 3 x 128 x 144 RGBA | Original briarwood_art.gd; feet (64,128) | Broadleaf variants |
| assets/forest/prop_1_*.png | 3 x 128 x 144 RGBA | Same | Pine variants |
| assets/forest/prop_2_0.png through prop_8_0.png | 7 x 128 x 144 RGBA | Original briarwood_prop.gd; feet (64,128) | Boulder, log, pillar, tent, mirror, mushrooms, fern |
| assets/forest/ground.png | 2048 x 1024 RGBA | Original briarwood_ground.gd; world origin (1024,512) | Static terrain, ruins flooring and cast shadows |
| assets/tiles/briarwood/forest.png / forest.tres | Six 64 x 32 tiles | Original generator; inherited diamond grid | Ground coverage |

All assets are original project artwork, authorized by this brief; no third-party asset licence is required. Sprite dimensions and transparent borders are checked by validate_gfx2.gd. Runtime sprites share cached textures. Terrain and trees are rasterized offline; only water, bridge state and sparse effects redraw at 10 Hz. The art source remains editable; regenerate rather than painting over the baked PNGs.

Regenerate from the project directory:
1. Run Godot with --headless --path . --script res://scripts/tools/generate_briarwood_tiles.gd --quit-after 120
2. Run Godot with --path . --script res://scripts/tools/bake_briarwood_art.gd --quit-after 3000 -- --bake-art
3. Run Godot with --headless --path . --import --quit-after 500

The bake step needs graphical rendering. It does not read or write player saves.

## Comparison captures

Each pair uses identical player coordinates, camera framing, viewport and progression flags. Six close views are 640 x 360; overview is 960 x 540. Bridge and beacon have extra paired state captures. Transition overlays expire before capture. Animation phase is not a pixel-exact comparison.

| View | Before | After |
| --- | --- | --- |
| Forest Edge | [before](before_edge.png) | [after](after_edge.png) |
| Whispering Fork | [before](before_fork.png) | [after](after_fork.png) |
| Old Bridge, broken | [before](before_bridge_broken.png) | [after](after_bridge_broken.png) |
| Old Bridge, repaired | [before](before_bridge_repaired.png) | [after](after_bridge_repaired.png) |
| Mirror Grove | [before](before_grove.png) | [after](after_grove.png) |
| First Beacon, dormant | [before](before_beacon_dormant.png) | [after](after_beacon_dormant.png) |
| First Beacon, active | [before](before_beacon_active.png) | [after](after_beacon_active.png) |
| Forest overview | [before](before_overview.png) | [after](after_overview.png) |

Reproduce with --path . --script res://tests/capture_gfx2.gd --quit-after 5000 (append -- --measure for timing, or -- --before on the baseline). Recoverable baseline branch: checkpoint/gfx2-before-7b8bd97.

## Validation

- Godot import: clean.
- validate_phase2.gd: 108 checks, 0 failures.
- validate_phase2_5.gd: 88 checks, 0 failures; includes actual walk-through, puzzle, interaction, inventory and save/load checks.
- validate_gfx2.gd: 15/15 important interaction approaches reachable with repaired bridge; 5,081 physics-space cells explored. Raster contracts cover 14 baked PNGs.
- Existing prop/interactable collision setup and stream barrier functions compared unchanged against 7b8bd97 (collision_audit.log).
- Bounded Briarwood startup smoke: clean; no script/runtime errors in final logs.
- All eight after captures inspected: player, single selected prompts and distinct progression states remain readable. No full manual free-roaming occlusion sweep was performed.

Measured on the RTX 4050 through Godot process-frame timing, 240 frames after warmup, active beacon, stationary player. Final native 640 x 360 / 1280 x 720 window sample: mean 18.47 ms, p95 34.72 ms, maximum 45.67 ms (~54 average FPS). The earlier unbaked 960 x 540 overview averaged 36.49 ms; baking reduced that overview sample to 17.72 ms. These are short wall-clock samples, not GPU profiler timings or a guarantee of 60 FPS. The target of a locked 60 FPS is not yet demonstrated; occasional frame pacing spikes remain.

## Scope and remaining limitations

Only Briarwood scripts/art plus generators, tests and this report changed. Startup remains Bellhaven. Open scenes/briarwood_forest.tscn and press F6 for direct review, or use F5 and travel normally. Existing exported Windows builds were not rebuilt.

Trees and ground use a deliberately small variant library; repetition is still visible in distant groves. The stream retains its original east-west course because its physical geometry is protected. Broken arches and supplies are decorative and non-blocking. Added opacity changes are immediate rather than blended. Prompts use the existing shared system and can cover a small portion of a tall landmark. A longer traversal/performance pass remains useful before describing this as release-quality or locked 60 FPS.
