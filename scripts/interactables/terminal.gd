extends StaticBody2D
signal message_requested(text: String)
signal proximity_changed(nearby: bool)
@export_multiline var message: String = "The bell has rung thirteen times. Something beneath the village is awakening."
@export var interaction_priority: int = 10
@export var prompt_text: String = "[E] INSPECT RUNE PEDESTAL"
@export var notice_board: bool = false
var selected: bool = false
var nearby_player: CharacterBody2D
var dialogue_open: bool = false

func _ready() -> void:
	add_to_group("interactables")
	$Indicator.text = prompt_text
	$Indicator.offset_left = -84
	$Indicator.offset_right = 84
	$Indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Range.body_entered.connect(_on_entered)
	$Range.body_exited.connect(_on_exited)

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
		message_requested.emit(message)
		get_viewport().set_input_as_handled()

func _draw() -> void:
	if notice_board:
		# Medieval timber village signpost / decree board
		draw_rect(Rect2(-10,-30,3,30),Color("4a3220"))
		draw_rect(Rect2(8,-30,3,30),Color("4a3220"))
		draw_rect(Rect2(-15,-37,30,23),Color("382516"))
		draw_rect(Rect2(-13,-35,26,18),Color("d6c49e"))
		for y in [-31,-27,-23]:
			draw_line(Vector2(-10,y),Vector2(9,y),Color("5c4632"),1)
		draw_rect(Rect2(-1,-34,2,2),Color("9e3d2b")) # Wax seal
		return
	# Ancient Stone Rune Pedestal with tiered base, weathered obelisk, and glowing golden runes
	draw_colored_polygon(PackedVector2Array([Vector2(-14,-3),Vector2(0,-10),Vector2(14,-3),Vector2(0,4)]), Color("363330"))
	draw_colored_polygon(PackedVector2Array([Vector2(-11,-5),Vector2(0,-11),Vector2(11,-5),Vector2(0,1)]), Color("4a4642"))
	# Stone pillar body & shaded right bevel
	draw_rect(Rect2(-7,-29,13,26),Color("6e6862"))
	draw_rect(Rect2(4,-29,4,26),Color("45413d"))
	# Angled runic altar slab cap
	draw_colored_polygon(PackedVector2Array([Vector2(-9,-29),Vector2(0,-34),Vector2(9,-29),Vector2(0,-24)]), Color("857e76"))
	# Etched golden-amber glowing rune sigil on stone face
	draw_rect(Rect2(-5,-25,9,13),Color("383430"))
	draw_line(Vector2(-1,-23),Vector2(-1,-14),Color("ffca57"),1)
	draw_line(Vector2(-3,-21),Vector2(1,-21),Color("ffca57"),1)
	draw_line(Vector2(-3,-17),Vector2(1,-19),Color("ffe89e"),1)
	draw_rect(Rect2(-2,-24,2,2),Color("ffe89e"))
	# Subtle warm gold light dot at altar crown
	draw_rect(Rect2(-1,-30,2,2),Color("ffca57"))
