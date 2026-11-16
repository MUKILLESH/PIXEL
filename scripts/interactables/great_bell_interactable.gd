extends StaticBody2D
## Reusable procedural pixel-art interactable for Chapter 5 (The Great Bell Sanctum).

const Art = preload("res://scripts/world/great_bell_art.gd")

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
	Art.ellipse(self, Vector2(0, 1), 11.0, 5.0, Color(0, 0, 0, 0.34))
	if selected:
		Art.ellipse_band(self, Vector2(0, 2), 18.0, 9.0, 1.5, Color(0.98, 0.88, 0.55, 0.85))
	match kind:
		"sanctum_dawnspire_gate", "bellhaven_sunrise_arch":
			draw_colored_polygon(PackedVector2Array([Vector2(-15, 0), Vector2(0, -7), Vector2(15, 0), Vector2(0, 7)]), halo_col)
			Art.px(self, -10, -26, 20, 26, Color(Art.STONE[4]))
			Art.px(self, -10, -26, 4, 26, Color(Art.STONE[6]))
			draw_colored_polygon(PackedVector2Array([Vector2(-11, -26), Vector2(0, -32), Vector2(11, -26)]), Color(Art.STONE[5]))
			Art.px(self, -6, -21, 12, 19, Color(Art.STONE[1]))
			var portal_c: Color = Color(Art.GOLD[3]) if kind == "bellhaven_sunrise_arch" else Color(Art.CYAN[3])
			Art.px(self, -4, -17, 8, 12, portal_c)
			Art.px(self, -2, -15, 4, 8, Color("ffffff"))
		"antechamber_threshold", "forgotten_hall_arch", "dawn_terrace_overlook":
			var body_c := Color(Art.STONE[5] if inspected else Art.STONE[4])
			Art.px(self, -8, -24, 16, 24, body_c)
			Art.px(self, -8, -24, 3, 24, Color(Art.STONE[7]))
			Art.px(self, -10, -27, 20, 4, Color(Art.GOLD[2]))
			Art.px(self, -4, -19, 8, 10, Color(Art.GOLD[3] if kind == "dawn_terrace_overlook" else Art.CYAN[3]))
			Art.px(self, -2, -17, 4, 6, Color("ffffff"))
			Art.glyph(self, -1.5, -7.0, 3, Color(Art.GOLD[2]))
		"memory_crystal":
			Art.ellipse(self, Vector2(0, 0), 11.0, 6.0, Color(0.45, 0.88, 0.98, 0.28 if not collected else 0.14))
			Art.px(self, -6, -9, 12, 9, Color(Art.STONE[4]))
			Art.px(self, -7, -10, 14, 2, Color(Art.BRONZE[4]))
			var c_base: Color = Color(Art.GOLD[2]) if collected else Color(Art.CYAN[2])
			var c_hi: Color = Color(Art.GOLD[4]) if collected else Color(Art.CYAN[4])
			draw_colored_polygon(PackedVector2Array([Vector2(-5, -10), Vector2(0, -28), Vector2(5, -10)]), c_base)
			draw_colored_polygon(PackedVector2Array([Vector2(-4, -10), Vector2(-1, -26), Vector2(1, -10)]), c_hi)
			# Floating crystal splinters
			Art.px(self, -8, -21, 2, 3, c_hi)
			Art.px(self, 6, -18, 2, 3, c_hi)
		"warden_record":
			Art.px(self, -10, -22, 20, 22, Color(Art.STONE[3]))
			Art.px(self, -10, -22, 3, 22, Color(Art.STONE[6]))
			Art.px(self, -11, -24, 22, 3, Color(Art.BRONZE[4]))
			Art.px(self, -7, -21, 14, 12, Color("d4c49c") if inspected else Color("6f7f99"))
			Art.inscription(self, -5, -18, 10, 17, Color("4a3824"), Color("ebe0c4") if inspected else Color("9eb0cf"))
			Art.inscription(self, -5, -14, 10, 29, Color("4a3824"), Color("ebe0c4") if inspected else Color("9eb0cf"))
		"elena_echo_plinth":
			Art.ellipse(self, Vector2(0, 0), 13.0, 6.5, Color(0.95, 0.84, 0.48, 0.28))
			Art.px(self, -7, -18, 14, 18, Color(Art.STONE[5]))
			Art.px(self, -8, -20, 16, 3, Color(Art.BRONZE[5]))
			Art.px(self, -6, -24, 2, 5, Color(Art.GOLD[2]))
			Art.px(self, 4, -24, 2, 5, Color(Art.GOLD[2]))
			var e_col := Color(Art.GOLD[3]) if inspected else Color(Art.CYAN[3])
			Art.ellipse(self, Vector2(0, -25), 5.0, 5.0, e_col)
			Art.ellipse(self, Vector2(-1, -26), 2.5, 2.5, Color("ffffff"))
		"beacon_conduit":
			draw_colored_polygon(PackedVector2Array([Vector2(-14, -2), Vector2(0, -9), Vector2(14, -2), Vector2(0, 5)]), halo_col)
			var pal: Array = Art.BRIAR if item_id == "conduit_briarwood" else (Art.FLOOD if item_id == "conduit_floodmill" else Art.IRON)
			Art.px(self, -8, -16, 16, 16, Color(Art.STONE[4]))
			Art.px(self, -8, -16, 4, 16, Color(Art.STONE[6]))
			Art.px(self, -9, -19, 18, 4, Color(pal[1] if not activated else pal[2]))
			Art.px(self, -9, -19, 18, 1, Color(pal[3] if activated else Art.STONE[7]))
			if item_id == "conduit_briarwood":
				# Emerald forest cradle & glowing leaf orb
				Art.px(self, -5, -11, 10, 3, Color(Art.BRIAR[2]))
				Art.ellipse(self, Vector2(0, -24), 5.0, 5.0, Color(Art.BRIAR[3] if activated else Art.BRIAR[1]))
			elif item_id == "conduit_floodmill":
				# Sapphire tidal basin & aqua droplet spire
				Art.px(self, -4, -12, 8, 4, Color(Art.FLOOD[2]))
				Art.ellipse(self, Vector2(0, -24), 5.0, 5.0, Color(Art.FLOOD[3] if activated else Art.FLOOD[1]))
			else:
				# Warden gilded iron anvil & solar ember
				Art.px(self, -5, -12, 10, 4, Color(Art.IRON[2]))
				Art.ellipse(self, Vector2(0, -24), 5.0, 5.0, Color(Art.IRON[3] if activated else Art.IRON[1]))
			if activated:
				Art.ellipse(self, Vector2(-1, -25), 2.5, 2.5, Color("ffffff"))
		"great_bell_binding":
			draw_colored_polygon(PackedVector2Array([Vector2(-17, -2), Vector2(0, -10), Vector2(17, -2), Vector2(0, 6)]), Color(0.98, 0.86, 0.46, 0.30) if severed else halo_col)
			Art.px(self, -11, -17, 22, 17, Color(Art.STONE[4]))
			Art.px(self, -11, -17, 5, 17, Color(Art.STONE[6]))
			Art.px(self, -13, -20, 26, 4, Color(Art.GOLD[2] if stabilized else Art.BRONZE[3]))
			Art.px(self, -13, -20, 26, 1, Color(Art.GOLD[3] if stabilized else Art.BRONZE[6]))
			var orb_c: Color = Color(Art.GOLD[3]) if severed else (Color(Art.CYAN[3]) if stabilized else Color(Art.AMETHYST[4]))
			Art.ellipse(self, Vector2(0, -26), 5.5, 5.5, orb_c)
			Art.ellipse(self, Vector2(-1, -27), 2.0, 2.0, Color("ffffff"))
		"dawn_memorial":
			draw_colored_polygon(PackedVector2Array([Vector2(-16, -2), Vector2(0, -9), Vector2(16, -2), Vector2(0, 5)]), halo_col)
			Art.px(self, -10, -28, 20, 28, Color(Art.LIME[4]))
			Art.px(self, -10, -28, 4, 28, Color(Art.LIME[5]))
			draw_colored_polygon(PackedVector2Array([Vector2(-11, -28), Vector2(0, -35), Vector2(11, -28)]), Color(Art.LIME[5]))
			Art.px(self, -2, -26, 4, 3, Color(Art.GOLD[3]))
			for ry in [-20, -16, -12]:
				Art.inscription(self, -6, ry, 12, absi(ry), Color("594c38"), Color(Art.GOLD[2]))
			if journal_placed:
				Art.px(self, 6, -6, 8, 5, Color("703f22"))
				Art.px(self, 8, -5, 4, 2, Color(Art.GOLD[3]))
