extends Panel
## Lightweight system & title menu providing New Game, Continue, Manual Save, Satchel, and Audio settings.

signal new_game_requested()
signal continue_requested()
signal save_requested()
signal inventory_requested()
signal quit_requested()
signal menu_closed_signal()

const AudioManagerScript = preload("res://scripts/systems/audio_manager.gd")

const OPTIONS := [
	"NEW GAME",
	"CONTINUE SAVED GAME",
	"SAVE PROGRESS",
	"OPEN FIELD SATCHEL",
	"RESUME EXPLORATION",
	"QUIT TO DESKTOP",
]
const AUDIO_BUSES := ["Master", "Music", "SFX", "Ambient"]
const AUDIO_LABELS := ["MASTER", "MUSIC", "SFX", "AMBIENT"]

var selected_index: int = 0
var has_save: bool = false
var opened_frame: int = -1
var buttons: Array[Button] = []
var audio_value_labels: Dictionary = {}
var feedback_label: Label

func _ready() -> void:
	visible = false
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.5
	anchor_bottom = 0.5
	offset_left = -224
	offset_right = 224
	offset_top = -152
	offset_bottom = 152

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.05, 0.08, 0.98)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.78, 0.62, 0.36, 1)
	add_theme_stylebox_override("panel", style)

	var title := Label.new()
	title.name = "TitleLabel"
	title.text = "ASHVALE: THE THIRTEENTH BELL"
	title.position = Vector2(20, 12)
	title.add_theme_font_size_override("font_size", 8)
	title.add_theme_color_override("font_color", Color("f2deaa"))
	add_child(title)

	var subtitle := Label.new()
	subtitle.name = "SubtitleLabel"
	subtitle.text = "CHRONICLES OF THE GREAT BELL - SYSTEM MENU"
	subtitle.position = Vector2(20, 26)
	subtitle.add_theme_font_size_override("font_size", 8)
	subtitle.add_theme_color_override("font_color", Color("9c937e"))
	add_child(subtitle)

	for i in range(OPTIONS.size()):
		var btn := Button.new()
		btn.name = "MenuButton%d" % i
		btn.position = Vector2(36, 44 + i * 22)
		btn.size = Vector2(376, 20)
		btn.focus_mode = Control.FOCUS_NONE
		btn.add_theme_font_size_override("font_size", 8)
		btn.pressed.connect(_on_button_pressed.bind(i))
		add_child(btn)
		buttons.append(btn)

	var sep := ColorRect.new()
	sep.position = Vector2(20, 182)
	sep.size = Vector2(408, 1)
	sep.color = Color(0.55, 0.44, 0.26, 0.85)
	add_child(sep)

	var audio_hdr := Label.new()
	audio_hdr.text = "AUDIO VOLUME SETTINGS"
	audio_hdr.position = Vector2(20, 188)
	audio_hdr.add_theme_font_size_override("font_size", 8)
	audio_hdr.add_theme_color_override("font_color", Color("c9b995"))
	add_child(audio_hdr)

	for bi in range(AUDIO_BUSES.size()):
		var bname: String = AUDIO_BUSES[bi]
		var col_x: int = 24 if (bi % 2 == 0) else 232
		var row_y: int = 204 if bi < 2 else 226
		var blbl := Label.new()
		blbl.text = AUDIO_LABELS[bi] + ":"
		blbl.position = Vector2(col_x, row_y + 3)
		blbl.size = Vector2(68, 14)
		blbl.add_theme_font_size_override("font_size", 8)
		blbl.add_theme_color_override("font_color", Color("d6c7ad"))
		add_child(blbl)

		var minus_btn := Button.new()
		minus_btn.text = "<"
		minus_btn.position = Vector2(col_x + 70, row_y)
		minus_btn.size = Vector2(20, 18)
		minus_btn.focus_mode = Control.FOCUS_NONE
		minus_btn.add_theme_font_size_override("font_size", 8)
		minus_btn.pressed.connect(adjust_audio_bus.bind(bname, -1))
		add_child(minus_btn)

		var val_lbl := Label.new()
		val_lbl.position = Vector2(col_x + 92, row_y + 3)
		val_lbl.size = Vector2(54, 14)
		val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		val_lbl.add_theme_font_size_override("font_size", 8)
		val_lbl.add_theme_color_override("font_color", Color("f2deaa"))
		add_child(val_lbl)
		audio_value_labels[bname] = val_lbl

		var plus_btn := Button.new()
		plus_btn.text = ">"
		plus_btn.position = Vector2(col_x + 148, row_y)
		plus_btn.size = Vector2(20, 18)
		plus_btn.focus_mode = Control.FOCUS_NONE
		plus_btn.add_theme_font_size_override("font_size", 8)
		plus_btn.pressed.connect(adjust_audio_bus.bind(bname, 1))
		add_child(plus_btn)

	feedback_label = Label.new()
	feedback_label.name = "FeedbackLabel"
	feedback_label.position = Vector2(20, 250)
	feedback_label.size = Vector2(408, 26)
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.add_theme_font_size_override("font_size", 8)
	feedback_label.add_theme_color_override("font_color", Color("d6c7ad"))
	add_child(feedback_label)

	var hint := Label.new()
	hint.name = "HintLabel"
	hint.text = "W/S SELECT   E/ENTER CONFIRM   F11 FULLSCREEN   ESC RESUME"
	hint.position = Vector2(20, 282)
	hint.add_theme_font_size_override("font_size", 8)
	hint.add_theme_color_override("font_color", Color("9c937e"))
	add_child(hint)
	_refresh_buttons()
	_refresh_audio_labels()

