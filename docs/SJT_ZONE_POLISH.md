# SJT zone polish — 16 November 2026

## Reference check and accuracy

Inspected the current `docs/references/MAP/VIT Vellore Campus Map Infographic.png` and `docs/references/sjt/SJT elevated view.jpg`. The map directory no longer contains the earlier `map.jpeg`. The replacement infographic has different labels (including “ST (Technology) Tower” and “ST Ground”), so it is used only as a relative-layout cue. It does not establish precise orientation, surveyed distances, or exact SJT architectural details.

The SJT photographs support the building's cream massing, repeated window bands, grey central feature, entrance canopy, roof slats, trees, red paths, lawn, basin and monument motifs. The existing compressed interpretation is retained.

**Decorative additions:** three benches, four streetlights and their ground light pools, three planters, two bins, five additional trees, a seating loop, paved seating pockets, forecourt markings, and the notice board. Their exact design, quantity and placement are original gameplay set dressing, not verified real-world SJT features. Lake/PRP directions and the open ground remain approximate map-relative cues; this pass does not build those destinations. No reference image pixels or external assets are shipped.

## Interaction and UI

The existing HUD selects one object from the current region's `interactables` group. Selection order is highest exported `interaction_priority`, then shortest player distance, then stable node path for exact ties. Only the selected object's world label appears and only that object handles E. All prompts disappear while a message is open; dismissing restores the appropriate selection. The duplicate HUD prompt stays hidden.

The terminal uses priority 10. A nearby notice board uses priority 1, making overlapping interaction ranges testable in normal gameplay. Its message is contextual campus guidance and does not advance the mystery objective. The HUD connects messages with their originating object, so opening and dismissing the notice affects the notice rather than accidentally locking the terminal.

The title and clock are now native 8px text without large plates. The objective remains visible in a 19px-high bottom strip. Dialogue appears only while reading; longer notice text wraps at native font size. Existing E/Escape dismissal and movement locking remain intact.

## Art, depth and routes

The student's brighter amber clothing, dark one-pixel silhouette edge and backpack accent improve contrast. Character scale, speed, animation, camera, and the 6px foot collider are unchanged.

The building shadow now derives from its footprint via a convex hull and a consistent projected light direction. Furniture/tree shadows and small pixel-edged light pools stay on the ground layer. Buildings retain separate facade sorting, and canopy column children explicitly participate in Y sorting. New furnishings have small ground-footprint colliders under the same actor sorting parent. Benches are set off the seating loop to keep its route clear.

## Validation

Godot 4.7.2 Standard / Compatibility was used for compilation, headless behavior and graphical captures. The original Phase 1.5 suite passes 63 checks. The expanded SJT/zone suite checks the original region behavior plus priority, proximity overlap, distance/path tie-breaks, prompt suppression/restoration, selected message routing, preserved player scale, furnishing colliders, clear seating-loop segments and compact HUD height. Final results: 66 zone checks and 63 Phase 1.5 checks passed; 20 scripts compiled, zero broken.

Graphical evidence: `tests/sjt_preview.png`, `tests/sjt_entrance.png`, `tests/sjt_single_prompt.png`, and `tests/sjt_overview.png`. No parse/runtime errors remained in the final compile or 300-frame startup run. Subjective readability, long play sessions and occlusion from every possible viewpoint still benefit from a hands-on playtest; no sustained FPS benchmark is claimed.

## Files and scope

New: `scripts/world/campus_furniture.gd`, `tests/validate_zone.gd`, this document and the single-prompt capture. Updated the terminal and HUD scripts, player drawing, SJT scene/layout/landscape/building scripts and capture script. The original courtyard's two direct terminal signal connections were removed because the shared HUD now owns selection/message routing. Its gameplay regression suite still passes. No unrelated game systems were added.

Launch remains F5 or F6 from `scenes/sjt_exterior.tscn`. Use WASD, E and E/Escape. To run the new checks:

```powershell
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/validate_zone.gd
```

