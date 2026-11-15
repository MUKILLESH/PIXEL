extends StaticBody2D
signal message_requested(text: String)
signal proximity_changed(nearby: bool)

@export_multiline var message: String = "The bell has rung thirteen times. Something beneath the village is awakening."
@export var interaction_priority: int = 10
@export var prompt_text: String = "[E] INSPECT RUNE PEDESTAL"
@export var notice_board: bool = false
@export_enum("RunePedestal", "NoticeBoard", "MothersLetter", "BriarwoodGate") var role: int = 0

var puzzle_solved: bool = false
var gate_unlocked: bool = false
var letter_highlighted: bool = false
var selected: bool = false
var nearby_player: CharacterBody2D
var dialogue_open: bool = false

func _ready() -> void:
	add_to_group("interactables")
	if notice_board and role == 0:
		role = 1
	$Indicator.text = prompt_text
	$Indicator.offset_left = -96
	$Indicator.offset_right = 96
	$Indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Range.body_entered.connect(_on_entered)
	$Range.body_exited.connect(_on_exited)

func refresh_prompt(new_text: String) -> void:
	prompt_text = new_text
	if has_node("Indicator"):
		$Indicator.text = new_text

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
	if notice_board or role == 1:
		# Medieval timber village signpost / decree board
		draw_rect(Rect2(-10, -30, 3, 30), Color("4a3220"))
		draw_rect(Rect2(8, -30, 3, 30), Color("4a3220"))
		draw_rect(Rect2(-15, -37, 30, 23), Color("382516"))
		draw_rect(Rect2(-13, -35, 26, 18), Color("d6c49e"))
		for y in [-31, -27, -23]:
			draw_line(Vector2(-10, y), Vector2(9, y), Color("5c4632"), 1)
		draw_rect(Rect2(-1, -34, 2, 2), Color("9e3d2b"))
		return

	if role == 2:
		# Elena's sealed cartographer survey chest beside the cottage door
		draw_colored_polygon(PackedVector2Array([Vector2(-11, -2), Vector2(0, -8), Vector2(11, -2), Vector2(0, 4)]), Color(0.02, 0.03, 0.05, 0.35))
		draw_rect(Rect2(-9, -11, 18, 11), Color("4f311c"))
		draw_rect(Rect2(-8, -10, 16, 4), Color("6e4429"))
		draw_rect(Rect2(-9, -6, 18, 2), Color("2d3138"))
		# Brass lockplate
		draw_rect(Rect2(-2, -8, 4, 4), Color("e6b85c"))
		# Rolled map scroll & red wax seal resting atop chest
		draw_rect(Rect2(-5, -14, 10, 3), Color("d9c498"))
		draw_rect(Rect2(-1, -13, 3, 2), Color("b83b2a"))
		if letter_highlighted:
			draw_rect(Rect2(6, -15, 2, 2), Color("ffe89e"))
		return

	if role == 3:
		# Ancient Briarwood Boundary Waystone Gate
		draw_colored_polygon(PackedVector2Array([Vector2(-15, -2), Vector2(0, -10), Vector2(15, -2), Vector2(0, 6)]), Color(0.02, 0.03, 0.05, 0.35))
		if gate_unlocked:
			draw_colored_polygon(PackedVector2Array([Vector2(-18, 0), Vector2(0, -10), Vector2(18, 0), Vector2(0, 10)]), Color(0.32, 0.82, 0.88, 0.25))
		draw_rect(Rect2(-8, -28, 16, 28), Color("5c5752"))
		draw_rect(Rect2(4, -28, 4, 28), Color("403c38"))
		draw_colored_polygon(PackedVector2Array([Vector2(-8, -28), Vector2(0, -35), Vector2(8, -28)]), Color("78716a"))
		# Moss & carved compass rune
		draw_rect(Rect2(-7, -25, 4, 5), Color("375740"))
		var rune_color := Color("8be6f0") if gate_unlocked else Color("787066")
		draw_line(Vector2(0, -23), Vector2(0, -13), rune_color, 1)
		draw_line(Vector2(-4, -18), Vector2(4, -18), rune_color, 1)
		draw_rect(Rect2(-1, -19, 3, 3), Color("ffe28a") if gate_unlocked else Color("635d56"))
		# Silver-barked briar vines before awakening
		if not gate_unlocked:
			draw_line(Vector2(-9, -6), Vector2(8, -16), Color("3d4a3d"), 2)
			draw_line(Vector2(-7, -20), Vector2(9, -10), Color("586958"), 2)
		return

	# Default role == 0: Ancient Stone Rune Pedestal
	if puzzle_solved:
		draw_colored_polygon(PackedVector2Array([Vector2(-20, -3), Vector2(0, -13), Vector2(20, -3), Vector2(0, 7)]), Color(0.35, 0.82, 0.88, 0.24))
	draw_colored_polygon(PackedVector2Array([Vector2(-14, -3), Vector2(0, -10), Vector2(14, -3), Vector2(0, 4)]), Color("363330"))
	draw_colored_polygon(PackedVector2Array([Vector2(-11, -5), Vector2(0, -11), Vector2(11, -5), Vector2(0, 1)]), Color("4a4642"))
	draw_rect(Rect2(-7, -29, 13, 26), Color("6e6862"))
	draw_rect(Rect2(4, -29, 4, 26), Color("45413d"))
	draw_colored_polygon(PackedVector2Array([Vector2(-9, -29), Vector2(0, -34), Vector2(9, -29), Vector2(0, -24)]), Color("92ebfa") if puzzle_solved else Color("857e76"))
	draw_rect(Rect2(-5, -25, 9, 13), Color("383430"))
	var glyph_main := Color("8be6f0") if puzzle_solved else Color("ffca57")
	var glyph_core := Color("ffffff") if puzzle_solved else Color("ffe89e")
	draw_line(Vector2(-1, -23), Vector2(-1, -14), glyph_main, 1)
	draw_line(Vector2(-3, -21), Vector2(1, -21), glyph_main, 1)
	draw_line(Vector2(-3, -17), Vector2(1, -19), glyph_core, 1)
	draw_rect(Rect2(-2, -24, 2, 2), glyph_core)
	draw_rect(Rect2(-1, -30, 2, 2), glyph_core)
