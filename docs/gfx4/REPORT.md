# GFX-4 — Ironwatch Keep

Completed from dd4bb28 on main. The original checkpoint remains checkpoint/gfx4-before-dd4bb28. No other region or separate worktree was changed.

## Art and integration

Original locally drawn pixel art replaces the sparse architecture with blue-gray ashlar, taller gatehouse towers, connected curtain walls, battlements, pointed windows and weathered crimson banners. Archives gain recessed shelves, books, columns, lancets and a chandelier. Silver Bell, Sundered Shield and Crowned Flame have separate relief silhouettes. A ceremonial throne and stepped platforms frame the Warden and Third Beacon; dormant violet and restored cyan-gold states remain distinct.

Fifteen RGBA textures in assets/ironwatch cache architecture, interior, floor and decoration. The six decoration types produce 32 non-blocking, feet-sorted pieces. Static art is baked offline; only small flames, archive dust, beacon effects and existing gameplay indicators animate. Sparse atmospheric effects avoid the stealth lane. Source drawing code remains available for edits. No external assets, dependencies or reference-image pixels were incorporated.

Modified files: ironwatch_building.gd, ironwatch_landscape.gd, ironwatch_prop.gd and ironwatch_region.gd under scripts/world; scripts/interactables/ironwatch_interactable.gd. Added world helpers: ironwatch_art.gd, ironwatch_ground.gd, ironwatch_dressing.gd and ironwatch_air.gd; offline generator scripts/tools/bake_ironwatch_art.gd; tests/capture_gfx4.gd and tests/validate_gfx4.gd; generated assets and this evidence directory.

Original collision setup, world object positions, region physics, boundaries and quest synchronization compare unchanged against dd4bb28. Shadow Sentinel code and quest manager are unchanged. Original patrol warnings, safe circles and checkpoint indicators remain separate from baked art. No save schema, dialogue, puzzle rules or player controls were changed.

## Matched visual comparisons

Existing baseline images were retained. After images use matching positions, progression states and framing; normal views are 640×360, overview is 960×540. The harness freezes player movement and recovery only for deterministic captures; gameplay retains both.

| View | Before | After | Main change |
| --- | --- | --- | --- |
| Courtyard | [Before](before_courtyard.png) | [After](after_courtyard.png) | Taller gatehouse, ashlar, banners and equipment |
| Archives | [Before](before_archives.png) | [After](after_archives.png) | Shelves, Gothic windows and interior depth |
| Hall of Crests | [Before](before_crests.png) | [After](after_crests.png) | Distinct reliefs and ceremonial floor |
| Shadowed Passage | [Before](before_passage.png) | [After](after_passage.png) | Restrained masonry around readable patrol cues |
| Warden | [Before](before_warden.png) | [After](after_warden.png) | Throne and connected northern curtain |
| Dormant vault | [Before](before_vault_dormant.png) | [After](after_vault_dormant.png) | Purple crystal and dark sanctuary |
| Restored vault | [Before](before_vault_restored.png) | [After](after_vault_restored.png) | Cyan crystal, gold entrance and beacon rays |
| Overview | [Before](before_overview.png) | [After](after_overview.png) | Unified fortress silhouette and paving |

All eight after views were visually inspected. Floor contrast was reduced after review; static texture references are retained to prevent disappearing draw resources.

## Validation

- Godot 4.7.2 headless editor import: no parsing or resource errors (import.log).
- Chapter 3 suite: **104 checks, 0 failures** (validate_phase4.log), including stealth/recovery, puzzles, transitions and save compatibility/recovery.
- Focused collision reachability: **16/16 targets**, 2,917 grid cells, **0 failures** (reachability.log). Uses the original collision mask with a six-pixel-radius probe, eight-pixel grid and 28-pixel interaction tolerance after opening progression gates.
- Art contracts: **15 textures** at expected dimensions with transparent margins; **32 decoration nodes**, no added collision objects; **0 failures**.
- Bounded headless Ironwatch startup: no errors (smoke.log).
- Final graphical capture and profile: completed, no errors or shutdown warnings (capture_after.log). An earlier diagnostic exposed active audio playbacks at harness shutdown; the capture helper now stops audio and allows the mixer to release it before quitting. Shared audio implementation is untouched.
- Preservation comparison: all audited gameplay/collision sections unchanged (preservation_audit.log).

## Measured performance

Godot Compatibility/OpenGL, NVIDIA RTX 4050 Laptop GPU. Native 640×360, window 1280×720, 240 windowed frames per location after one second of warmup. Patrol animations run in the passage; player position and recovery are held by the harness. These are frame intervals under the current display pacing, not isolated GPU timings or a full interactive benchmark.

| Location | Mean ms | p95 ms | Maximum ms |
| --- | ---: | ---: | ---: |
| Courtyard | 16.66 | 16.70 | 16.79 |
| Shadowed Passage | 16.66 | 16.70 | 16.74 |
| Third Beacon Vault | 16.66 | 16.70 | 16.78 |

These samples are consistent with stable 60 FPS on the development laptop. No comparative baseline performance improvement is claimed.

## Run and regenerate

Open scenes/ironwatch_keep.tscn in Godot 4.7.2 and press F6 for direct region review. F5 keeps the existing full-game startup and progression.

From the project root in PowerShell:

```powershell
& ./Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/validate_gfx4.gd
& ./Godot_v4.7.2-stable_win64_console.exe --path . --script res://tests/capture_gfx4.gd --quit-after 2400 -- --measure
```

To rebake intentionally edited art sources, run the engine with --path . --script res://scripts/tools/bake_ironwatch_art.gd -- --bake-ironwatch, then import the project. Baking requires a graphical renderer. Normal play does not run the generator.

## Remaining review

Walk the region manually to review occlusion throughout continuous movement and interactions, especially tall tower and archive edges. The existing prompt system can draw over tall art; its behavior was preserved. Decorative walls intentionally add no collision and do not redefine playable boundaries. Repeated stone courses and some open exterior space remain visible in the overview. Stationary samples cannot establish performance on other machines. No distributable export was rebuilt.
