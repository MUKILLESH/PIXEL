extends CanvasLayer
## Persistent Bellhaven HUD, multi-line dialogue box, Rune Puzzle host, and Prologue Complete overlay.

var player: CharacterBody2D
var terminal: StaticBody2D
var quest_manager: Node
var nearby: bool = false
var selected: StaticBody2D

var dialogue_lines: Array[String] = []
var dialogue_index: int = 0
var on_dialogue_complete: Callable = Callable()

@onready var panel: Panel = $Message
@onready var message_label: Label = $Message/Text
@onready var dismiss_label: Label = $Message/Dismiss
@onready var rune_puzzle: Panel = $RunePuzzle
@onready var prologue_banner: Panel = $PrologueComplete

func _ready() -> void:
	# Compact fixed-viewport HUD. The active interaction prompt lives in the world.
	$TitlePlate.hide()
	$ClockPlate.hide()
	$Title.add_theme_font_size_override("font_size", 8)
	$Title.position = Vector2(12, 10)
	$Subtitle.position = Vector2(12, 23)
	$Clock.add_theme_font_size_override("font_size", 8)
	$Clock.offset_left = -96
	$Clock.offset_top = 10
	$Clock.offset_right = -12
	$Footer.offset_left = 8
	$Footer.anchor_right = 0
	$Footer.offset_right = 344
	$Footer.offset_top = -26
	$Footer.offset_bottom = -7
	$Objective.offset_left = 16
	$Objective.offset_top = -21
	$Controls.hide()
	$Message.offset_top = -121
	$Message.offset_bottom = -36
	for label: Label in [$Title, $Subtitle, $Clock]:
		label.add_theme_color_override("font_shadow_color", Color("1a1410"))
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)
	if rune_puzzle != null:
		rune_puzzle.puzzle_solved_signal.connect(_on_rune_puzzle_solved)
		rune_puzzle.puzzle_closed_signal.connect(_on_rune_puzzle_closed)

func bind_quest_manager(qm: Node) -> void:
	quest_manager = qm
	if quest_manager != null and not quest_manager.objective_changed.is_connected(_on_objective_changed):
		quest_manager.objective_changed.connect(_on_objective_changed)
		$Objective.text = quest_manager.get_current_objective_text()

func _on_objective_changed(_objective_id: String, objective_text: String) -> void:
	$Objective.text = objective_text

func _is_modal_open() -> bool:
	return panel.visible or (rune_puzzle != null and rune_puzzle.visible) or (prologue_banner != null and prologue_banner.visible)

func _process(_delta: float) -> void:
	_update_selection()

func _on_interactable_proximity_changed(_nearby: bool) -> void:
	_update_selection()

func _update_selection() -> void:
	if not is_inside_tree():
		return
	var parent := get_parent()
	if parent == null:
		return
	var best: StaticBody2D = null
	var best_distance: float = INF
	var objects := get_tree().get_nodes_in_group("interactables")
	var modal_open: bool = _is_modal_open()
	for object: Node in objects:
		if not parent.is_ancestor_of(object):
			continue
		var callback: Callable = show_message.bind(object)
		if not object.message_requested.is_connected(callback):
			object.message_requested.connect(callback)
		if not object.proximity_changed.is_connected(_on_interactable_proximity_changed):
			object.proximity_changed.connect(_on_interactable_proximity_changed)
		if modal_open or object.nearby_player == null:
			continue
		var distance: float = object.global_position.distance_squared_to(object.nearby_player.global_position)
		if is_better_candidate(object, best, distance, best_distance):
			best = object
			best_distance = distance
	selected = best
	for object: Node in objects:
		if parent.is_ancestor_of(object):
			object.set_selected(object == best)
	$Prompt.hide()

func is_better_candidate(candidate: StaticBody2D, current: StaticBody2D, distance: float, current_distance: float) -> bool:
	if current == null:
		return true
	if candidate.interaction_priority != current.interaction_priority:
		return candidate.interaction_priority > current.interaction_priority
	if not is_equal_approx(distance, current_distance):
		return distance < current_distance
	return str(candidate.get_path()) < str(current.get_path())

func show_message(text: String, source: StaticBody2D = null) -> void:
	if _is_modal_open():
		return
	if source != null and quest_manager != null:
		_handle_story_interaction(text, source)
		return
	var title := "VILLAGE SIGNPOST" if (source != null and source.notice_board) else "STONE RUNE PEDESTAL"
	show_dialogue(title, [text], source)

