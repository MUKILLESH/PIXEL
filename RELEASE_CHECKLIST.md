# Release Checklist — ASHVALE: THE THIRTEENTH BELL (v1.0.0)

## Pre-Release Verification Status

- [x] **Project Safety:** Checkpoint branch `backup-phase6-pre7` created at `e1c01b9` before Phase 7 edits.
- [x] **Bitmap Glyph Safety:** Audited UI labels and JSON strings; no unsupported glyphs (`%`, `_`, `+`, `*`, `&`, `=`, `|`) in player-facing text.
- [x] **Ending Objective & Credits Cleanup:** `open_ending_credits()` clears `"display_ending_credits"` immediately (`Chapter 5 Complete - Ashvale Remembered.`) and saves post-game state cleanly.
- [x] **System Menu & Window Controls:** Added `QUIT TO DESKTOP` (`TitleMenu`) and `[F11]` fullscreen/windowed toggle (`HUD`).
- [x] **Visual Polish (Great Bell Sanctum):** Upgraded Great Bell monolith silhouette, halo/chains contrast, Hall crystal shimmer, Heart radial spokes, and seamless Dawn Terrace layered sunrise peaks (`capture_phase6.gd` captures inspected).
- [x] **Save/Load & Post-Game Integrity:** Verified `SAVE_VERSION = 5`, backward compatibility with `v1`–`v4`, corrupt primary save `.bak` recovery, audio settings isolation (`ashvale_audio_settings.json`), non-looping post-game `Continue`, and clean `New Game` reset (without modifying existing player saves).
- [x] **Windowed GPU Performance Profile (`tests/profile_phase7.gd`):** Measured steady `60.0 FPS` (`avg_frame_ms = 16.66–16.67 ms`, `physics_ms = 0.38–0.60 ms`, `mem_mb = 42.58–45.36 MB`, `0` orphan nodes) across all 6 regions on Windows OpenGL 3.3 Compatibility renderer.
- [x] **Packaged Data Build (`dist/ASHVALE-Windows/ASHVALE.pck`):** Exported cleanly with `--export-pack "Windows Desktop"` (`EXIT:0`) excluding `tests/*`, `docs/*`, `scripts/tools/*`, and dev folders; verified standalone boot (`--main-pack`) from `%TEMP%` in both headless and windowed modes (`EXIT:0`).
- [ ] **Standalone Windows Executable (`ASHVALE.exe`):** Blocked by missing Godot `4.7.2.stable` Windows export templates at `%APPDATA%\Godot\export_templates\4.7.2.stable\windows_release_x86_64.exe` (see `KNOWN_ISSUES.md`). Ready to run `--export-release "Windows Desktop" "dist/ASHVALE-Windows/ASHVALE.exe"` immediately once templates are installed.
- [ ] **Unassisted Human Playthrough & Audio Mix Check:** Recommended final manual smoke check on target hardware for speaker/headphone volume balance, `[F11]` fullscreen scaling, and continuous human pacing from Prologue through Credits.
