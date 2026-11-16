extends StaticBody2D
## Reusable procedural pixel-art interactable for Chapter 5 (The Great Bell Sanctum).

signal message_requested(text: String)
signal proximity_changed(nearby: bool)

@export var kind: String = "antechamber_threshold"
@export var item_id: String = ""
@export var speaker_name: String = "THE GREAT BELL"
@export var prompt_text: String = "[E] INSPECT"
@export_multiline var message: String = ""
@export var interaction_priority: int = 10
@export var notice_board: bool = false

var selected: bool = false
var nearby_player: CharacterBody2D
var dialogue_open: bool = false

var collected: bool = false
var inspected: bool = false
var activated: bool = false
var stabilized: bool = false
var severed: bool = false
var journal_placed: bool = false
var ready_to_travel: bool = false

var indicator: Label
var range_area: Area2D

func _ready() -> void:
	add_to_group("interactables")
	collision_layer = 1
	collision_mask = 2

	if not has_node("Solid"):
		var solid := CollisionShape2D.new()
		solid.name = "Solid"
		solid.position = Vector2(0, -3)
		var shape := CircleShape2D.new()
		if kind in ["memory_crystal", "dawn_terrace_overlook"]:
			shape.radius = 5.0
		elif kind in ["great_bell_binding", "dawn_memorial", "beacon_conduit"]:
			shape.radius = 8.0
		else:
			shape.radius = 6.0
		solid.shape = shape
		add_child(solid)

	if not has_node("Range"):
		range_area = Area2D.new()
		range_area.name = "Range"
		range_area.collision_layer = 0
		range_area.collision_mask = 2
		var r_shape := CollisionShape2D.new()
		r_shape.name = "Shape"
		var circle := CircleShape2D.new()
		circle.radius = 44.0 if kind in ["great_bell_binding", "dawn_memorial"] else 40.0
		r_shape.shape = circle
		range_area.add_child(r_shape)
		add_child(range_area)
	else:
		range_area = $Range

	range_area.body_entered.connect(_on_entered)
	range_area.body_exited.connect(_on_exited)

	if not has_node("Indicator"):
		indicator = Label.new()
		indicator.name = "Indicator"
		indicator.visible = false
		indicator.z_index = 12
		indicator.offset_left = -114
		indicator.offset_top = -48
		indicator.offset_right = 114
		indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		indicator.add_theme_font_size_override("font_size", 8)
		indicator.add_theme_color_override("font_color", Color("fae08c"))
		indicator.add_theme_color_override("font_shadow_color", Color("120e0b"))
		indicator.add_theme_constant_override("shadow_offset_x", 1)
		indicator.add_theme_constant_override("shadow_offset_y", 1)
		add_child(indicator)
	else:
		indicator = $Indicator
	indicator.text = prompt_text

func get_great_bell_kind() -> String:
	return kind

func refresh_prompt(new_text: String) -> void:
	prompt_text = new_text
	if indicator != null:
		indicator.text = new_text

func _on_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		nearby_player = body
		indicator.visible = selected and not dialogue_open
		proximity_changed.emit(true)

func _on_exited(body: Node2D) -> void:
	if body == nearby_player:
		nearby_player = null
		indicator.hide()
		proximity_changed.emit(false)

func set_selected(value: bool) -> void:
	selected = value
	if indicator != null:
		indicator.visible = selected and nearby_player != null and not dialogue_open
	queue_redraw()

func set_dialogue_open(open: bool) -> void:
	dialogue_open = open
	if indicator != null:
		indicator.visible = selected and nearby_player != null and not dialogue_open
	if open:
		_release_player_input()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if dialogue_open or not selected or nearby_player == null:
		return
	if event.is_action_pressed("interact"):
		var vp: Viewport = get_viewport()
		if vp != null and is_inside_tree():
			vp.set_input_as_handled()
		message_requested.emit(message)

func _release_player_input() -> void:
	for action in ["move_left", "move_right", "move_up", "move_down"]:
		if InputMap.has_action(action) and Input.is_action_pressed(action):
			Input.action_release(action)

