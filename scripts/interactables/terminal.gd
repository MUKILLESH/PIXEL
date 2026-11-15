extends StaticBody2D
signal message_requested(text: String)
signal proximity_changed(nearby: bool)
@export_multiline var message: String = "11:47 PM — You have 13 minutes."
@export var interaction_priority: int = 10
@export var prompt_text: String = "[E] READ TERMINAL"
@export var notice_board: bool = false
var selected: bool = false
var nearby_player: CharacterBody2D
var dialogue_open: bool = false

func _ready() -> void:
	add_to_group("interactables")
	$Indicator.text = prompt_text
	$Indicator.offset_left = -48
	$Indicator.offset_right = 48
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
		draw_rect(Rect2(-10,-30,3,30),Color("526164"))
		draw_rect(Rect2(8,-30,3,30),Color("526164"))
		draw_rect(Rect2(-15,-37,30,23),Color("293f4a"))
		draw_rect(Rect2(-13,-35,26,18),Color("b6aa88"))
		for x in [-10,0,7]:
			draw_rect(Rect2(x,-32,5,11),Color("ded7b8"))
		return
	draw_colored_polygon(PackedVector2Array([Vector2(-12,-3),Vector2(0,-9),Vector2(12,-3),Vector2(0,3)]), Color("1b3041"))
	draw_rect(Rect2(-8,-27,16,25),Color("345264"))
	draw_rect(Rect2(6,-27,3,25),Color("203446"))
	draw_rect(Rect2(-6,-24,11,12),Color("75e9cf"))
	draw_rect(Rect2(-4,-21,7,2),Color("235365"))
	draw_rect(Rect2(-4,-17,4,1),Color("235365"))
	draw_rect(Rect2(-4,-8,8,2),Color("b4c3bf"))
