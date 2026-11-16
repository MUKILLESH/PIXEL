extends StaticBody2D
## Reusable medieval villager NPC supporting quest-aware dialogue and pixel idle animation.

signal message_requested(text: String)
signal proximity_changed(nearby: bool)

@export var npc_id: String = "caelen"
@export var speaker_name: String = "MASTER CAELEN"
@export var prompt_text: String = "[E] TALK TO MASTER CAELEN"
@export var interaction_priority: int = 8
@export var notice_board: bool = false
@export var facing: int = 2

var selected: bool = false
var nearby_player: CharacterBody2D
var dialogue_open: bool = false
var idle_time: float = 0.0
var idle_frame: int = 0

func _ready() -> void:
	add_to_group("interactables")
	$Indicator.text = prompt_text
	$Indicator.offset_left = -96
	$Indicator.offset_right = 96
	$Indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Range.body_entered.connect(_on_entered)
	$Range.body_exited.connect(_on_exited)

func get_npc_id() -> String:
	return npc_id

func refresh_prompt(new_text: String) -> void:
	prompt_text = new_text
	if has_node("Indicator"):
		$Indicator.text = new_text

func face_toward(world_pos: Vector2) -> void:
	var delta_vec: Vector2 = world_pos - global_position
	if delta_vec.length_squared() > 4.0:
		facing = posmod(roundi(delta_vec.angle() / (PI / 4.0)), 8)
		queue_redraw()

func _process(delta: float) -> void:
	idle_time += delta
	var next_frame: int = int(idle_time * 1.8) % 2
	if next_frame != idle_frame:
		idle_frame = next_frame
		queue_redraw()

func _on_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		nearby_player = body
		$Indicator.visible = selected and not dialogue_open
		proximity_changed.emit(true)

func _on_exited(body: Node2D) -> void:
	if body == nearby_player:
		nearby_player = null
		$Indicator.hide()
		proximity_changed.emit(false)

func set_dialogue_open(value: bool) -> void:
	dialogue_open = value
	$Indicator.visible = selected and nearby_player != null and not value

func set_selected(value: bool) -> void:
	selected = value
	$Indicator.visible = selected and nearby_player != null and not dialogue_open

func _unhandled_input(event: InputEvent) -> void:
	if selected and nearby_player != null and not dialogue_open and event.is_action_pressed("interact") and not event.is_echo():
		face_toward(nearby_player.global_position)
		message_requested.emit("")
		get_viewport().set_input_as_handled()

