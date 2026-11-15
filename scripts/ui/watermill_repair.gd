extends Panel
## Self-contained Watermill Mechanical Repair puzzle for Chapter 2 (Old Watermill).

signal watermill_repaired_signal()
signal watermill_closed_signal()

const OPTIONS := ["IRON DRIVE GEAR", "BRONZE PINION", "OAK COUPLING BELT", "WARPED COG"]
const SLOT_NAMES := ["SLOT 1: DRIVE AXLE", "SLOT 2: CENTER MESH", "SLOT 3: SLUICE SHAFT"]
const SOLUTION := [0, 1, 2] # IRON DRIVE GEAR -> BRONZE PINION -> OAK COUPLING BELT

var selections: Array[int] = [3, 0, 1]
var selected_slot: int = 0
var repaired: bool = false
var opened_frame: int = -1
var feedback_text: String = "Diagram: 1. IRON DRIVE GEAR, 2. BRONZE PINION, 3. OAK COUPLING BELT."
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
	title.text = "OLD WATERMILL - MECHANICAL GEARBOX"
	title.position = Vector2(16, 12)
	title.add_theme_font_size_override("font_size", 8)
	title.add_theme_color_override("font_color", Color("f2deaa"))
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "ALIGN THE THREE COMPONENTS TO RECONNECT THE SLUICE PUMP"
	subtitle.position = Vector2(16, 26)
	subtitle.add_theme_font_size_override("font_size", 8)
	subtitle.add_theme_color_override("font_color", Color("9c937e"))
	add_child(subtitle)

	for i in range(3):
		var y_pos: int = 56 + i * 32
		var slot_btn := Button.new()
		slot_btn.text = SLOT_NAMES[i]
		slot_btn.position = Vector2(194, y_pos)
		slot_btn.size = Vector2(126, 22)
		_style_button(slot_btn)
		slot_btn.pressed.connect(select_slot.bind(i))
		add_child(slot_btn)

		var prev_btn := Button.new()
		prev_btn.text = "<"
		prev_btn.position = Vector2(324, y_pos)
		prev_btn.size = Vector2(20, 22)
		_style_button(prev_btn)
		prev_btn.pressed.connect(_on_cycle_pressed.bind(i, -1))
		add_child(prev_btn)

		var opt_label := Label.new()
		opt_label.position = Vector2(346, y_pos + 6)
		opt_label.size = Vector2(130, 14)
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
			"slot": slot_btn,
			"opt": opt_label,
		})

	feedback_label = Label.new()
	feedback_label.position = Vector2(196, 158)
	feedback_label.size = Vector2(268, 38)
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.add_theme_font_size_override("font_size", 8)
	add_child(feedback_label)

	var confirm_button := Button.new()
	confirm_button.text = "[ ENGAGE MILLWHEEL ]"
	confirm_button.position = Vector2(196, 204)
	confirm_button.size = Vector2(154, 24)
	_style_button(confirm_button)
	confirm_button.pressed.connect(verify_repair)
	add_child(confirm_button)

	var close_button := Button.new()
	close_button.text = "[ CLOSE ]"
	close_button.position = Vector2(358, 204)
	close_button.size = Vector2(106, 24)
	_style_button(close_button)
	close_button.pressed.connect(close_puzzle)
	add_child(close_button)

	var controls := Label.new()
	controls.text = "W/S SLOT   A/D COMPONENT   E/ENTER ENGAGE   ESC CLOSE"
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

func open_puzzle() -> void:
	if repaired:
		return
	selections = [3, 0, 1]
	selected_slot = 0
	feedback_text = "Diagram: 1. IRON DRIVE GEAR, 2. BRONZE PINION, 3. OAK COUPLING BELT."
	feedback_color = Color("d6c7ad")
	opened_frame = Engine.get_process_frames()
	visible = true
	_refresh_labels()
	queue_redraw()

func close_puzzle() -> void:
	if not visible:
		return
	visible = false
	watermill_closed_signal.emit()

func select_slot(slot_index: int) -> void:
	selected_slot = clampi(slot_index, 0, 2)
	_refresh_labels()
	queue_redraw()

func set_slot_part(slot_index: int, part_name: String) -> void:
	var idx: int = OPTIONS.find(part_name)
	if idx == -1 or slot_index < 0 or slot_index > 2:
		return
	selections[slot_index] = idx
	_refresh_labels()
	queue_redraw()

func rotate_slot(slot_index: int, delta_step: int) -> void:
	if repaired or slot_index < 0 or slot_index > 2:
		return
	selections[slot_index] = posmod(selections[slot_index] + delta_step, OPTIONS.size())
	feedback_text = "%s fitted with %s." % [SLOT_NAMES[slot_index], OPTIONS[selections[slot_index]]]
	feedback_color = Color("d6c7ad")
	_refresh_labels()
	queue_redraw()

