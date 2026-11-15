extends StaticBody2D
## Reusable procedural pixel-art interactable for Chapter 1 (Briarwood Forest).

signal message_requested(text: String)
signal proximity_changed(nearby: bool)

@export var kind: String = "waystone_entrance"
@export var item_id: String = ""
@export var speaker_name: String = "BRIARWOOD"
@export var prompt_text: String = "[E] INSPECT"
@export_multiline var message: String = ""
@export var interaction_priority: int = 9
@export var notice_board: bool = false

var selected: bool = false
var nearby_player: CharacterBody2D
var dialogue_open: bool = false

var collected: bool = false
var inspected: bool = false
var repaired: bool = false
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
		shape.radius = 4.0 if kind == "repair_material" else 8.0
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
		circle.radius = 42.0
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
		indicator.offset_left = -104
		indicator.offset_top = -46
		indicator.offset_right = 104
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

func get_briarwood_kind() -> String:
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

func set_dialogue_open(value: bool) -> void:
	dialogue_open = value
	if indicator != null:
		indicator.visible = selected and nearby_player != null and not value

func set_selected(value: bool) -> void:
	selected = value
	if indicator != null:
		indicator.visible = selected and nearby_player != null and not dialogue_open

func _unhandled_input(event: InputEvent) -> void:
	if selected and nearby_player != null and not dialogue_open and event.is_action_pressed("interact") and not event.is_echo():
		message_requested.emit(message)
		get_viewport().set_input_as_handled()

