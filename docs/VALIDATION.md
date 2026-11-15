# Validation — ASHVALE: THE THIRTEENTH BELL (Phase 1)

## Automated Headless Validation Suites

Run resource import and all four validation scripts plus startup smoke test:

```powershell
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --import
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/validate.gd
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/validate_sjt.gd
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/validate_zone.gd
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/validate_phase1.gd
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --quit-after 300
```

Asset generators (run before `--import` whenever tiles or bitmap font glyphs change):

```powershell
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://scripts/tools/generate_tiles.gd
& './Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://scripts/tools/generate_font.gd
```

## Graphical Captures

Generate visual QA screenshots (inspect rendered `.png` files under `tests/`):

```powershell
& './Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_sjt.gd
& './Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture.gd
```

## Covered Guarantees

- **Baseline (`validate.gd`, `validate_sjt.gd`, `validate_zone.gd`):** Clean scene/script loading, full 2,401-tile diamond apron coverage, 8-direction movement & diagonal sliding, canopy/landmark/furnishing colliders, priority prompt tie-breaking, and compact (`<= 20px`) footer bar.
- **Phase 1 Prologue (`validate_phase1.gd`):**
  - Chronological anti-skip guards block early chest pickup, early puzzle opening, and early Briarwood gate exit before completing the prologue.
  - All 6 story interaction spots are verified free of solid collision overlaps (`test_move`).
  - Pre-pedestal NPC conversations do not prematurely increment Objective 2.
  - Multi-line NPC dialogue advances cleanly with `E`, recovers cleanly without credit or movement softlocks when cancelled mid-dialogue with `ESC`, and tracks all 3 unique villagers (`MasterCaelen`, `Mira`, `SisterElara`) without repeat-talk farming.
  - Cipher discoverability without guessing: Caelen (`Outer Ring / MOON`), Mira (`Middle Ring / SUN`), Elara (`Inner Ring / STAR`), Mother's letter, and the Rune Puzzle opening note explicitly provide the full `MOON / SUN / STAR` alignment.
  - Concentric Rune Puzzle opens/closes cleanly with `ESC` without softlocking, rejects wrong combinations, solves on `MOON`/`SUN`/`STAR` via keyboard (`A/D`, `W/S`, `E`), locks pedestal re-opening afterwards, awakens the pedestal and southwest beacon beam, and unlocks the Briarwood Waystone.
  - Briarwood Waystone recovers cleanly from mid-dialogue `ESC` cancellation, completes Objective 6 on final confirmation, displays `"PROLOGUE COMPLETE — THE THIRTEENTH TOLL"`, and shows a Chapter 1 transition note on subsequent interactions without re-triggering the banner.
  - Post-prologue dismissal restores free movement and updates NPC reflections; NPC solid colliders and idle animation clocks are verified.

## Remaining Manual Playtesting Requirements (Before Phase 2)

Automated headless checks verify state transitions, geometry, and inputs, while a human playtest pass in the live desktop window (`F5`) should confirm:

1. **Interactive Pacing & Readability:** Read through all multi-page dialogues (`Master Caelen`, `Mira`, `Sister Elara`, `Mother's Letter`, `Stone Rune Pedestal`, and `Briarwood Waystone`) at normal reading speed to confirm comfortable pacing, zero eyestrain at `1280x720` / fullscreen, and intuitive `[E]` / `[ESC]` affordances.
2. **Mouse & Keyboard Puzzle Feel:** Test clicking individual concentric ring buttons and `<` / `>` rotation arrows with the mouse cursor alongside `W/S`/`A/D`/`E` keyboard navigation inside the Stone Rune Pedestal UI.
3. **Manual Exploration & Navigation:** Physically walk Aren around all villagers, belfry columns, cottage corners, village square furnishings, and road borders to confirm smooth collision sliding and camera framing with no visual pop or awkward snags.
4. **Full End-to-End Flow Without Test Teleports:** Complete Objectives 1 through 6 continuously on foot (`15–20` minutes target pacing including NPC lore), confirming clear spatial guidance from the Rune Pedestal cipher to the glowing Briarwood beam.