func _handle_story_interaction(text: String, source: StaticBody2D) -> void:
	if source.notice_board:
		show_dialogue("VILLAGE SIGNPOST", [text], source)
		return
	if source.has_method("get_npc_id"):
		var npc_id: String = source.get_npc_id()
		var lines: Array[String] = quest_manager.get_npc_dialogue(npc_id)
		show_dialogue(source.speaker_name, lines, source, func(): quest_manager.record_npc_talked(npc_id))
		return
	var role: int = int(source.get("role")) if "role" in source else 0
	if role == 2:
		if not quest_manager.can_open_mothers_letter():
			show_dialogue("SEALED SURVEY CHEST", ["Master Caelen's locked survey chest rests beside the cottage door. Speak with the three villagers first."], source)
		else:
			var lines: Array[String] = quest_manager.get_story_lines("mothers_letter")
			show_dialogue("MOTHER'S LETTER", lines, source, func(): quest_manager.complete_objective("find_mothers_letter"))
		return
	if role == 3:
		var stage: String = quest_manager.get_current_objective_id()
		if stage in ["investigate_bell", "speak_npcs", "find_mothers_letter", "solve_rune_puzzle"]:
			show_dialogue("BRIARWOOD WAYSTONE", ["Silver-barked briars and a dormant ward-seal block the southwest road into Briarwood Forest."], source)
		elif stage == "discover_briarwood_path":
			quest_manager.complete_objective("discover_briarwood_path")
			var lines: Array[String] = quest_manager.get_story_lines("briarwood_ending")
			show_dialogue("BRIARWOOD WAYSTONE", lines, source, func(): _finish_prologue())
		elif stage == "trigger_prologue_completion":
			var lines: Array[String] = quest_manager.get_story_lines("briarwood_ending")
			show_dialogue("BRIARWOOD WAYSTONE", lines, source, func(): _finish_prologue())
		else:
			show_dialogue("BRIARWOOD WAYSTONE", ["The road to Briarwood Forest stands open, awaiting Chapter 1: Whispers of Briarwood."], source)
		return
	# Default: Stone Rune Pedestal (role == 0)
	var obj_id: String = quest_manager.get_current_objective_id()
	if obj_id == "investigate_bell":
		show_dialogue("STONE RUNE PEDESTAL", [text], source, func(): quest_manager.complete_objective("investigate_bell"))
	elif obj_id in ["speak_npcs", "find_mothers_letter"]:
		show_dialogue("STONE RUNE PEDESTAL", ["Three concentric rune discs sit locked inside the stone altar. Learn their cipher from the villagers and Mother's notes first."], source)
	elif quest_manager.can_open_rune_puzzle():
		open_rune_puzzle(source)
	else:
		show_dialogue("STONE RUNE PEDESTAL", ["The aligned rings hum steadily in golden-cyan harmony, guiding Aren toward the Briarwood Waystone."], source)

func show_dialogue(speaker: String, lines: Array[String], source: StaticBody2D = null, complete_cb: Callable = Callable()) -> void:
	if lines.is_empty():
		return
	if source != null:
		terminal = source
	dialogue_lines = lines.duplicate()
	dialogue_index = 0
	on_dialogue_complete = complete_cb
	$Message/Source.text = speaker
	_render_dialogue_page()
	panel.show()
	if player != null:
		player.set("movement_locked", true)
	if terminal != null:
		terminal.set_dialogue_open(true)
	$Prompt.hide()
	_update_selection()

func _render_dialogue_page() -> void:
	var line: String = dialogue_lines[dialogue_index]
	message_label.text = line
	message_label.add_theme_font_size_override("font_size", 8 if line.length() > 48 else 16)
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if dialogue_index + 1 < dialogue_lines.size():
		dismiss_label.text = "[E] CONTINUE (%d/%d)   [ESC] CLOSE" % [dialogue_index + 1, dialogue_lines.size()]
	elif dialogue_lines.size() > 1:
		dismiss_label.text = "[E] / [ESC] FINISH (%d/%d)" % [dialogue_index + 1, dialogue_lines.size()]
	else:
		dismiss_label.text = "[E] / [ESC] CLOSE"

func _close_dialogue(trigger_completion: bool) -> void:
	var cb: Callable = on_dialogue_complete
	dialogue_lines.clear()
	dialogue_index = 0
	on_dialogue_complete = Callable()
	panel.hide()
	if player != null:
		player.set("movement_locked", false)
	if terminal != null:
		terminal.set_dialogue_open(false)
	$Prompt.hide()
	_update_selection()
	if trigger_completion and cb.is_valid():
		cb.call()

func open_rune_puzzle(source: StaticBody2D) -> void:
	if rune_puzzle == null or rune_puzzle.solved:
		return
	terminal = source
	if player != null:
		player.set("movement_locked", true)
	if terminal != null:
		terminal.set_dialogue_open(true)
	$Prompt.hide()
	rune_puzzle.open_puzzle()
	_update_selection()

func _on_rune_puzzle_solved() -> void:
	if quest_manager != null:
		quest_manager.complete_objective("solve_rune_puzzle")
		var lines: Array[String] = quest_manager.get_story_lines("beacon_revelation")
		show_dialogue("STONE RUNE PEDESTAL", lines, terminal)
	else:
		_on_rune_puzzle_closed()

func _on_rune_puzzle_closed() -> void:
	if player != null:
		player.set("movement_locked", false)
	if terminal != null:
		terminal.set_dialogue_open(false)
	$Prompt.hide()
	_update_selection()

func _finish_prologue() -> void:
	if quest_manager != null:
		quest_manager.complete_objective("trigger_prologue_completion")
	if prologue_banner != null:
		prologue_banner.show()
	if player != null:
		player.set("movement_locked", true)
	if terminal != null:
		terminal.set_dialogue_open(true)
	$Prompt.hide()
	_update_selection()

func set_nearby(value: bool) -> void:
	nearby = value
	$Prompt.hide()

func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	var is_confirm: bool = event.is_action_pressed("interact") or ((event is InputEventKey or event is InputEventAction) and event.is_action_pressed("ui_accept"))
	var is_cancel: bool = event.is_action_pressed("dismiss") or ((event is InputEventKey or event is InputEventAction) and event.is_action_pressed("ui_cancel"))
	if prologue_banner != null and prologue_banner.visible and (is_confirm or is_cancel):
		prologue_banner.hide()
		if player != null:
			player.set("movement_locked", false)
		if terminal != null:
			terminal.set_dialogue_open(false)
		$Prompt.hide()
		_update_selection()
		get_viewport().set_input_as_handled()
		return
	if panel.visible:
		if is_confirm:
			if dialogue_index + 1 < dialogue_lines.size():
				dialogue_index += 1
				_render_dialogue_page()
			else:
				_close_dialogue(true)
			get_viewport().set_input_as_handled()
		elif is_cancel:
			var on_last_page: bool = (dialogue_index >= dialogue_lines.size() - 1)
			_close_dialogue(on_last_page)
			get_viewport().set_input_as_handled()