func _on_cycle_pressed(slot_index: int, delta_step: int) -> void:
	select_slot(slot_index)
	rotate_slot(slot_index, delta_step)

func verify_repair() -> bool:
	if repaired:
		return false
	if selections == SOLUTION:
		repaired = true
		feedback_text = "TEETH LOCKED AND COUPLING ENGAGED - WATERWHEEL TURNING!"
		feedback_color = Color("8be6f0")
		_refresh_labels()
		queue_redraw()
		visible = false
		watermill_repaired_signal.emit()
		return true
	feedback_text = "The axle binds with a metallic groan! Match IRON DRIVE GEAR, BRONZE PINION, OAK COUPLING BELT."
	feedback_color = Color("e6735c")
	_refresh_labels()
	queue_redraw()
	return false

func _refresh_labels() -> void:
	for i in range(row_buttons.size()):
		var entry: Dictionary = row_buttons[i]
		var slot_btn: Button = entry["slot"]
		var opt_lbl: Label = entry["opt"]
		var is_sel: bool = (i == selected_slot)
		slot_btn.add_theme_color_override("font_color", Color("ffe89e") if is_sel else Color("b8b09c"))
		opt_lbl.text = OPTIONS[selections[i]]
		var matches: bool = (selections[i] == SOLUTION[i])
		opt_lbl.add_theme_color_override("font_color", Color("8be6f0") if repaired else (Color("a5e082") if matches else (Color("ffe89e") if is_sel else Color("e0d4ba"))))
	if feedback_label != null:
		feedback_label.text = feedback_text
		feedback_label.add_theme_color_override("font_color", feedback_color)

func _input(event: InputEvent) -> void:
	if not visible or event.is_echo() or Engine.get_process_frames() == opened_frame:
		return
	if not ((event is InputEventKey or event is InputEventAction) and event.is_pressed()):
		return
	if event.is_action_pressed("move_up") or event.is_action_pressed("ui_up"):
		select_slot(posmod(selected_slot - 1, 3))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_down") or event.is_action_pressed("ui_down"):
		select_slot(posmod(selected_slot + 1, 3))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_left") or event.is_action_pressed("ui_left"):
		rotate_slot(selected_slot, -1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_right") or event.is_action_pressed("ui_right"):
		rotate_slot(selected_slot, 1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		verify_repair()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("dismiss") or event.is_action_pressed("ui_cancel"):
		close_puzzle()
		get_viewport().set_input_as_handled()

func _draw() -> void:
	# Left mechanical gearbox diagram
	var box := Rect2(18, 56, 164, 168)
	draw_rect(box, Color("141a24"))
	draw_rect(box, Color("595043"), false, 2.0)

	# Waterwheel intake at bottom left
	draw_rect(Rect2(24, 186, 152, 28), Color("1b4b63"))
	draw_line(Vector2(30, 198), Vector2(166, 198), Color("67b5cc"), 1.5)

	var slot_centers := [Vector2(62, 92), Vector2(100, 126), Vector2(138, 162)]
	var slot_radii := [22.0, 16.0, 18.0]
	for i in range(3):
		var c: Vector2 = slot_centers[i]
		var r: float = slot_radii[i]
		var matched: bool = (selections[i] == SOLUTION[i])
		var rim_col := Color("8be6f0") if repaired else (Color("a5e082") if matched else Color("d9984a"))
		draw_circle(c, r, Color("29303b"))
		draw_circle(c, r, rim_col, false, 2.0)
		draw_circle(c, 4.0, rim_col)
		for k in range(6):
			var ang: float = float(k) * TAU / 6.0
			draw_line(c + Vector2(cos(ang), sin(ang)) * 4.0, c + Vector2(cos(ang), sin(ang)) * (r - 2.0), rim_col, 1.5)

	# Oak Coupling Belt connecting mesh -> sluice shaft when matched
	if selections[2] == SOLUTION[2]:
		draw_line(slot_centers[1] + Vector2(0, -14), slot_centers[2] + Vector2(0, -14), Color("b88249"), 3.0)
		draw_line(slot_centers[1] + Vector2(0, 14), slot_centers[2] + Vector2(0, 14), Color("b88249"), 3.0)

	# Selected slot reticle
	var sc: Vector2 = slot_centers[selected_slot]
	var sr: float = slot_radii[selected_slot] + 5.0
	draw_rect(Rect2(sc.x - sr, sc.y - sr, sr * 2.0, sr * 2.0), Color("ffd466"), false, 1.5)
