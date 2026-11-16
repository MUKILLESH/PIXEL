extends StaticBody2D
## Reusable procedural pixel-art interactable for Chapter 4 (Dawnspire Mountain).

signal message_requested(text: String)
signal proximity_changed(nearby: bool)

@export var kind: String = "foothills_entrance"
@export var item_id: String = ""
@export var speaker_name: String = "DAWNSPIRE MOUNTAIN"
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
		if kind in ["skybridge_part", "elena_journal", "optional_discovery"]:
			shape.radius = 4.0
		elif kind in ["celestial_mechanism", "sanctuary_nexus"]:
			shape.radius = 10.0
		else:
			shape.radius = 7.0
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
		circle.radius = 44.0 if kind in ["celestial_mechanism", "sanctuary_nexus"] else 42.0
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

func get_dawnspire_kind() -> String:
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
		"ironwatch_return_gate":
			draw_colored_polygon(PackedVector2Array([Vector2(-15, 0), Vector2(0, -8), Vector2(15, 0), Vector2(0, 8)]), halo_col)
			draw_rect(Rect2(-9, -24, 18, 24), Color("363d4f"))
			draw_rect(Rect2(-6, -21, 12, 19), Color("191e29"))
			draw_rect(Rect2(-3, -15, 6, 8), Color("9c7ce8"))
		"foothills_entrance", "cliff_marker", "observatory_arch", "sanctuary_threshold":
			draw_rect(Rect2(-8, -24, 16, 24), Color("384357") if not inspected else Color("4a6178"))
			draw_rect(Rect2(-10, -27, 20, 5), Color("d9a94e"))
			draw_rect(Rect2(-4, -20, 8, 10), Color("8be6f0") if inspected else Color("7c8ea8"))
		"skybridge_console":
			draw_rect(Rect2(-11, -18, 22, 18), Color("3b4252"))
			draw_rect(Rect2(-9, -24, 18, 7), Color("56627a"))
			draw_circle(Vector2(0, -20), 4.0, Color("8be6f0") if solved else Color("e09648"))
		"skybridge_diagram":
			draw_rect(Rect2(-10, -20, 20, 20), Color("4a5469"))
			draw_rect(Rect2(-7, -17, 14, 11), Color("e6d7b3"))
			draw_line(Vector2(-5, -13), Vector2(5, -13), Color("4f3622"), 1.5)
			draw_line(Vector2(-5, -9), Vector2(5, -9), Color("4f3622"), 1.5)
		"skybridge_part":
			if not collected:
				draw_rect(Rect2(-8, -12, 16, 12), Color("524333"))
				draw_circle(Vector2(0, -14), 5.0, Color("d99b43"))
				draw_circle(Vector2(0, -14), 2.0, Color("fff1b8"))
			else:
				draw_rect(Rect2(-6, -8, 12, 8), Color("333742"))
		"refuge_mural":
			draw_rect(Rect2(-12, -24, 24, 24), Color("444b61"))
			draw_rect(Rect2(-9, -21, 18, 16), Color("c7b08b"))
			draw_circle(Vector2(0, -13), 4.0, Color("d96b52") if inspected else Color("7c5b40"))
		"elena_journal":
			draw_rect(Rect2(-10, -14, 20, 14), Color("42352b"))
			draw_rect(Rect2(-7, -19, 14, 6), Color("8a3b2e"))
			draw_rect(Rect2(-5, -18, 10, 4), Color("f2e6c2"))
			draw_circle(Vector2(7, -18), 2.5, Color("ffd97d"))
		"celestial_clue":
			var base_c := Color("435478") if inspected else Color("343f59")
			draw_rect(Rect2(-8, -24, 16, 24), base_c)
			draw_rect(Rect2(-10, -27, 20, 4), Color("d9a94e"))
			draw_circle(Vector2(0, -15), 4.0, Color("8be6f0") if inspected else Color("ffd86b"))
		"celestial_mechanism":
			if solved:
				draw_colored_polygon(PackedVector2Array([Vector2(-22, 0), Vector2(0, -12), Vector2(22, 0), Vector2(0, 12)]), Color(0.45, 0.90, 1.0, 0.28))
			draw_rect(Rect2(-13, -16, 26, 16), Color("364259"))
			draw_arc(Vector2(0, -24), 10.0, 0.0, TAU, 24, Color("d9a94e"), 2.0)
			draw_circle(Vector2(0, -24), 5.0, Color("8ef5ff") if solved else Color("6c7894"))
		"sanctuary_nexus":
			if activated:
				draw_colored_polygon(PackedVector2Array([Vector2(-26, 0), Vector2(0, -14), Vector2(26, 0), Vector2(0, 14)]), Color(0.98, 0.88, 0.48, 0.32))
			draw_rect(Rect2(-14, -15, 28, 15), Color("363f57"))
			draw_rect(Rect2(-10, -34, 20, 19), Color("4b5878"))
			var crystal_c := Color("8ef5ff") if activated else Color("c7a454")
			draw_colored_polygon(PackedVector2Array([Vector2(-7, -36), Vector2(0, -54), Vector2(7, -36), Vector2(0, -28)]), crystal_c)
			draw_circle(Vector2(0, -40), 3.0, Color("ffffff") if activated else Color("ffe38f"))
		"great_bell_gate":
			if unlocked:
				draw_colored_polygon(PackedVector2Array([Vector2(-18, 0), Vector2(0, -10), Vector2(18, 0), Vector2(0, 10)]), Color(0.98, 0.86, 0.44, 0.30))
			draw_rect(Rect2(-12, -36, 24, 36), Color("363e52"))
			draw_rect(Rect2(-6, -26, 12, 20), Color("ffe38f") if unlocked else Color("4a2836"))
			if not unlocked:
				for bx in [-3, 3]:
					draw_line(Vector2(bx, -26), Vector2(bx, -6), Color("8893ab"), 1.6)
		"optional_discovery":
			if not collected:
				draw_rect(Rect2(-8, -11, 16, 11), Color("463b32"))
				draw_circle(Vector2(0, -14), 3.5, Color("8be6f0"))
			else:
				draw_rect(Rect2(-6, -8, 12, 8), Color("343742"))
