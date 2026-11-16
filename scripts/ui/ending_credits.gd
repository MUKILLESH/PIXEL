extends Panel
## Full-screen Finale Ending & Interactive Credits overlay for ASHVALE: THE THIRTEENTH BELL.

signal credits_action_selected(action: String)

const ACTIONS := ["close", "bellhaven", "title", "new_game"]
const BUTTON_LABELS := [
	"[1] CLOSE / CONTINUE POST-GAME",
	"[2] BELLHAVEN AT SUNRISE",
	"[3] RETURN TO TITLE MENU",
	"[4] START NEW GAME",
]

var selected_index: int = 0
var opened_frame: int = -1
var buttons: Array[Button] = []
var summary_label: Label
var closing_label: Label
var title_header: Label
var the_end_header: Label

func _ready() -> void:
	visible = false
	z_index = 40
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.5
	anchor_bottom = 0.5
	offset_left = -286
	offset_right = 286
	offset_top = -164
	offset_bottom = 164

	var scrim := ColorRect.new()
	scrim.name = "CreditsScrim"
	scrim.position = Vector2(-34, -16)
	scrim.size = Vector2(640, 360)
	scrim.color = Color(0.03, 0.03, 0.06, 0.94)
	scrim.show_behind_parent = true
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(scrim)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.09, 0.98)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.86, 0.72, 0.42, 1.0)
	add_theme_stylebox_override("panel", style)

	title_header = Label.new()
	title_header.name = "CreditsGameTitle"
	title_header.text = "ASHVALE: THE THIRTEENTH BELL"
	title_header.position = Vector2(20, 12)
	title_header.size = Vector2(532, 12)
	title_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_header.add_theme_font_size_override("font_size", 8)
	title_header.add_theme_color_override("font_color", Color("f2deaa"))
	add_child(title_header)

	the_end_header = Label.new()
	the_end_header.name = "CreditsTheEnd"
	the_end_header.text = "THE END - NO MORE STOLEN NAMES"
	the_end_header.position = Vector2(20, 26)
	the_end_header.size = Vector2(532, 12)
	the_end_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	the_end_header.add_theme_font_size_override("font_size", 8)
	the_end_header.add_theme_color_override("font_color", Color("8be6f0"))
	add_child(the_end_header)

	var top_rule := ColorRect.new()
	top_rule.position = Vector2(24, 42)
	top_rule.size = Vector2(524, 1)
	top_rule.color = Color(0.78, 0.62, 0.36, 0.85)
	add_child(top_rule)

	var sections := [
		["CHRONICLE COMPLETE", "Prologue: Bellhaven  /  Ch 1: Briarwood  /  Ch 2: Floodmill\nCh 3: Ironwatch Keep  /  Ch 4: Dawnspire  /  Ch 5: The Last Bell"],
		["DESIGN, NARRATIVE AND ENGINEERING", "Chronological Story Architecture, Isometric Puzzles, Cinematics,\nSave Persistence, and Complete World Simulation in Godot 4.7.2"],
		["PROCEDURAL PIXEL ART AND AUDIO", "Handmade 2.5D Pixel Geometry, Dynamic Storm-to-Dawn Skies,\nFour-Bus Procedural Synth Score and Resonance Soundscape"],
	]
	var cur_y: int = 50
	for sec in sections:
		var hdr := Label.new()
		hdr.text = sec[0]
		hdr.position = Vector2(24, cur_y)
		hdr.size = Vector2(524, 10)
		hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hdr.add_theme_font_size_override("font_size", 8)
		hdr.add_theme_color_override("font_color", Color("ffd578"))
		add_child(hdr)

		var body := Label.new()
		body.text = sec[1]
		body.position = Vector2(24, cur_y + 12)
		body.size = Vector2(524, 24)
		body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.add_theme_font_size_override("font_size", 8)
		body.add_theme_color_override("font_color", Color("d6c7ad"))
		add_child(body)
		cur_y += 42

	summary_label = Label.new()
	summary_label.name = "RemembranceSummary"
	summary_label.position = Vector2(24, 178)
	summary_label.size = Vector2(524, 34)
	summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_label.add_theme_font_size_override("font_size", 8)
	summary_label.add_theme_color_override("font_color", Color("9cd6de"))
	add_child(summary_label)

	closing_label = Label.new()
	closing_label.name = "ClosingDedication"
	closing_label.text = "\"For Elena, and for every name restored to the morning light.\""
	closing_label.position = Vector2(24, 214)
	closing_label.size = Vector2(524, 14)
	closing_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	closing_label.add_theme_font_size_override("font_size", 8)
	closing_label.add_theme_color_override("font_color", Color("f2deaa"))
	add_child(closing_label)

	var bot_rule := ColorRect.new()
	bot_rule.position = Vector2(24, 232)
	bot_rule.size = Vector2(524, 1)
	bot_rule.color = Color(0.78, 0.62, 0.36, 0.85)
	add_child(bot_rule)

	for i in range(ACTIONS.size()):
		var btn := Button.new()
		btn.name = "CreditsBtn%d" % i
		btn.text = BUTTON_LABELS[i]
		var col: int = i % 2
		var row: int = int(i / 2)
		btn.position = Vector2(26 + col * 266, 240 + row * 28)
		btn.size = Vector2(254, 22)
		btn.focus_mode = Control.FOCUS_NONE
		btn.add_theme_font_size_override("font_size", 8)
		btn.pressed.connect(trigger_action.bind(ACTIONS[i]))
		add_child(btn)
		buttons.append(btn)

	var hint := Label.new()
	hint.name = "CreditsHint"
	hint.text = "WASD/ARROWS MOVE   E/ENTER CONFIRM   ESC CLOSE / SKIP CREDITS"
	hint.position = Vector2(24, 302)
	hint.size = Vector2(524, 12)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 8)
	hint.add_theme_color_override("font_color", Color("9c937e"))
	add_child(hint)
	_refresh_buttons()

