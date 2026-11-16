# Known Issues & Release Limitations — ASHVALE: THE THIRTEENTH BELL (v1.0.0)

1. **Missing Godot 4.7.2 Windows Export Templates on Development Machine (Blocker for `.exe` Binary Bundling):**
   - `export_presets.cfg` (`"Windows Desktop"`) and `--export-pack "Windows Desktop" dist/ASHVALE-Windows/ASHVALE.pck` succeeded (`EXIT:0`).
   - Running `--export-release "Windows Desktop" dist/ASHVALE-Windows/ASHVALE.exe` failed because Godot's official export templates for `4.7.2.stable` are not installed on this workstation (`C:/Users/srmuk/AppData/Roaming/Godot/export_templates/4.7.2.stable/windows_release_x86_64.exe` and `windows_debug_x86_64.exe` are absent).
   - **Resolution Path:** Install Godot 4.7.2.stable export templates via **Project / Editor -> Manage Export Templates -> Download and Install**, then run:
     `.\Godot_v4.7.2-stable_win64_console.exe --headless --export-release "Windows Desktop" "dist/ASHVALE-Windows/ASHVALE.exe"`
   - Until that `.exe` step runs with official templates, `dist/ASHVALE-Windows/ASHVALE.pck` has been built and verified standalone via `--main-pack` from `%TEMP%`.

2. **Human Playthrough vs. Automated Validation Scope:**
   - All story sequences, puzzles, save migrations (`v1`–`v5`), audio bus isolation, rendering captures, and `ASHVALE.pck` pack boot have been exercised across automated headless/GPU runs on Windows.
   - Because automated scripts cannot substitute for an uninterrupted end-to-end human session with live audio speakers, physical keyboard/mouse feel, subjective volume mixing across headphones, and fullscreen monitor switching should still be confirmed manually using `PLAYER_GUIDE.md` & `RELEASE_CHECKLIST.md`.

3. **Keyboard vs. Gamepad Support:**
   - Full keyboard playability (`WASD`/Arrows, `E`/`Enter`/`Space`, `Esc`, `M`/`F10`, `I`/`Tab`, `F5`, `F11`, `X`) and mouse UI clicking are implemented and verified. Dedicated analog gamepad stick bindings are not configured in `project.godot`.

4. **Windows Binary Code Signing:**
   - `codesign/enable=false` is set in `export_presets.cfg`; unsigned Windows executables exported later without an Authenticode certificate will show a standard Windows SmartScreen prompt on first launch.