func _draw() -> void:
	# Ground shadow anchored at feet
	draw_rect(Rect2(-8, -2, 16, 4), Color(0.02, 0.03, 0.05, 0.38))
	var bob: int = idle_frame
	var side: int = 1 if facing in [0, 1, 7] else (-1 if facing in [3, 4, 5] else 0)
	if dialogue_open:
		# Subtle speech attention emblem above NPC head during conversation
		var badge_y: float = -45.0 + float(bob)
		draw_colored_polygon(PackedVector2Array([Vector2(0, badge_y - 4), Vector2(4, badge_y), Vector2(0, badge_y + 4), Vector2(-4, badge_y)]), Color("fae08c"))
		draw_rect(Rect2(-1, badge_y - 1, 2, 2), Color("161924"))

	match npc_id:
		"caelen":
			# Elderly bell keeper: dark boots, burgundy & slate robe, white beard, brass hand lantern
			patch(-5, -27 + bob, 10, 17, "161924")
			patch(-4, -12, 3, 10, "2b2420")
			patch(1, -12, 3, 10, "2b2420")
			patch(-4, -26 + bob, 8, 17, "6b333b")
			patch(-2, -26 + bob, 4, 15, "424a59")
			patch(-4, -15 + bob, 8, 2, "c79b4b")
			# Head & silver hair/beard
			patch(-4 + side, -37 + bob, 8, 9, "dbb08e")
			patch(-5 + side, -39 + bob, 10, 4, "b8bec9")
			patch(-3 + side, -31 + bob, 6, 4, "cfd6e0")
			patch(-2 + side, -34 + bob, 1, 1, "242b38")
			patch(1 + side, -34 + bob, 1, 1, "242b38")
			# Warm brass hand lantern held on side
			patch(5, -20 + bob, 2, 4, "4a3a28")
			patch(4, -15 + bob, 4, 5, "ffbe4f")
			patch(5, -14 + bob, 2, 3, "fff0b8")
		"mira":
			# Village blacksmith: sturdy linen tunic, heavy leather forge apron, hammer, auburn hair
			patch(-6, -27 + bob, 12, 17, "161924")
			patch(-4, -12, 3, 10, "29211b")
			patch(1, -12, 3, 10, "29211b")
			patch(-5, -26 + bob, 10, 15, "c4b195")
			patch(-4, -24 + bob, 8, 14, "5c3a21")
			patch(-2, -20 + bob, 4, 2, "363d47")
			# Blacksmith iron hammer
			patch(5, -21 + bob, 2, 7, "6e472b")
			patch(4, -23 + bob, 5, 3, "8a94a3")
			# Head & braided auburn hair
			patch(-4 + side, -37 + bob, 8, 9, "e0a783")
			patch(-5 + side, -39 + bob, 10, 4, "8f3c26")
			patch(-5 + side, -35 + bob, 2, 5, "752d1b")
			patch(-2 + side, -34 + bob, 1, 1, "242b38")
			patch(1 + side, -34 + bob, 1, 1, "242b38")
		"lyra":
			# Lyra: traveling historian in teal-and-ochre coat, weathered cloak, headband, brass astrolabe & field journal
			patch(-5, -27 + bob, 10, 17, "161924")
			patch(-4, -12, 3, 10, "3d281a")
			patch(1, -12, 3, 10, "3d281a")
			patch(-5, -26 + bob, 10, 16, "2d5e58")
			patch(-3, -25 + bob, 6, 15, "438c7f")
			patch(-5, -16 + bob, 10, 2, "c9974c")
			# Brass scroll satchel & astrolabe charm on right hip
			patch(4, -22 + bob, 3, 7, "6e472b")
			patch(4, -24 + bob, 3, 2, "e2d0a3")
			patch(5, -17 + bob, 2, 2, "e6b85c")
			# Open field journal in left hand
			patch(-7, -18 + bob, 4, 4, "e8dcc0")
			patch(-6, -17 + bob, 2, 2, "5c4632")
			# Head, warm copper hair & teal explorer headband
			patch(-4 + side, -37 + bob, 8, 9, "e8b590")
			patch(-5 + side, -39 + bob, 10, 4, "8a472a")
			patch(-5 + side, -36 + bob, 10, 2, "438c7f")
			patch(-5 + side, -34 + bob, 2, 6, "753920")
			patch(3 + side, -34 + bob, 2, 5, "753920")
			patch(-2 + side, -33 + bob, 1, 1, "242b38")
			patch(1 + side, -33 + bob, 1, 1, "242b38")
		"warden":
			# Last Bell Warden: ancient keep guardian in slate plate, indigo-violet mantle, bell sigil, ward lantern staff
			patch(-6, -28 + bob, 12, 18, "14141f")
			patch(-4, -12, 3, 10, "262a36")
			patch(1, -12, 3, 10, "262a36")
			patch(-6, -27 + bob, 12, 17, "383254")
			patch(-5, -26 + bob, 10, 14, "4c5466")
			# Silver pauldrons & tarnished bronze Bell crest on breastplate
			patch(-6, -26 + bob, 3, 4, "8f9aa8")
			patch(3, -26 + bob, 3, 4, "8f9aa8")
			patch(-2, -23 + bob, 4, 4, "d9a94e")
			patch(-1, -22 + bob, 2, 2, "6c5280")
			# Hooded helm & silver beard
			patch(-5 + side, -40 + bob, 10, 12, "2a2540")
			patch(-4 + side, -37 + bob, 8, 9, "c9b39d")
			patch(-3 + side, -32 + bob, 6, 4, "aeb8c7")
			patch(-2 + side, -34 + bob, 1, 1, "98f0ff")
			patch(1 + side, -34 + bob, 1, 1, "98f0ff")
			# Tall bronze ward-staff & sapphire lantern
			patch(6, -34 + bob, 2, 24, "6e5736")
			patch(5, -38 + bob, 4, 4, "7ce8ff")
			patch(6, -37 + bob, 2, 2, "ffffff")
		_:
			# Sister Elara: cowled chronicler in sapphire robes, silver stole, open parchment tome
			patch(-5, -27 + bob, 10, 17, "161924")
			patch(-4, -26 + bob, 8, 22, "2f4566")
			patch(-2, -25 + bob, 4, 18, "c4cbd6")
			patch(-5 + side, -39 + bob, 10, 12, "243652")
			patch(-4 + side, -36 + bob, 8, 8, "e3b18d")
			patch(-2 + side, -33 + bob, 1, 1, "242b38")
			patch(1 + side, -33 + bob, 1, 1, "242b38")
			# Open parchment chronicle tome
			patch(-6, -18 + bob, 5, 4, "d9c498")
			patch(-5, -17 + bob, 3, 2, "5c4632")

func patch(x: int, y: int, w: int, h: int, color: String) -> void:
	draw_rect(Rect2(x, y, w, h), Color(color))