func _draw() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(-11, -1), Vector2(0, -7), Vector2(11, -1), Vector2(0, 5)]), Color(0.02, 0.04, 0.04, 0.35))
	match kind:
		"waystone_entrance":
			draw_rect(Rect2(-8, -28, 16, 28), Color("4f5954"))
			draw_rect(Rect2(4, -28, 4, 28), Color("363d39"))
			draw_colored_polygon(PackedVector2Array([Vector2(-8, -28), Vector2(0, -35), Vector2(8, -28)]), Color("67736c"))
			draw_rect(Rect2(-7, -20, 4, 7), Color("396342"))
			draw_line(Vector2(0, -23), Vector2(0, -11), Color("8be6f0"), 1.0)
			draw_line(Vector2(-4, -17), Vector2(4, -17), Color("ffd466"), 1.0)
		"direction_sign":
			draw_rect(Rect2(-2, -28, 4, 28), Color("4a321d"))
			draw_rect(Rect2(-14, -27, 26, 6), Color("8a613b"))
			draw_rect(Rect2(-12, -19, 26, 6), Color("704e2e"))
			draw_line(Vector2(-10, -24), Vector2(8, -24), Color("d9c79e"), 1.0)
			draw_line(Vector2(-8, -16), Vector2(10, -16), Color("d9c79e"), 1.0)
		"broken_bridge":
			# Stone bridgehead bollard & broken rope mooring
			draw_rect(Rect2(-7, -20, 14, 20), Color("595652"))
			draw_rect(Rect2(-8, -22, 16, 4), Color("75706a"))
			var ring_col := Color("8be6f0") if repaired else Color("b86f44")
			draw_rect(Rect2(-3, -15, 6, 4), ring_col)
			if not repaired:
				draw_line(Vector2(4, -13), Vector2(10, -6), Color("c4a872"), 1.0)
		"worksite_ledger":
			# Carpenter's sawhorse & pinned blueprint scroll
			draw_rect(Rect2(-10, -13, 3, 13), Color("593a20"))
			draw_rect(Rect2(7, -13, 3, 13), Color("593a20"))
			draw_rect(Rect2(-13, -16, 26, 6), Color("855832"))
			draw_rect(Rect2(-8, -18, 16, 7), Color("e6d7b3"))
			draw_line(Vector2(-5, -16), Vector2(5, -16), Color("6b4928"), 1.0)
			draw_line(Vector2(-5, -14), Vector2(4, -14), Color("2f6a70"), 1.0)
		"repair_material":
			if collected:
				draw_rect(Rect2(-6, -3, 12, 3), Color("445241"))
				draw_rect(Rect2(-2, -6, 4, 2), Color("7e9478"))
				return
			if item_id == "rope_coil":
				draw_circle(Vector2(0, -6), 7.0, Color("997a45"))
				draw_circle(Vector2(0, -6), 4.0, Color("c9a769"), false, 2.0)
				draw_rect(Rect2(5, -8, 4, 2), Color("ebd29d"))
			else:
				# Seasoned oak plank stack
				draw_rect(Rect2(-11, -10, 22, 5), Color("8f5c34"))
				draw_rect(Rect2(-9, -15, 20, 5), Color("ab7244"))
				draw_line(Vector2(-8, -13), Vector2(9, -13), Color("613c1f"), 1.0)
				draw_rect(Rect2(-4, -17, 2, 2), Color("ffe89e"))
		"inscription":
			var glow := Color("8be6f0") if inspected else Color("ffca57")
			draw_rect(Rect2(-8, -28, 16, 28), Color("48524c"))
			draw_rect(Rect2(4, -28, 4, 28), Color("323935"))
			draw_rect(Rect2(-9, -31, 18, 4), Color("5d6962"))
			draw_rect(Rect2(-6, -26, 4, 5), Color("3c6e47"))
			draw_rect(Rect2(-4, -22, 8, 12), Color("282e2b"))
			draw_line(Vector2(-2, -19), Vector2(2, -19), glow, 1.0)
			draw_line(Vector2(0, -21), Vector2(0, -13), glow, 1.0)
			draw_rect(Rect2(-1, -16, 2, 2), Color("ffffff") if inspected else glow)
		"mirror_pedestal":
			var rim := Color("8be6f0") if activated else Color("d9b366")
			draw_rect(Rect2(-9, -12, 18, 12), Color("505852"))
			draw_rect(Rect2(-6, -21, 12, 9), Color("69736b"))
			draw_circle(Vector2(0, -24), 7.0, Color("293b47"))
			draw_circle(Vector2(0, -24), 7.0, rim, false, 2.0)
			draw_line(Vector2(-3, -27), Vector2(3, -21), Color("b8f6fc"), 1.5)
		"first_beacon":
			if activated:
				draw_colored_polygon(PackedVector2Array([Vector2(-22, 0), Vector2(0, -12), Vector2(22, 0), Vector2(0, 12)]), Color(0.38, 0.90, 0.94, 0.25))
			draw_rect(Rect2(-12, -14, 24, 14), Color("565c59"))
			draw_rect(Rect2(-8, -32, 16, 18), Color("6e7571"))
			draw_rect(Rect2(3, -32, 5, 18), Color("484d4a"))
			var crystal := Color("8ef5ff") if activated else Color("4a6375")
			var core := Color("ffffff") if activated else Color("89a5b8")
			draw_colored_polygon(PackedVector2Array([Vector2(-5, -34), Vector2(0, -48), Vector2(5, -34), Vector2(0, -28)]), crystal)
			draw_rect(Rect2(-2, -41, 4, 6), core)
		"hidden_relic":
			# Ruined camp surveyor's chest & notebook
			draw_rect(Rect2(-9, -10, 18, 10), Color("5c3d24"))
			draw_rect(Rect2(-8, -9, 16, 4), Color("7a5230"))
			draw_rect(Rect2(-2, -7, 4, 3), Color("e6b85c"))
			draw_rect(Rect2(-5, -13, 10, 3), Color("e3d4b4"))
			if not collected:
				draw_rect(Rect2(6, -13, 2, 2), Color("ffe89e"))
		"floodmill_gate":
			if unlocked:
				draw_colored_polygon(PackedVector2Array([Vector2(-16, 0), Vector2(0, -9), Vector2(16, 0), Vector2(0, 9)]), Color(0.32, 0.82, 0.88, 0.25))
			draw_rect(Rect2(-8, -28, 16, 28), Color("525e5c"))
			draw_rect(Rect2(4, -28, 4, 28), Color("38403f"))
			draw_colored_polygon(PackedVector2Array([Vector2(-8, -28), Vector2(0, -35), Vector2(8, -28)]), Color("6b7a78"))
			var gcol := Color("8be6f0") if unlocked else Color("7c8582")
			draw_line(Vector2(-3, -18), Vector2(3, -18), gcol, 1.0)
			draw_line(Vector2(0, -22), Vector2(0, -12), gcol, 1.0)
			if not unlocked:
				draw_line(Vector2(-9, -8), Vector2(9, -18), Color("374a42"), 2.0)
				draw_line(Vector2(-8, -20), Vector2(8, -10), Color("4e665a"), 2.0)
