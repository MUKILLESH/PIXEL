extends StaticBody2D
## Reusable procedural pixel-art interactable for Chapter 3 (Ironwatch Keep: The Keeper's Lie).

signal message_requested(text: String)
signal proximity_changed(nearby: bool)

@export var kind: String = "courtyard_arch"
@export var item_id: String = ""
@export var speaker_name: String = "IRONWATCH KEEP"
@export var prompt_text: String = "[E] INSPECT"
@export_multiline var message: String = ""
@export var interaction_priority: int = 10
@export var notice_board: bool = false

var selected: bool = false
var nearby_player: CharacterBody2D
var dialogue_open: bool = false

var collected: bool = false
var inspected: bool = false
var solved: bool = false
var activated: bool = false
var unlocked: bool = false
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
		if kind in ["crest_clue", "barracks_keepsake", "elena_research"]:
			shape.radius = 4.0
		elif kind == "courtyard_monument":
			shape.radius = 12.0
		else:
			shape.radius = 8.0
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
		circle.radius = 44.0 if kind == "courtyard_monument" else 42.0
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

func get_ironwatch_kind() -> String:
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
		draw_arc(Vector2(0, 2), 18.0, 0.0, TAU, 24, Color(0.98, 0.88, 0.55, 0.72), 1.6)
	match kind:
		"floodmill_return_gate":
			draw_colored_polygon(PackedVector2Array([Vector2(-15, 0), Vector2(0, -8), Vector2(15, 0), Vector2(0, 8)]), halo_col)
			draw_rect(Rect2(-9, -24, 18, 24), Color("3c454a"))
			draw_rect(Rect2(-6, -21, 12, 19), Color("1f262b"))
			draw_rect(Rect2(-3, -15, 6, 8), Color("67b5cc"))
		"courtyard_arch":
			draw_colored_polygon(PackedVector2Array([Vector2(-18, 0), Vector2(0, -10), Vector2(18, 0), Vector2(0, 10)]), halo_col)
			draw_rect(Rect2(-12, -30, 6, 30), Color("3c4252"))
			draw_rect(Rect2(6, -30, 6, 30), Color("292e3b"))
			draw_rect(Rect2(-14, -34, 28, 6), Color("52596e"))
			draw_rect(Rect2(-4, -27, 8, 5), Color("b78be8"))
		"courtyard_monument":
			# Circle of 4 hooded stone Warden statues facing an engraved center plaque
			draw_circle(Vector2.ZERO, 18.0, Color(0.18, 0.20, 0.27, 0.55))
			draw_circle(Vector2.ZERO, 6.0, Color("e6b85c") if inspected else Color("6f768a"))
			var statue_offsets := [Vector2(-12, -8), Vector2(12, -8), Vector2(-12, 8), Vector2(12, 8)]
			for so in statue_offsets:
				draw_rect(Rect2(so.x - 4, so.y - 20, 8, 20), Color("586073"))
				draw_rect(Rect2(so.x - 3, so.y - 24, 6, 5), Color("70798f"))
				draw_rect(Rect2(so.x - 1, so.y - 16, 2, 3), Color("e6b85c") if inspected else Color("988eb5"))
		"warden_records":
			# Reading chest/pedestal inside the cutaway Archives with an illuminated ledger
			draw_rect(Rect2(-12, -14, 24, 14), Color("4f3622"))
			draw_rect(Rect2(-10, -17, 20, 5), Color("6b492e"))
			draw_rect(Rect2(-7, -21, 14, 6), Color("f2e6c2"))
			draw_line(Vector2(0, -21), Vector2(0, -15), Color("7a3c28"), 1.5)
			draw_circle(Vector2(6, -21), 2.5, Color("ffd97d"))
		"barracks_log":
			draw_rect(Rect2(-11, -15, 22, 15), Color("463a30"))
			draw_rect(Rect2(-9, -18, 18, 5), Color("615144"))
			draw_rect(Rect2(-6, -21, 9, 5), Color("ded3b6"))
			draw_rect(Rect2(4, -23, 5, 6), Color("7b8496"))
		"barracks_keepsake":
			if not collected:
				draw_rect(Rect2(-7, -10, 14, 10), Color("3f3932"))
				draw_circle(Vector2(0, -12), 4.0, Color("ffd86b"))
				draw_circle(Vector2(0, -12), 2.0, Color("70b8cc"))
			else:
				draw_rect(Rect2(-6, -8, 12, 8), Color("34302b"))
		"crest_clue":
			var stone := Color("433f5e") if not inspected else Color("635494")
			draw_rect(Rect2(-8, -24, 16, 24), stone)
			draw_rect(Rect2(-10, -27, 20, 4), Color("d9a94e"))
			draw_rect(Rect2(-5, -20, 10, 12), Color("1d1a2e"))
			draw_rect(Rect2(-3, -18, 6, 8), Color("8be6f0") if inspected else Color("e096f5"))
		"crest_altar":
			if solved:
				draw_colored_polygon(PackedVector2Array([Vector2(-20, 0), Vector2(0, -11), Vector2(20, 0), Vector2(0, 11)]), Color(0.42, 0.90, 0.96, 0.25))
			draw_rect(Rect2(-13, -15, 26, 15), Color("332a4f"))
			draw_rect(Rect2(-11, -24, 22, 10), Color("4c3f75"))
			var gem := Color("8be6f0") if solved else Color("d998ff")
			draw_colored_polygon(PackedVector2Array([Vector2(-6, -24), Vector2(0, -35), Vector2(6, -24), Vector2(0, -19)]), gem)
		"shadow_ward_switch":
			draw_rect(Rect2(-7, -18, 14, 18), Color("2f3047"))
			draw_rect(Rect2(-9, -21, 18, 4), Color("53547a"))
			var flame := Color("8be6f0") if solved else Color("ff9e5e")
			draw_circle(Vector2(0, -27), 5.0, flame)
			draw_circle(Vector2(0, -27), 2.5, Color("ffffff"))
		"elena_research":
			draw_rect(Rect2(-10, -15, 20, 15), Color("362e54"))
			draw_rect(Rect2(-8, -21, 16, 7), Color("3d7a8f"))
			draw_rect(Rect2(-6, -20, 12, 5), Color("fff1c7"))
			draw_circle(Vector2(0, -24), 2.0, Color("8be6ff") if inspected else Color("ffd86b"))
		"third_beacon":
			preload("res://scripts/world/ironwatch_art.gd").beacon(self,activated)
		"dawnspire_gate":
			if unlocked:
				draw_colored_polygon(PackedVector2Array([Vector2(-18, 0), Vector2(0, -10), Vector2(18, 0), Vector2(0, 10)]), Color(0.95, 0.84, 0.44, 0.28))
			draw_rect(Rect2(-12, -36, 24, 36), Color("383254"))
			draw_rect(Rect2(5, -36, 7, 36), Color("25213b"))
			draw_colored_polygon(PackedVector2Array([Vector2(-14, -36), Vector2(0, -45), Vector2(14, -36)]), Color("6b5ca3"))
			draw_rect(Rect2(-6, -26, 12, 19), Color("141122"))
			draw_rect(Rect2(-4, -24, 8, 16), Color("ffe38f") if unlocked else Color("964552"))
			if not unlocked:
				for bx in [-2, 2]:
					draw_line(Vector2(bx, -26), Vector2(bx, -7), Color("6f768a"), 1.5)