func _draw() -> void:
	var halo_col := Color(0.98, 0.88, 0.55, 0.34) if selected else Color(0.55, 0.85, 0.96, 0.14)
	if selected:
		draw_arc(Vector2(0, 2), 17.0, 0.0, TAU, 24, Color(0.98, 0.88, 0.55, 0.75), 1.5)
	match kind:
		"sanctum_dawnspire_gate", "bellhaven_sunrise_arch":
			draw_colored_polygon(PackedVector2Array([Vector2(-14, 0), Vector2(0, -7), Vector2(14, 0), Vector2(0, 7)]), halo_col)
			draw_rect(Rect2(-9, -24, 18, 24), Color("434d63"))
			draw_rect(Rect2(-6, -21, 12, 19), Color("1f2636"))
			draw_rect(Rect2(-3, -15, 6, 8), Color("ffd470") if kind == "bellhaven_sunrise_arch" else Color("8be6f0"))
		"antechamber_threshold", "forgotten_hall_arch", "dawn_terrace_overlook":
			draw_rect(Rect2(-7, -22, 14, 22), Color("3c475e") if not inspected else Color("586a88"))
			draw_rect(Rect2(-9, -25, 18, 4), Color("d9a94e"))
			draw_rect(Rect2(-3, -18, 6, 9), Color("ffdf7d") if kind == "dawn_terrace_overlook" else Color("8be6f0"))
		"memory_crystal":
			draw_colored_polygon(PackedVector2Array([Vector2(-10, -2), Vector2(0, -8), Vector2(10, -2), Vector2(0, 4)]), Color(0.45, 0.88, 0.98, 0.25 if not collected else 0.10))
			draw_rect(Rect2(-5, -10, 10, 10), Color("384359"))
			var crystal_c: Color = Color("d9c07e") if collected else Color("8bf0ff")
			draw_colored_polygon(PackedVector2Array([Vector2(-4, -10), Vector2(0, -26), Vector2(4, -10)]), crystal_c)
		"warden_record":
			draw_rect(Rect2(-9, -22, 18, 22), Color("374054"))
			draw_rect(Rect2(-6, -19, 12, 14), Color("d4c49c") if inspected else Color("6f7f99"))
			draw_rect(Rect2(-4, -17, 8, 2), Color("52412c"))
		"elena_echo_plinth":
			draw_colored_polygon(PackedVector2Array([Vector2(-12, -2), Vector2(0, -9), Vector2(12, -2), Vector2(0, 5)]), Color(0.95, 0.84, 0.48, 0.26))
			draw_rect(Rect2(-6, -18, 12, 18), Color("46536b"))
			draw_circle(Vector2(0, -24), 5.0, Color("fae08c") if inspected else Color("8ceeff"))
			draw_circle(Vector2(0, -24), 2.5, Color("ffffff"))
		"beacon_conduit":
			draw_colored_polygon(PackedVector2Array([Vector2(-13, -2), Vector2(0, -9), Vector2(13, -2), Vector2(0, 5)]), halo_col)
			draw_rect(Rect2(-7, -18, 14, 18), Color("384256"))
			draw_rect(Rect2(-9, -21, 18, 4), Color("667591"))
			var flame_c: Color = Color("5e6678")
			if activated:
				if item_id == "conduit_briarwood":
					flame_c = Color("6ef2a0")
				elif item_id == "conduit_floodmill":
					flame_c = Color("7ce8ff")
				else:
					flame_c = Color("ffd46b")
			draw_circle(Vector2(0, -27), 5.5 if activated else 4.0, flame_c)
			if activated:
				draw_circle(Vector2(0, -27), 2.5, Color("ffffff"))
		"great_bell_binding":
			draw_colored_polygon(PackedVector2Array([Vector2(-16, -2), Vector2(0, -10), Vector2(16, -2), Vector2(0, 6)]), Color(0.98, 0.86, 0.46, 0.28) if severed else halo_col)
			draw_rect(Rect2(-10, -18, 20, 18), Color("3f4759"))
			draw_rect(Rect2(-12, -21, 24, 4), Color("d9a94e") if stabilized else Color("687085"))
			var orb_c: Color = Color("ffe894") if severed else (Color("8be6f0") if stabilized else Color("9c66d4"))
			draw_circle(Vector2(0, -26), 5.0, orb_c)
			draw_circle(Vector2(0, -26), 2.0, Color("ffffff"))
		"dawn_memorial":
			draw_colored_polygon(PackedVector2Array([Vector2(-15, -2), Vector2(0, -9), Vector2(15, -2), Vector2(0, 5)]), halo_col)
			draw_rect(Rect2(-8, -22, 16, 22), Color("9e9481"))
			draw_rect(Rect2(-10, -25, 20, 4), Color("c4b79e"))
			draw_rect(Rect2(-3, -20, 6, 4), Color("f2ca6b"))
			if journal_placed:
				draw_rect(Rect2(5, -6, 6, 4), Color("703f22"))