func open_credits(qm: Node = null) -> void:
	opened_frame = Engine.get_process_frames()
	selected_index = 1 if (qm != null and (qm.storm_resolved or qm.chapter5_completed)) else 0
	var mem_cnt: int = qm.get_recovered_memory_fragment_count() if (qm != null and qm.has_method("get_recovered_memory_fragment_count")) else 3
	var cond_cnt: int = qm.get_activated_beacon_conduit_count() if (qm != null and qm.has_method("get_activated_beacon_conduit_count")) else 3
	var opt_cnt: int = qm.optional_discoveries.size() if qm != null else 0
	var extra_note: String = ""
	if qm != null and qm.has_method("get_optional_discovery_summary"):
		var notes: Array[String] = qm.get_optional_discovery_summary()
		if not notes.is_empty():
			extra_note = "\n" + notes[0]
	summary_label.text = "BEACON NETWORK: %d/3 ACTIVE   MEMORY FRAGMENTS: %d/3   REMEMBRANCES FOUND: %d%s" % [cond_cnt, mem_cnt, opt_cnt, extra_note]
	_refresh_buttons()
	visible = true

func close_credits() -> void:
	visible = false

func trigger_action(action_id: String) -> void:
	visible = false
	credits_action_selected.emit(action_id)

func _refresh_buttons() -> void:
	for i in range(buttons.size()):
		var btn: Button = buttons[i]
		var is_sel: bool = (i == selected_index)
		var st := StyleBoxFlat.new()
		st.bg_color = Color(0.18, 0.16, 0.24, 1.0) if is_sel else Color(0.10, 0.10, 0.15, 1.0)
		st.border_width_left = 1
		st.border_width_top = 1
		st.border_width_right = 1
		st.border_width_bottom = 1
		st.border_color = Color(0.95, 0.82, 0.45, 1.0) if is_sel else Color(0.45, 0.38, 0.28, 1.0)
		btn.add_theme_stylebox_override("normal", st)
		btn.add_theme_stylebox_override("hover", st)
		btn.add_theme_stylebox_override("pressed", st)
		btn.add_theme_color_override("font_color", Color("ffe8a6") if is_sel else Color("d6c7ad"))

func _input(event: InputEvent) -> void:
	if not visible or event.is_echo():
		return
	if Engine.get_process_frames() == opened_frame:
		return
	var vp: Viewport = get_viewport()
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_1:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				trigger_action("close")
				return
			KEY_2:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				trigger_action("bellhaven")
				return
			KEY_3:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				trigger_action("title")
				return
			KEY_4:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				trigger_action("new_game")
				return
			KEY_LEFT, KEY_A:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				selected_index = posmod(selected_index - 1, buttons.size())
				_refresh_buttons()
				return
			KEY_RIGHT, KEY_D:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				selected_index = posmod(selected_index + 1, buttons.size())
				_refresh_buttons()
				return
			KEY_UP, KEY_W:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				selected_index = posmod(selected_index - 2, buttons.size())
				_refresh_buttons()
				return
			KEY_DOWN, KEY_S:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				selected_index = posmod(selected_index + 2, buttons.size())
				_refresh_buttons()
				return
	if event.is_action_pressed("dismiss") or event.is_action_pressed("ui_cancel"):
		if vp != null and is_inside_tree():
			vp.set_input_as_handled()
		trigger_action("close")
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		if vp != null and is_inside_tree():
			vp.set_input_as_handled()
		trigger_action(ACTIONS[selected_index])
