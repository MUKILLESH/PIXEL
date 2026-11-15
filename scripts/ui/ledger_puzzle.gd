extends Panel
## Evidence Reconstruction puzzle for Floodmill's Forgotten Village Ledger.

signal ledger_solved_signal()
signal ledger_closed_signal()

const OPTIONS := ["THIRTY-SIX HEARTHS", "MEMORY OFFERING", "IRONWATCH SEAL", "FLOOD DAMAGE CLAIM"]
const ENTRY_NAMES := ["ENTRY I: THE CENSUS", "ENTRY II: THE EDICT", "ENTRY III: THE VAULT"]
const SOLUTION := [0, 1, 2] # THIRTY-SIX HEARTHS, MEMORY OFFERING, IRONWATCH SEAL

var selections: Array[int] = [3, 0, 1]
var selected_entry: int = 0
var solved: bool = false
var all_clues_discovered: bool = false
var opened_frame: int = -1
var feedback_text: String = "Pair each torn Archive column with the evidence recovered from Floodmill's three records."
var feedback_color: Color = Color("d6c7ad")

var row_buttons: Array[Dictionary] = []
var feedback_label: Label

func _ready() -> void:
	visible = false
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.5
	anchor_bottom = 0.5
	offset_left = -260
	offset_right = 260
	offset_top = -134
	offset_bottom = 134

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.05, 0.08, 0.98)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.78, 0.62, 0.36, 1)
	add_theme_stylebox_override("panel", style)

	var title := Label.new()
	title.text = "FORGOTTEN ARCHIVE - MASTER LEDGER RECONSTRUCTION"
	title.position = Vector2(16, 12)
	title.add_theme_font_size_override("font_size", 8)
	title.add_theme_color_override("font_color", Color("f2deaa"))
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "MATCH EACH DAMAGED ENTRY WITH DISCOVERED VILLAGE RECORDS"
	subtitle.position = Vector2(16, 26)
	subtitle.add_theme_font_size_override("font_size", 8)
	subtitle.add_theme_color_override("font_color", Color("9c937e"))
	add_child(subtitle)

	for i in range(3):
		var y_pos: int = 56 + i * 32
		var ent_btn := Button.new()
		ent_btn.text = ENTRY_NAMES[i]
		ent_btn.position = Vector2(188, y_pos)
		ent_btn.size = Vector2(128, 22)
		_style_button(ent_btn)
		ent_btn.pressed.connect(select_entry.bind(i))
		add_child(ent_btn)

		var prev_btn := Button.new()
		prev_btn.text = "<"
		prev_btn.position = Vector2(320, y_pos)
		prev_btn.size = Vector2(20, 22)
		_style_button(prev_btn)
		prev_btn.pressed.connect(_on_cycle_pressed.bind(i, -1))
		add_child(prev_btn)

		var opt_label := Label.new()
		opt_label.position = Vector2(342, y_pos + 6)
		opt_label.size = Vector2(134, 14)
		opt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		opt_label.add_theme_font_size_override("font_size", 8)
		add_child(opt_label)

		var next_btn := Button.new()
		next_btn.text = ">"
		next_btn.position = Vector2(478, y_pos)
		next_btn.size = Vector2(20, 22)
		_style_button(next_btn)
		next_btn.pressed.connect(_on_cycle_pressed.bind(i, 1))
		add_child(next_btn)

		row_buttons.append({
			"entry": ent_btn,
			"opt": opt_label,
		})

	feedback_label = Label.new()
	feedback_label.position = Vector2(192, 158)
	feedback_label.size = Vector2(276, 38)
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.add_theme_font_size_override("font_size", 8)
	add_child(feedback_label)

	var confirm_button := Button.new()
	confirm_button.text = "[ BIND MASTER LEDGER ]"
	confirm_button.position = Vector2(192, 204)
	confirm_button.size = Vector2(158, 24)
	_style_button(confirm_button)
	confirm_button.pressed.connect(verify_ledger)
	add_child(confirm_button)

	var close_button := Button.new()
	close_button.text = "[ CLOSE ]"
	close_button.position = Vector2(358, 204)
	close_button.size = Vector2(108, 24)
	_style_button(close_button)
	close_button.pressed.connect(close_puzzle)
	add_child(close_button)

	var controls := Label.new()
	controls.text = "W/S COLUMN   A/D RECORD   E/ENTER BIND   ESC CLOSE"
	controls.position = Vector2(16, 242)
	controls.add_theme_font_size_override("font_size", 8)
	controls.add_theme_color_override("font_color", Color("9c937e"))
	add_child(controls)

	_refresh_labels()

