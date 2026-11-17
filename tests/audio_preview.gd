extends SceneTree
## Interactive In-Game Audio Audition Tool for ASHVALE: THE THIRTEENTH BELL
## Run directly via:
##   .\Godot_v4.7.2-stable_win64_console.exe --path . -s res://tests/audio_preview.gd
## Keys 1-8 preview each chapter's live Music + Ambience + Adaptive Mix!

const AudioManagerScript = preload("res://scripts/systems/audio_manager.gd")

const TRACKS := [
	{"region": "bellhaven", "title": "1. Bellhaven Village", "desc": "Warm felt piano, gentle strings & flutes"},
	{"region": "briarwood", "title": "2. Briarwood Forest", "desc": "Delicate harp, flutes, celesta & woodland leaves"},
	{"region": "floodmill", "title": "3. Floodmill Wetlands", "desc": "Melancholic piano, solo cello, soft stream & rain"},
	{"region": "ironwatch", "title": "4. Ironwatch Keep", "desc": "Ceremonial drums, deep strings, horn & quiet stone air"},
	{"region": "dawnspire", "title": "5. Dawnspire Mountain", "desc": "Soaring flutes, sweeping harp & calm mountain wind"},
	{"region": "great_bell", "title": "6. Great Bell Sanctum", "desc": "Sacred cathedral theme, bronze bell & quiet stone hall"},
	{"region": "great_bell_climax", "title": "7. Last Bell Climax", "desc": "Heroic surge -> Radiant D Major liberation"},
	{"region": "epilogue_dawn", "title": "8. Epilogue Sunrise", "desc": "Emotional reprise of Bellhaven motif at dawn"},
]

var audio_mgr: Node
var status_lbl: Label
var duck_state: String = "NORMAL EXPLORATION"
var _idx: int = 0
var _prev_keys: Dictionary = {}

func _init() -> void:
	call_deferred("_setup")

func _setup() -> void:
	var canvas := CanvasLayer.new()
	root.add_child(canvas)

	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.08, 1.0)
	bg.size = Vector2(640, 360)
	canvas.add_child(bg)

	var hdr := Label.new()
	hdr.text = "ASHVALE AUDIO AUDITORIUM — LIVE ENGINE PREVIEW"
	hdr.position = Vector2(24, 18)
	hdr.add_theme_font_size_override("font_size", 12)
	hdr.add_theme_color_override("font_color", Color("f2deaa"))
	canvas.add_child(hdr)

	var list_lbl := Label.new()
	var lines := PackedStringArray()
	for i in range(TRACKS.size()):
		var t: Dictionary = TRACKS[i]
		lines.append("[%d] %s — %s" % [i + 1, t["title"], t["desc"]])
	lines.append("")
	lines.append("[D] Toggle Dialogue Ducking   [E] Toggle Emotional Silence")
	lines.append("[B] Trigger Bell Toll SFX     [F] Trigger Footsteps SFX")
	lines.append("[ESC] Quit Preview")
	list_lbl.text = "\n".join(lines)
	list_lbl.position = Vector2(24, 52)
	list_lbl.add_theme_font_size_override("font_size", 8)
	list_lbl.add_theme_color_override("font_color", Color("d6c7ad"))
	canvas.add_child(list_lbl)

	status_lbl = Label.new()
	status_lbl.position = Vector2(24, 290)
	status_lbl.add_theme_font_size_override("font_size", 10)
	status_lbl.add_theme_color_override("font_color", Color("8ce89a"))
	canvas.add_child(status_lbl)

	audio_mgr = AudioManagerScript.ensure(self)
	_select_track(0)

	if DisplayServer.get_name() == "headless":
		await create_timer(0.4).timeout
		audio_mgr.stop_all()
		quit(0)

func _select_track(idx: int) -> void:
	_idx = idx
	var t: Dictionary = TRACKS[idx]
	if t["region"] == "great_bell_climax":
		audio_mgr.play_region_ambience("great_bell", 1.4)
		audio_mgr.transition_music_track("great_bell_climax", 1.4)
	else:
		audio_mgr.play_region_ambience(t["region"], 1.4)
	status_lbl.text = "NOW PLAYING: %s | MIX MODE: %s" % [t["title"], duck_state]

func _just_pressed(kc: int) -> bool:
	var now: bool = Input.is_physical_key_pressed(kc)
	var was: bool = bool(_prev_keys.get(kc, false))
	_prev_keys[kc] = now
	return now and not was

func _process(_delta: float) -> bool:
	for k in range(8):
		if _just_pressed(KEY_1 + k):
			_select_track(k)
	if _just_pressed(KEY_D):
		duck_state = "DIALOGUE DUCK (-4.2 dB)" if duck_state != "DIALOGUE DUCK (-4.2 dB)" else "NORMAL EXPLORATION"
		audio_mgr.set_dialogue_ducking(duck_state != "NORMAL EXPLORATION", false)
		status_lbl.text = "NOW PLAYING: %s | MIX MODE: %s" % [TRACKS[_idx]["title"], duck_state]
	if _just_pressed(KEY_E):
		duck_state = "EMOTIONAL SILENCE (-10.5 dB)" if duck_state != "EMOTIONAL SILENCE (-10.5 dB)" else "NORMAL EXPLORATION"
		audio_mgr.set_dialogue_ducking(duck_state != "NORMAL EXPLORATION", duck_state != "NORMAL EXPLORATION")
		status_lbl.text = "NOW PLAYING: %s | MIX MODE: %s" % [TRACKS[_idx]["title"], duck_state]
	if _just_pressed(KEY_B):
		audio_mgr.play_sfx("bell_toll")
	if _just_pressed(KEY_F):
		audio_mgr.play_sfx("footstep")
	if _just_pressed(KEY_ESCAPE):
		audio_mgr.stop_all()
		quit(0)
	return false
