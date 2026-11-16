extends StaticBody2D
## Reusable procedural pixel-art interactable for Chapter 2 (Floodmill: The Drowned Village).

signal message_requested(text: String)
signal proximity_changed(nearby: bool)

@export var kind: String = "entrance_arch"
@export var item_id: String = ""
@export var speaker_name: String = "FLOODMILL"
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
		shape.radius = 4.0 if kind in ["mill_part", "archive_record", "optional_lore"] else 8.0
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
		indicator.offset_left = -108
		indicator.offset_top = -46
		indicator.offset_right = 108
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

func get_floodmill_kind() -> String:
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
	draw_colored_polygon(PackedVector2Array([Vector2(-11, -1), Vector2(0, -7), Vector2(11, -1), Vector2(0, 5)]), Color(0.02, 0.04, 0.05, 0.36))
	match kind:
		"entrance_arch":
			draw_rect(Rect2(-9, -28, 18, 28), Color("4f5957"))
			draw_rect(Rect2(5, -28, 4, 28), Color("363d3c"))
			draw_colored_polygon(PackedVector2Array([Vector2(-10, -28), Vector2(0, -35), Vector2(10, -28)]), Color("6b7674"))
			draw_rect(Rect2(-3, -20, 6, 5), Color("8be6f0"))
		"village_plaque":
			var glow := Color("8be6f0") if inspected else Color("d9b366")
			draw_rect(Rect2(-8, -26, 16, 26), Color("535c59"))
			draw_rect(Rect2(-6, -22, 12, 14), Color("363d3b"))
			draw_line(Vector2(-4, -17), Vector2(4, -17), glow, 1.0)
			draw_line(Vector2(-4, -13), Vector2(3, -13), glow, 1.0)
		"optional_lore":
			# Tarnished homestead keepsake box & silver locket
			draw_rect(Rect2(-8, -9, 16, 9), Color("523a28"))
			draw_rect(Rect2(-7, -8, 14, 3), Color("6e4f36"))
			draw_circle(Vector2(0, -10), 3.0, Color("c8d4dc") if not collected else Color("637075"))
		"watermill_mechanism":
			# Heavy iron gear-box clutch pedestal beside mill wheel
			draw_rect(Rect2(-10, -16, 20, 16), Color("464e52"))
			draw_rect(Rect2(-8, -22, 16, 6), Color("667075"))
			var gear_col := Color("8be6f0") if repaired else Color("c98449")
			draw_circle(Vector2(0, -14), 6.0, gear_col, false, 2.0)
			draw_rect(Rect2(-2, -16, 4, 4), Color("e6b85c") if repaired else Color("75523b"))
		"mill_diagram":
			# Pinned oilcloth blueprint easel
			draw_rect(Rect2(-9, -15, 2, 15), Color("4f3622"))
			draw_rect(Rect2(7, -15, 2, 15), Color("4f3622"))
			draw_rect(Rect2(-12, -20, 24, 12), Color("d9ccb0"))
			draw_rect(Rect2(-9, -17, 18, 6), Color("2c5c6b"))
		"mill_part":
			if collected:
				draw_rect(Rect2(-6, -3, 12, 3), Color("3f4d43"))
				return
			if item_id == "oak_coupling_belt":
				draw_circle(Vector2(0, -6), 6.5, Color("8a5934"), false, 3.0)
				draw_rect(Rect2(-2, -13, 4, 2), Color("ffe89e"))
			elif item_id == "bronze_pinion":
				draw_circle(Vector2(0, -6), 6.0, Color("c48a47"))
				draw_circle(Vector2(0, -6), 2.0, Color("29231d"))
			else: # iron_drive_gear
				draw_circle(Vector2(0, -7), 7.5, Color("7e8b94"))
				draw_circle(Vector2(0, -7), 3.0, Color("24292e"))
				draw_rect(Rect2(-1, -15, 2, 3), Color("ffe89e"))
		"sluice_console":
			# Brass and iron three-lever weir console
			draw_rect(Rect2(-12, -16, 24, 16), Color("4c5557"))
			draw_rect(Rect2(-10, -21, 20, 5), Color("6c7678"))
			var lcol := Color("8be6f0") if unlocked else Color("e6b85c")
			for lx in [-6, 0, 6]:
				draw_line(Vector2(lx, -18), Vector2(lx, -27), Color("b8c2c7"), 1.5)
				draw_rect(Rect2(lx - 1.5, -28, 3, 3), lcol)
		"canal_clue":
			# Brass canal water-level gauge post
			draw_rect(Rect2(-3, -24, 6, 24), Color("4f5957"))
			draw_rect(Rect2(-6, -22, 12, 8), Color("d9b366"))
			draw_line(Vector2(-4, -18), Vector2(4, -18), Color("1f4959"), 2.0)
		"archive_entrance":
			# Carved sandstone library lectern & bell emblem
			draw_rect(Rect2(-8, -16, 16, 16), Color("574b41"))
			draw_rect(Rect2(-10, -20, 20, 5), Color("7a634b"))
			draw_rect(Rect2(-6, -22, 12, 3), Color("e6dcc5"))
		"archive_record":
			# Open surviving parchment scroll on pedestal / lectern
			draw_rect(Rect2(-8, -11, 16, 11), Color("4d3624"))
			draw_rect(Rect2(-10, -14, 20, 4), Color("6e4d34"))
			if collected:
				draw_rect(Rect2(-6, -16, 12, 3), Color("8fd6e8"))
			else:
				draw_rect(Rect2(-6, -16, 12, 4), Color("f2e4c4"))
				draw_rect(Rect2(2, -16, 3, 2), Color("b84435"))
		"ledger_table":
			# Large Archive Oak Reading Table & brass binding clasps
			draw_rect(Rect2(-15, -12, 30, 12), Color("593a23"))
			draw_rect(Rect2(-17, -17, 34, 6), Color("7d5232"))
			var book_col := Color("8be6f0") if activated else Color("e6d4ad")
			draw_rect(Rect2(-8, -20, 16, 5), book_col)
			draw_rect(Rect2(9, -20, 3, 4), Color("ffca57"))
		"second_beacon":
			if activated:
				draw_colored_polygon(PackedVector2Array([Vector2(-24, 0), Vector2(0, -13), Vector2(24, 0), Vector2(0, 13)]), Color(0.40, 0.92, 0.96, 0.28))
			draw_rect(Rect2(-13, -15, 26, 15), Color("4f5959"))
			draw_rect(Rect2(-9, -34, 18, 19), Color("677373"))
			draw_rect(Rect2(3, -34, 6, 19), Color("414a4a"))
			var crystal := Color("8ef5ff") if activated else Color("4a6375")
			var core := Color("ffffff") if activated else Color("89a5b8")
			draw_colored_polygon(PackedVector2Array([Vector2(-6, -36), Vector2(0, -50), Vector2(6, -36), Vector2(0, -29)]), crystal)
			draw_rect(Rect2(-2, -43, 4, 6), core)
		"ironwatch_gate":
			# Basalt mountain keep archway with iron portcullis bars
			if unlocked:
				draw_colored_polygon(PackedVector2Array([Vector2(-16, 0), Vector2(0, -9), Vector2(16, 0), Vector2(0, 9)]), Color(0.32, 0.82, 0.88, 0.24))
			draw_rect(Rect2(-10, -30, 20, 30), Color("3c434a"))
			draw_rect(Rect2(5, -30, 5, 30), Color("282d33"))
			draw_colored_polygon(PackedVector2Array([Vector2(-11, -30), Vector2(0, -37), Vector2(11, -30)]), Color("525c66"))
			var glow_col := Color("8be6f0") if unlocked else Color("a85143")
			draw_rect(Rect2(-4, -22, 8, 14), Color("191d24"))
			draw_rect(Rect2(-2, -26, 4, 3), glow_col)
			if not unlocked:
				for bx in [-2, 1]:
					draw_line(Vector2(bx, -22), Vector2(bx, -8), Color("6e7885"), 1.5)
