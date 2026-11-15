extends CanvasLayer
var player: CharacterBody2D
var terminal: StaticBody2D
var nearby: bool = false
var selected: StaticBody2D
@onready var panel: Panel = $Message
@onready var message_label: Label = $Message/Text

func _ready() -> void:
	# Compact fixed-viewport HUD. The only interaction prompt lives in the world.
	$TitlePlate.hide()
	$ClockPlate.hide()
	$Title.add_theme_font_size_override("font_size",8)
	$Title.position = Vector2(12,10)
	$Subtitle.position = Vector2(12,23)
	$Clock.add_theme_font_size_override("font_size",8)
	$Clock.offset_left = -66
	$Clock.offset_top = 10
	$Footer.offset_left = 8
	$Footer.anchor_right = 0
	$Footer.offset_right = 320
	$Footer.offset_top = -26
	$Footer.offset_bottom = -7
	$Objective.offset_left = 16
	$Objective.offset_top = -21
	$Controls.hide()
	$Message.offset_top = -121
	$Message.offset_bottom = -36
	for label: Label in [$Title,$Subtitle,$Clock]:
		label.add_theme_color_override("font_shadow_color",Color("152734"))
		label.add_theme_constant_override("shadow_offset_x",1)
		label.add_theme_constant_override("shadow_offset_y",1)

func _process(_delta: float) -> void:
	var best: StaticBody2D = null
	var best_distance: float = INF
	var objects := get_tree().get_nodes_in_group("interactables")
	for object: Node in objects:
		if not get_parent().is_ancestor_of(object):
			continue
		var callback: Callable = show_message.bind(object)
		if not object.message_requested.is_connected(callback):
			object.message_requested.connect(callback)
		if panel.visible or object.nearby_player == null:
			continue
		var distance: float = object.global_position.distance_squared_to(object.nearby_player.global_position)
		if is_better_candidate(object,best,distance,best_distance):
			best = object
			best_distance = distance
	selected = best
	for object: Node in objects:
		if get_parent().is_ancestor_of(object):
			object.set_selected(object == best)
	$Prompt.hide()

func is_better_candidate(candidate: StaticBody2D, current: StaticBody2D, distance: float, current_distance: float) -> bool:
	if current == null:
		return true
	if candidate.interaction_priority != current.interaction_priority:
		return candidate.interaction_priority > current.interaction_priority
	if not is_equal_approx(distance,current_distance):
		return distance < current_distance
	return str(candidate.get_path()) < str(current.get_path())

func show_message(text: String, source: StaticBody2D = null) -> void:
	if panel.visible:
		return
	message_label.text = text
	message_label.add_theme_font_size_override("font_size",8 if text.length() > 48 else 16)
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if source != null:
		terminal = source
	$Message/Source.text = "CAMPUS NOTICE" if terminal.notice_board else "INCOMING / UNKNOWN SIGNAL"
	panel.show()
	player.set("movement_locked",true)
	terminal.set_dialogue_open(true)
	if text.begins_with("11:47"):
		$Objective.text = "SIGNAL RECEIVED / 13 MINUTES REMAIN"
	$Prompt.hide()

func set_nearby(value: bool) -> void:
	nearby = value
	$Prompt.hide()

func _input(event: InputEvent) -> void:
	if panel.visible and not event.is_echo() and (event.is_action_pressed("interact") or event.is_action_pressed("dismiss")):
		panel.hide()
		player.set("movement_locked",false)
		terminal.set_dialogue_open(false)
		$Prompt.hide()
		get_viewport().set_input_as_handled()