func open_menu(save_available: bool, status_text: String = "") -> void:
	has_save = save_available
	opened_frame = Engine.get_process_frames()
	selected_index = 1 if save_available else 4
	if status_text != "":
		set_feedback(status_text, false)
	elif save_available:
		set_feedback("Saved chronicle detected. Choose Continue to resume or Save to overwrite.", false)
	else:
		set_feedback("No save file found yet. Select Save Progress or press F5 anytime.", false)
	_refresh_buttons()
	_refresh_audio_labels()
	visible = true

func adjust_audio_bus(bus_name: String, delta_steps: int) -> float:
	var audio_mgr := AudioManagerScript.ensure(get_tree())
	if audio_mgr == null:
		return 1.0
	var cur_step: int = clampi(roundi(audio_mgr.get_bus_linear(bus_name) * 10.0), 0, 10)
	var next_step: int = clampi(cur_step + delta_steps, 0, 10)
	var next_val: float = float(next_step) / 10.0
	audio_mgr.set_bus_linear(bus_name, next_val)
	audio_mgr.save_settings()
	if bus_name in ["Master", "SFX"] and next_step > 0:
		audio_mgr.play_sfx("dialogue_open")
	_refresh_audio_labels()
	set_feedback("Audio %s volume set to %d/10 and saved." % [bus_name.to_upper(), next_step], false)
	return next_val

func _refresh_audio_labels() -> void:
	var audio_mgr := AudioManagerScript.ensure(get_tree()) if is_inside_tree() else null
	for bname in AUDIO_BUSES:
		if not audio_value_labels.has(bname):
			continue
		var lbl: Label = audio_value_labels[bname]
		var step_v: int = roundi(audio_mgr.get_bus_linear(bname) * 10.0) if audio_mgr != null else 8
		lbl.text = "[MUTE]" if step_v == 0 else ("[%d/10]" % step_v)

func close_menu() -> void:
	if not visible:
		return
	visible = false
	menu_closed_signal.emit()

func set_feedback(text: String, is_error: bool = false) -> void:
	if feedback_label == null:
		return
	feedback_label.text = text
	feedback_label.add_theme_color_override("font_color", Color("ff8080") if is_error else Color("8ce89a"))

func select_option(idx: int) -> void:
	selected_index = posmod(idx, OPTIONS.size())
	_refresh_buttons()

func activate_selected() -> void:
	_on_button_pressed(selected_index)

func _on_button_pressed(idx: int) -> void:
	selected_index = idx
	_refresh_buttons()
	match idx:
		0:
			new_game_requested.emit()
		1:
			continue_requested.emit()
		2:
			save_requested.emit()
		3:
			inventory_requested.emit()
		4:
			close_menu()
		5:
			quit_requested.emit()

func _refresh_buttons() -> void:
	for i in range(buttons.size()):
		var btn: Button = buttons[i]
		var label_text: String = OPTIONS[i]
		if i == 1 and not has_save:
			label_text = "CONTINUE SAVED GAME (NONE FOUND)"
		btn.text = ("> " + label_text) if i == selected_index else ("  " + label_text)
		var st := StyleBoxFlat.new()
		st.bg_color = Color(0.16, 0.14, 0.22, 1) if i == selected_index else Color(0.10, 0.10, 0.14, 1)
		st.border_width_left = 1
		st.border_width_top = 1
		st.border_width_right = 1
		st.border_width_bottom = 1
		st.border_color = Color("f2deaa") if i == selected_index else Color(0.45, 0.38, 0.26, 1)
		btn.add_theme_stylebox_override("normal", st)
		btn.add_theme_stylebox_override("hover", st)
		btn.add_theme_stylebox_override("pressed", st)
		var font_col := Color("6f7685") if (i == 1 and not has_save) else (Color("f2deaa") if i == selected_index else Color("d6c7ad"))
		btn.add_theme_color_override("font_color", font_col)

func _input(event: InputEvent) -> void:
	if not visible or event.is_echo() or Engine.get_process_frames() == opened_frame:
		return
	if event.is_action_pressed("move_up") or event.is_action_pressed("ui_up"):
		select_option(selected_index - 1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_down") or event.is_action_pressed("ui_down"):
		select_option(selected_index + 1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		activate_selected()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("dismiss") or event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and (event.keycode == KEY_M or event.keycode == KEY_F10)):
		close_menu()
		get_viewport().set_input_as_handled()