func _style_button(btn: Button) -> void:
	btn.focus_mode = Control.FOCUS_NONE
	btn.add_theme_font_size_override("font_size", 8)
	btn.add_theme_color_override("font_color", Color("e8dbb8"))
	btn.add_theme_color_override("font_hover_color", Color("ffe89e"))
	btn.add_theme_color_override("font_pressed_color", Color("8be6f0"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("191624")
	normal.border_width_left = 1
	normal.border_width_top = 1
	normal.border_width_right = 1
	normal.border_width_bottom = 1
	normal.border_color = Color("7a633d")
	var hover := normal.duplicate()
	hover.bg_color = Color("262136")
	hover.border_color = Color("d9b366")
	var pressed := normal.duplicate()
	pressed.bg_color = Color("110f18")
	pressed.border_color = Color("8be6f0")
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("focus", hover)
	btn.add_theme_stylebox_override("pressed", pressed)

func open_puzzle(clues_ready: bool = true) -> void:
	if solved:
		return
	all_clues_discovered = clues_ready
	selections = [3, 0, 1]
	selected_entry = 0
	feedback_text = "Pair each torn Archive column with the evidence recovered from Floodmill's three records."
	feedback_color = Color("d6c7ad")
	opened_frame = Engine.get_process_frames()
	visible = true
	_refresh_labels()
	queue_redraw()

func close_puzzle() -> void:
	if not visible:
		return
	visible = false
	ledger_closed_signal.emit()

func select_entry(entry_index: int) -> void:
	selected_entry = clampi(entry_index, 0, 2)
	_refresh_labels()
	queue_redraw()

func set_entry_choice(entry_index: int, choice_name: String) -> void:
	var idx: int = OPTIONS.find(choice_name)
	if idx == -1 or entry_index < 0 or entry_index > 2:
		return
	selections[entry_index] = idx
	_refresh_labels()
	queue_redraw()

func rotate_entry(entry_index: int, delta_step: int) -> void:
	if solved or entry_index < 0 or entry_index > 2:
		return
	selections[entry_index] = posmod(selections[entry_index] + delta_step, OPTIONS.size())
	feedback_text = "%s set to %s." % [ENTRY_NAMES[entry_index], OPTIONS[selections[entry_index]]]
	feedback_color = Color("d6c7ad")
	_refresh_labels()
	queue_redraw()

func _on_cycle_pressed(entry_index: int, delta_step: int) -> void:
	select_entry(entry_index)
	rotate_entry(entry_index, delta_step)

func verify_ledger() -> bool:
	if solved:
		return false
	if not all_clues_discovered:
		feedback_text = "Missing evidence! Gather all three Archive records first."
		feedback_color = Color("e6735c")
		_refresh_labels()
		queue_redraw()
		return false
	if selections == SOLUTION:
		solved = true
		feedback_text = "LEDGER BOUND - THE ERASURE OF FLOODMILL STANDS PROVEN!"
		feedback_color = Color("8be6f0")
		_refresh_labels()
		queue_redraw()
		visible = false
		ledger_solved_signal.emit()
		return true
	feedback_text = "The ink columns reject that sequence. Re-check Census, Edict, and Vault receipts."
	feedback_color = Color("e6735c")
	_refresh_labels()
	queue_redraw()
	return false

func _refresh_labels() -> void:
	for i in range(row_buttons.size()):
		var entry: Dictionary = row_buttons[i]
		var e_btn: Button = entry["entry"]
		var o_lbl: Label = entry["opt"]
		var is_sel: bool = (i == selected_entry)
		e_btn.add_theme_color_override("font_color", Color("ffe89e") if is_sel else Color("b8b09c"))
		o_lbl.text = OPTIONS[selections[i]]
		var matches: bool = (selections[i] == SOLUTION[i])
		o_lbl.add_theme_color_override("font_color", Color("8be6f0") if solved else (Color("a5e082") if matches else (Color("ffe89e") if is_sel else Color("e0d4ba"))))
	if feedback_label != null:
		feedback_label.text = feedback_text
		feedback_label.add_theme_color_override("font_color", feedback_color)

func _input(event: InputEvent) -> void:
	if not visible or event.is_echo() or Engine.get_process_frames() == opened_frame:
		return
	if not ((event is InputEventKey or event is InputEventAction) and event.is_pressed()):
		return
	if event.is_action_pressed("move_up") or event.is_action_pressed("ui_up"):
		select_entry(posmod(selected_entry - 1, 3))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_down") or event.is_action_pressed("ui_down"):
		select_entry(posmod(selected_entry + 1, 3))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_left") or event.is_action_pressed("ui_left"):
		rotate_entry(selected_entry, -1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_right") or event.is_action_pressed("ui_right"):
		rotate_entry(selected_entry, 1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		verify_ledger()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("dismiss") or event.is_action_pressed("ui_cancel"):
		close_puzzle()
		get_viewport().set_input_as_handled()

func _draw() -> void:
	# Open double-page parchment folio on the left
	var box := Rect2(18, 56, 160, 168)
	draw_rect(box, Color("241a14"))
	draw_rect(box, Color("595043"), false, 2.0)

	# Leather cover & twin aged parchment leaves
	draw_rect(Rect2(26, 66, 68, 148), Color("dfd0ad"))
	draw_rect(Rect2(98, 66, 68, 148), Color("d4c39d"))
	draw_line(Vector2(96, 66), Vector2(96, 214), Color("523a25"), 3.0)

	# Three reconstructed parchment slip rows aligned to columns
	for i in range(3):
		var ry: int = 78 + i * 44
		var matches: bool = (selections[i] == SOLUTION[i])
		draw_rect(Rect2(32, ry, 56, 28), Color("bfa87d"))
		draw_line(Vector2(36, ry + 8), Vector2(82, ry + 8), Color("59412b"), 2.0)
		draw_line(Vector2(36, ry + 16), Vector2(74, ry + 16), Color("59412b"), 1.5)
		var slip_col := Color("a5e082") if matches else (Color("ffd466") if i == selected_entry else Color("9e4b3c"))
		draw_rect(Rect2(104, ry, 54, 28), Color("ebd9b5"))
		draw_rect(Rect2(104, ry, 54, 28), slip_col, false, 2.0 if i == selected_entry else 1.5)
		draw_rect(Rect2(150, ry + 18, 6, 6), Color("b84435") if not matches else Color("4a9ea8"))
