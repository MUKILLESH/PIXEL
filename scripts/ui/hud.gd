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

const BridgeRepairScript = preload("res://scripts/ui/bridge_repair.gd")
const MirrorPuzzleScript = preload("res://scripts/ui/mirror_puzzle.gd")
const WatermillRepairScript = preload("res://scripts/ui/watermill_repair.gd")
const SluicePuzzleScript = preload("res://scripts/ui/sluice_puzzle.gd")
const LedgerPuzzleScript = preload("res://scripts/ui/ledger_puzzle.gd")
const CrestPuzzleScript = preload("res://scripts/ui/crest_puzzle.gd")
const InventoryPanelScript = preload("res://scripts/ui/inventory_panel.gd")
const TitleMenuScript = preload("res://scripts/ui/title_menu.gd")
const QuestManagerScript = preload("res://scripts/systems/quest_manager.gd")

@onready var panel: Panel = $Message
@onready var message_label: Label = $Message/Text
@onready var dismiss_label: Label = $Message/Dismiss
@onready var rune_puzzle: Panel = $RunePuzzle
@onready var prologue_banner: Panel = $PrologueComplete
var bridge_repair: Panel
var mirror_puzzle: Panel
var watermill_repair: Panel
var sluice_puzzle: Panel
var ledger_puzzle: Panel
var crest_puzzle: Panel
var stealth_status_label: Label
var inventory_panel: Panel
var title_menu: Panel
var save_path: String = "user://ashvale_save.json"

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
	bridge_repair = BridgeRepairScript.new()
	bridge_repair.name = "BridgeRepair"
	add_child(bridge_repair)
	bridge_repair.bridge_repaired_signal.connect(_on_bridge_repaired)
	bridge_repair.bridge_closed_signal.connect(_on_modal_closed)
	mirror_puzzle = MirrorPuzzleScript.new()
	mirror_puzzle.name = "MirrorPuzzle"
	add_child(mirror_puzzle)
	mirror_puzzle.mirror_solved_signal.connect(_on_mirror_solved)
	mirror_puzzle.mirror_closed_signal.connect(_on_modal_closed)
	watermill_repair = WatermillRepairScript.new()
	watermill_repair.name = "WatermillRepair"
	add_child(watermill_repair)
	watermill_repair.watermill_repaired_signal.connect(_on_watermill_repaired)
	watermill_repair.watermill_closed_signal.connect(_on_modal_closed)
	sluice_puzzle = SluicePuzzleScript.new()
	sluice_puzzle.name = "SluicePuzzle"
	add_child(sluice_puzzle)
	sluice_puzzle.sluice_solved_signal.connect(_on_sluice_solved)
	sluice_puzzle.sluice_closed_signal.connect(_on_modal_closed)
	sluice_puzzle.sluice_states_changed.connect(_on_sluice_states_changed)
	ledger_puzzle = LedgerPuzzleScript.new()
	ledger_puzzle.name = "LedgerPuzzle"
	add_child(ledger_puzzle)
	ledger_puzzle.ledger_solved_signal.connect(_on_ledger_solved)
	ledger_puzzle.ledger_closed_signal.connect(_on_modal_closed)
	crest_puzzle = CrestPuzzleScript.new()
	crest_puzzle.name = "CrestPuzzle"
	add_child(crest_puzzle)
	crest_puzzle.crest_solved_signal.connect(_on_crest_solved)
	crest_puzzle.crest_closed_signal.connect(_on_modal_closed)
	stealth_status_label = Label.new()
	stealth_status_label.name = "StealthStatus"
	stealth_status_label.visible = false
	stealth_status_label.position = Vector2(12, 36)
	stealth_status_label.add_theme_font_size_override("font_size", 8)
	stealth_status_label.add_theme_color_override("font_color", Color("ffd578"))
	stealth_status_label.add_theme_color_override("font_shadow_color", Color("120e0b"))
	stealth_status_label.add_theme_constant_override("shadow_offset_x", 1)
	stealth_status_label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(stealth_status_label)
	inventory_panel = InventoryPanelScript.new()
	inventory_panel.name = "InventoryPanel"
	add_child(inventory_panel)
	inventory_panel.inventory_closed_signal.connect(_on_modal_closed)
	title_menu = TitleMenuScript.new()
	title_menu.name = "TitleMenu"
	add_child(title_menu)
	title_menu.new_game_requested.connect(start_new_game)
	title_menu.continue_requested.connect(continue_game)
	title_menu.save_requested.connect(manual_save)
	title_menu.inventory_requested.connect(_on_menu_inventory_requested)
	title_menu.menu_closed_signal.connect(_on_modal_closed)

func bind_quest_manager(qm: Node) -> void:
	quest_manager = qm
	if quest_manager != null and not quest_manager.objective_changed.is_connected(_on_objective_changed):
		quest_manager.objective_changed.connect(_on_objective_changed)
		$Objective.text = quest_manager.get_current_objective_text()

func _on_objective_changed(_objective_id: String, objective_text: String) -> void:
	$Objective.text = objective_text

func set_stealth_status(msg: String) -> void:
	if stealth_status_label == null:
		return
	if msg == "":
		stealth_status_label.visible = false
		stealth_status_label.text = ""
	else:
		stealth_status_label.text = msg
		stealth_status_label.visible = not _is_modal_open()

func _is_modal_open() -> bool:
	return panel.visible or (rune_puzzle != null and rune_puzzle.visible) or (bridge_repair != null and bridge_repair.visible) or (mirror_puzzle != null and mirror_puzzle.visible) or (watermill_repair != null and watermill_repair.visible) or (sluice_puzzle != null and sluice_puzzle.visible) or (ledger_puzzle != null and ledger_puzzle.visible) or (crest_puzzle != null and crest_puzzle.visible) or (inventory_panel != null and inventory_panel.visible) or (title_menu != null and title_menu.visible) or (prologue_banner != null and prologue_banner.visible)

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
		var cb: Callable = Callable()
		if npc_id == "lyra":
			var stage_id: String = quest_manager.get_current_objective_id()
			if quest_manager.quest_id == "chapter3_keepers_lie":
				cb = Callable()
			elif quest_manager.quest_id == "chapter2_drowned_village":
				if stage_id == "speak_lyra_arrival":
					cb = func(): quest_manager.complete_objective("speak_lyra_arrival")
				elif stage_id == "complete_chapter2":
					cb = func(): _finish_chapter2()
			else:
				if stage_id == "meet_lyra":
					cb = func(): quest_manager.complete_objective("meet_lyra")
				elif stage_id == "complete_chapter1":
					cb = func(): _finish_chapter1()
		elif npc_id == "warden":
			var w_stage: String = quest_manager.get_current_objective_id()
			if w_stage == "reach_wardens_chamber":
				quest_manager.complete_objective("reach_wardens_chamber")
				w_stage = quest_manager.get_current_objective_id()
			if w_stage == "confront_last_warden":
				lines = quest_manager.get_story_lines("warden_confrontation")
				cb = func(): quest_manager.complete_objective("confront_last_warden")
		else:
			cb = func(): quest_manager.record_npc_talked(npc_id)
		show_dialogue(source.speaker_name, lines, source, cb)
		return
	if source.has_method("get_ironwatch_kind"):
		_handle_ironwatch_interaction(source)
		return
	if source.has_method("get_briarwood_kind"):
		_handle_briarwood_interaction(source)
		return
	if source.has_method("get_floodmill_kind"):
		_handle_floodmill_interaction(source)
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
		elif source.get("ready_to_travel") == true and get_parent().has_method("travel_to_briarwood"):
			show_dialogue("BRIARWOOD WAYSTONE", ["Stepping through the awakened gate into Briarwood Forest..."], source, func(): get_parent().travel_to_briarwood())
		else:
			show_dialogue("BRIARWOOD WAYSTONE", ["The road to Briarwood Forest stands open, awaiting Chapter 1: Whispers of Briarwood."], source, func():
				source.set("ready_to_travel", true)
				if source.has_method("refresh_prompt"):
					source.refresh_prompt("[E] ENTER BRIARWOOD FOREST")
			)
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

func _handle_briarwood_interaction(source: StaticBody2D) -> void:
	var kind: String = source.get_briarwood_kind()
	var obj_id: String = quest_manager.get_current_objective_id()
	var title: String = source.speaker_name if source.speaker_name != "" else "BRIARWOOD"
	match kind:
		"waystone_entrance":
			if obj_id == "enter_briarwood":
				show_dialogue(title, quest_manager.get_story_lines("forest_entry"), source, func(): quest_manager.complete_objective("enter_briarwood"))
			else:
				show_dialogue(title, ["Bellhaven lies south behind the mist. The First Ancient Beacon awaits north of the stream."], source)
		"direction_sign":
			show_dialogue(title, [source.message], source)
		"worksite_ledger":
			show_dialogue(title, quest_manager.get_story_lines("worksite_clue"), source)
		"repair_material":
			if source.get("collected") == true:
				show_dialogue(title, ["You already gathered these bridge repair supplies."], source)
			elif not quest_manager.can_collect_materials():
				show_dialogue(title, ["Old carpenter's supplies rest here. Meet Lyra and inspect the broken bridge first so you know what to haul."], source)
			else:
				var item_id: String = String(source.get("item_id"))
				show_dialogue(title, [source.message], source, func():
					if quest_manager.record_material_collected(item_id):
						source.set("collected", true)
						source.queue_redraw()
				)
		"broken_bridge":
			if obj_id in ["enter_briarwood", "meet_lyra"]:
				show_dialogue(title, ["The crossing over Briarwood stream has collapsed. Meet Lyra at the Forest Edge campfire first."], source)
			elif obj_id == "investigate_bridge":
				show_dialogue(title, quest_manager.get_story_lines("broken_bridge_inspect"), source, func(): quest_manager.complete_objective("investigate_bridge"))
			elif obj_id == "find_repair_materials":
				show_dialogue(title, ["The broken span needs two sturdy oak planks and a coil of hemp rope from the carpenter's worksite east of Whispering Fork."], source)
			elif quest_manager.can_open_bridge_repair():
				open_bridge_repair(source)
			else:
				show_dialogue(title, ["The rebuilt oak-and-rope bridge holds steady above the rushing turquoise current."], source)
		"inscription":
			var insc_id: String = String(source.get("item_id"))
			var lines: Array[String] = quest_manager.get_story_lines("inscription_" + insc_id)
			if obj_id in ["enter_briarwood", "meet_lyra", "investigate_bridge", "find_repair_materials", "repair_bridge"]:
				show_dialogue(title, ["Moss covers ancient carved letters from an erased village."], source)
			elif obj_id == "discover_inscriptions" and not quest_manager.inscriptions_read.has(insc_id):
				show_dialogue(title, lines, source, func():
					if quest_manager.record_inscription_read(insc_id):
						source.set("inspected", true)
						source.queue_redraw()
				)
			else:
				show_dialogue(title, lines, source)
		"mirror_pedestal":
			if obj_id == "discover_inscriptions":
				show_dialogue(title, ["Three ancient mirrors frame the shrine barrier, yet their solar angles are faded. Read the three forest inscriptions first."], source)
			elif quest_manager.can_open_mirror_puzzle():
				open_mirror_puzzle(source)
			elif quest_manager.mirror_puzzle_solved:
				show_dialogue(title, ["The aligned mirrors channel a golden-cyan beam cleanly into the shrine receptors."], source)
			else:
				show_dialogue(title, ["Ancient bronze mirrors stand silently beneath the canopy."], source)
		"first_beacon":
			if not quest_manager.mirror_puzzle_solved:
				show_dialogue(title, ["A luminous mirror-ward seals off the First Ancient Beacon. Align all three mirrors in Mirror Grove first."], source)
			elif obj_id == "activate_first_beacon":
				show_dialogue(title, quest_manager.get_story_lines("beacon_activation"), source, func(): quest_manager.complete_objective("activate_first_beacon"))
			elif obj_id == "experience_elena_recording":
				show_dialogue(title, quest_manager.get_story_lines("elena_recording"), source, func(): quest_manager.complete_objective("experience_elena_recording"))
			else:
				show_dialogue(title, ["The First Ancient Beacon hums brightly, holding Elena's compass bearing toward Floodmill Wetlands."], source)
		"hidden_relic":
			var disc_id: String = String(source.get("item_id"))
			show_dialogue(title, quest_manager.get_story_lines("ruined_camp_note"), source, func():
				quest_manager.record_optional_discovery(disc_id)
				source.set("collected", true)
				source.queue_redraw()
			)
		"floodmill_gate":
			if quest_manager.floodmill_unlocked:
				if source.get("ready_to_travel") == true and get_parent().has_method("travel_to_floodmill"):
					show_dialogue(title, ["Following Elena's compass bearing down the mist-choked steps toward Floodmill Wetlands..."], source, func(): get_parent().travel_to_floodmill())
				else:
					show_dialogue(title, ["The southeast marsh gate stands unlocked, awaiting Chapter 2: The Drowned Village."], source, func():
						source.set("ready_to_travel", true)
						if source.has_method("refresh_prompt"):
							source.refresh_prompt("[E] ENTER FLOODMILL WETLANDS")
					)
			else:
				show_dialogue(title, ["Dense marsh mist blocks the southeast road toward Floodmill. Complete your search at the First Beacon Shrine first."], source)

func _handle_floodmill_interaction(source: StaticBody2D) -> void:
	var kind: String = source.get_floodmill_kind()
	var obj_id: String = quest_manager.get_current_objective_id()
	var title: String = source.speaker_name if source.speaker_name != "" else "FLOODMILL"
	match kind:
		"entrance_arch":
			if obj_id == "enter_floodmill":
				show_dialogue(title, quest_manager.get_story_lines("floodmill_entry"), source, func(): quest_manager.complete_objective("enter_floodmill"))
			else:
				show_dialogue(title, ["Briarwood Forest climbs uphill behind the mist. Ahead lie Floodmill's drowned streets and the Old Watermill."], source)
		"village_plaque":
			if obj_id in ["enter_floodmill", "speak_lyra_arrival"]:
				show_dialogue(title, ["A chiseled census monolith rises from the flooded cobbles. Speak with Lyra at the entrance path first."], source)
			elif obj_id == "explore_ruined_village":
				show_dialogue(title, quest_manager.get_story_lines("village_monument"), source, func(): quest_manager.complete_objective("explore_ruined_village"))
			else:
				show_dialogue(title, quest_manager.get_story_lines("village_monument"), source)
		"optional_lore":
			var disc_id: String = String(source.get("item_id"))
			show_dialogue(title, quest_manager.get_story_lines("homestead_locket_note"), source, func():
				quest_manager.record_optional_discovery(disc_id)
				source.set("collected", true)
				source.queue_redraw()
			)
		"watermill_mechanism":
			if obj_id in ["enter_floodmill", "speak_lyra_arrival", "explore_ruined_village"]:
				show_dialogue(title, ["The Old Watermill's huge timber wheel stands jammed in silt. Inspect the square's Census Stone first."], source)
			elif obj_id == "discover_watermill":
				show_dialogue(title, quest_manager.get_story_lines("watermill_inspect"), source, func(): quest_manager.complete_objective("discover_watermill"))
			elif obj_id == "find_watermill_parts":
				show_dialogue(title, ["The stripped drive shaft needs three parts (%d/3): Iron Drive Gear, Bronze Pinion, and Oak Coupling Belt." % quest_manager.mill_parts_collected.size()], source)
			elif quest_manager.can_open_watermill_repair():
				open_watermill_repair(source)
			else:
				show_dialogue(title, ["The restored waterwheel turns steadily in its raceway, feeding pressure to the northern Sluice Console."], source)
		"mill_diagram":
			show_dialogue(title, quest_manager.get_story_lines("mill_diagram_clue"), source)
		"mill_part":
			if source.get("collected") == true:
				show_dialogue(title, ["You already recovered this watermill component."], source)
			elif not quest_manager.can_collect_mill_parts():
				show_dialogue(title, ["Salvageable millwright hardware lies in the moss. Examine the broken Watermill mechanism first so you know what fits."], source)
			else:
				var part_id: String = String(source.get("item_id"))
				show_dialogue(title, [source.message], source, func():
					if quest_manager.record_mill_part_collected(part_id):
						source.set("collected", true)
						source.queue_redraw()
				)
		"sluice_console":
			if not quest_manager.watermill_repaired:
				show_dialogue(title, ["No hydraulic pressure reaches the canal sluice wheels yet. Repair the Old Watermill on the east bank first."], source)
			elif obj_id == "investigate_sluice_gates":
				show_dialogue(title, quest_manager.get_story_lines("sluice_inspect"), source, func(): quest_manager.complete_objective("investigate_sluice_gates"))
			elif quest_manager.can_open_sluice_puzzle():
				open_sluice_puzzle(source)
			else:
				show_dialogue(title, ["All three sluices hold DIVERT, DRAIN, and OPEN cleanly, keeping the Forgotten Archive causeway dry."], source)
		"canal_clue":
			show_dialogue(title, quest_manager.get_story_lines("canal_gauge_clue"), source)
		"archive_entrance":
			if not quest_manager.sluice_solved:
				show_dialogue(title, ["Churning floodwater covers the Archive steps. Lower the canal level at the Sluice Console first."], source)
			elif obj_id == "enter_forgotten_archive":
				show_dialogue(title, quest_manager.get_story_lines("archive_entry"), source, func(): quest_manager.complete_objective("enter_forgotten_archive"))
			else:
				show_dialogue(title, quest_manager.get_story_lines("archive_entry"), source)
		"archive_record":
			var clue_id: String = String(source.get("item_id"))
			var lines: Array[String] = quest_manager.get_story_lines(clue_id)
			if not quest_manager.is_objective_completed("enter_forgotten_archive"):
				show_dialogue(title, ["Water-warped library shelves line the Forgotten Archive. Step past the Archive entrance threshold first."], source)
			elif obj_id == "reconstruct_village_ledger" and not quest_manager.archive_clues_found.has(clue_id):
				show_dialogue(title, lines, source, func():
					if quest_manager.record_archive_clue_found(clue_id):
						source.set("collected", true)
						source.queue_redraw()
				)
			else:
				show_dialogue(title, lines, source)
		"ledger_table":
			if not quest_manager.is_objective_completed("enter_forgotten_archive"):
				show_dialogue(title, ["A brass-clasped ledger sits open upon the library table. Enter the Forgotten Archive first."], source)
			elif obj_id == "reconstruct_village_ledger":
				if quest_manager.archive_clues_found.size() < 3:
					show_dialogue(title, ["Three columns are torn from the Master Ledger (%d/3 gathered). Inspect all three surviving Archive records around this room first." % quest_manager.archive_clues_found.size()], source)
				else:
					open_ledger_puzzle(source)
			elif obj_id == "discover_villagers_truth":
				show_dialogue("RESTORED VILLAGE LEDGER", quest_manager.get_story_lines("villagers_truth"), source, func(): quest_manager.complete_objective("discover_villagers_truth"))
			else:
				show_dialogue("RESTORED VILLAGE LEDGER", quest_manager.get_story_lines("villagers_truth"), source)
		"second_beacon":
			if not quest_manager.villagers_truth_discovered:
				show_dialogue(title, ["A quiet blue seal rests over the Second Ancient Beacon. Reconstruct the Forgotten Archive ledger and learn the villagers' fate first."], source)
			elif obj_id == "restore_second_beacon":
				show_dialogue(title, quest_manager.get_story_lines("second_beacon_activation"), source, func(): quest_manager.complete_objective("restore_second_beacon"))
			elif obj_id == "witness_elena_message":
				show_dialogue(title, quest_manager.get_story_lines("elena_recording_ch2"), source, func(): quest_manager.complete_objective("witness_elena_message"))
			else:
				show_dialogue(title, ["The Second Ancient Beacon burns bright above the marshes, lighting the northern mountain road to Ironwatch Keep."], source)
		"ironwatch_gate":
			if quest_manager.ironwatch_unlocked:
				if source.get("ready_to_travel") == true and get_parent().has_method("travel_to_ironwatch"):
					show_dialogue(title, ["Climbing the jagged basalt pass above Floodmill toward Ironwatch Keep..."], source, func(): get_parent().travel_to_ironwatch())
				else:
					show_dialogue(title, ["The eastern mountain pass stands unlocked, awaiting Chapter 3: Ironwatch Keep."], source, func():
						source.set("ready_to_travel", true)
						if source.has_method("refresh_prompt"):
							source.refresh_prompt("[E] ENTER IRONWATCH KEEP")
					)
			else:
				show_dialogue(title, ["Heavy iron portcullis bars seal the pass toward Ironwatch Keep. Restore Floodmill's Second Beacon first."], source)

func _handle_ironwatch_interaction(source: StaticBody2D) -> void:
	var kind: String = source.get_ironwatch_kind()
	var obj_id: String = quest_manager.get_current_objective_id()
	var title: String = source.speaker_name if source.speaker_name != "" else "IRONWATCH KEEP"
	match kind:
		"floodmill_return_gate":
			if get_parent().has_method("travel_to_floodmill"):
				show_dialogue(title, ["Descending the mountain switchbacks back toward Floodmill Wetlands..."], source, func(): get_parent().travel_to_floodmill())
			else:
				show_dialogue(title, ["Floodmill lies down the southern ridge."], source)
		"courtyard_arch":
			if obj_id == "enter_ironwatch":
				show_dialogue(title, quest_manager.get_story_lines("ironwatch_arrival"), source, func(): quest_manager.complete_objective("enter_ironwatch"))
			else:
				show_dialogue(title, ["Beyond Ironwatch's obsidian gatehouse, cold battlements overlook four stone Watchers."], source)
		"courtyard_monument":
			if obj_id == "enter_ironwatch":
				show_dialogue(title, ["Inspect Ironwatch's inner gate threshold first so Lyra can anchor her compass bearing."], source)
			elif obj_id == "investigate_courtyard":
				show_dialogue(title, quest_manager.get_story_lines("courtyard_inspected"), source, func(): quest_manager.complete_objective("investigate_courtyard"))
			else:
				show_dialogue(title, quest_manager.get_story_lines("courtyard_inspected"), source)
		"warden_records":
			if obj_id in ["enter_ironwatch", "investigate_courtyard"]:
				show_dialogue(title, ["Iron-bound ledgers line the cutaway Archives shelves. Investigate the Courtyard Statue Circle first."], source)
			elif obj_id == "discover_warden_records":
				show_dialogue(title, quest_manager.get_story_lines("warden_records_read"), source, func(): quest_manager.complete_objective("discover_warden_records"))
			else:
				show_dialogue(title, quest_manager.get_story_lines("warden_records_read"), source)
		"barracks_log":
			if obj_id in ["enter_ironwatch", "investigate_courtyard", "discover_warden_records"]:
				show_dialogue(title, ["Weathered bunks and roster books fill the garrison. Search the Fortress Archives records northeast first."], source)
			elif obj_id == "explore_barracks":
				show_dialogue(title, quest_manager.get_story_lines("barracks_inspected"), source, func(): quest_manager.complete_objective("explore_barracks"))
			else:
				show_dialogue(title, quest_manager.get_story_lines("barracks_inspected"), source)
		"barracks_keepsake":
			var disc_id: String = String(source.get("item_id"))
			show_dialogue(title, quest_manager.get_story_lines("barracks_keepsake_found"), source, func():
				quest_manager.record_optional_discovery(disc_id)
				quest_manager.barracks_keepsake_found = true
				source.set("collected", true)
				source.queue_redraw()
			)
		"crest_clue":
			var cid: String = String(source.get("item_id"))
			var lines: Array[String] = quest_manager.get_story_lines("crest_" + cid + "_text")
			if obj_id in ["enter_ironwatch", "investigate_courtyard", "discover_warden_records", "explore_barracks"]:
				show_dialogue(title, ["An ancient Watch crest tablet rests in sapphire inlay. Read the Archives and Barracks logs first."], source)
			elif obj_id == "find_crest_clues" and not quest_manager.crest_clues_found.has(cid):
				show_dialogue(title, lines, source, func():
					if quest_manager.record_crest_clue_found(cid):
						source.set("inspected", true)
						source.queue_redraw()
				)
			else:
				show_dialogue(title, lines, source)
		"crest_altar":
			if obj_id in ["enter_ironwatch", "investigate_courtyard", "discover_warden_records", "explore_barracks", "find_crest_clues"]:
				show_dialogue(title, ["Three heraldic sockets lock the Shadowed Passage (%d/3 historical clues found). Discover all three Watch tablets first." % quest_manager.crest_clues_found.size()], source)
			elif quest_manager.can_open_crest_puzzle():
				open_crest_puzzle(source)
			else:
				show_dialogue(title, ["SILVER BELL, SUNDERED SHIELD, and CROWNED FLAME shine above the unlocked Shadowed Passage."], source)
		"shadow_ward_switch":
			if not quest_manager.crest_puzzle_solved:
				show_dialogue(title, ["A violet ward-lantern seals the northern stair."], source)
			elif obj_id == "navigate_shadowed_passage":
				show_dialogue(title, quest_manager.get_story_lines("shadow_passage_completed"), source, func(): quest_manager.complete_objective("navigate_shadowed_passage"))
			else:
				show_dialogue(title, ["The North Ward Lantern glows steadily, holding the Shadow Sentinels at peace."], source)
		"elena_research":
			if not quest_manager.warden_confronted:
				show_dialogue(title, ["A sapphire travel notebook rests under a Warden crest. Confront the Last Bell Warden by the western steps first."], source)
			elif quest_manager.can_read_elena_research():
				show_dialogue(title, quest_manager.get_story_lines("elena_research_read"), source, func(): quest_manager.complete_objective("discover_elena_research"))
			else:
				show_dialogue(title, quest_manager.get_story_lines("elena_research_read"), source)
		"third_beacon":
			if not quest_manager.elena_research_found:
				show_dialogue(title, ["The Third Ancient Beacon waits dormant inside its star mandala. Confront the Last Bell Warden and read Elena's research first."], source)
			elif quest_manager.can_activate_third_beacon():
				show_dialogue(title, quest_manager.get_story_lines("third_beacon_restored"), source, func(): quest_manager.complete_objective("restore_third_beacon"))
			else:
				show_dialogue(title, ["All three Ancient Beacons—Briarwood, Floodmill, and Ironwatch—ring together in golden-sapphire harmony."], source)
		"dawnspire_gate":
			if not quest_manager.third_beacon_activated:
				show_dialogue(title, ["Heavy citadel chains seal the northern road toward Dawnspire. Restore Ironwatch's Third Ancient Beacon first."], source)
			elif obj_id == "unlock_dawnspire_road":
				show_dialogue(title, quest_manager.get_story_lines("dawnspire_gate_unlocked"), source, func(): quest_manager.complete_objective("unlock_dawnspire_road"))
			elif obj_id == "complete_chapter3":
				show_dialogue(title, [
					"AREN: \"The First Watch suffered a disaster, and later keepers hid the beacons instead of ending the cycle. Mother proved there is another way.\"",
					"LYRA: \"All three Ancient Beacons shine across Ashvale now, Aren. The mountain road to Dawnspire belongs to us.\""
				], source, func(): _finish_chapter3())
			else:
				show_dialogue(title, ["The Citadel Gate stands unlocked beneath the golden-sapphire beam pointing up toward Dawnspire."], source)

func open_rune_puzzle(source: StaticBody2D) -> void:
	if rune_puzzle == null or rune_puzzle.solved:
		return
	_open_modal_panel(rune_puzzle, source)

func open_bridge_repair(source: StaticBody2D) -> void:
	if bridge_repair == null or bridge_repair.repaired:
		return
	_open_modal_panel(bridge_repair, source)

func open_mirror_puzzle(source: StaticBody2D) -> void:
	if mirror_puzzle == null or mirror_puzzle.solved:
		return
	_open_modal_panel(mirror_puzzle, source)

func open_watermill_repair(source: StaticBody2D) -> void:
	if watermill_repair == null or watermill_repair.repaired:
		return
	_open_modal_panel(watermill_repair, source)

func open_sluice_puzzle(source: StaticBody2D) -> void:
	if sluice_puzzle == null or sluice_puzzle.solved:
		return
	terminal = source
	if player != null:
		player.set("movement_locked", true)
	if terminal != null:
		terminal.set_dialogue_open(true)
	$Prompt.hide()
	var saved_gates: Array = quest_manager.sluice_gate_states if quest_manager != null else []
	sluice_puzzle.open_puzzle(saved_gates)
	_update_selection()

func open_ledger_puzzle(source: StaticBody2D) -> void:
	if ledger_puzzle == null or ledger_puzzle.solved:
		return
	terminal = source
	if player != null:
		player.set("movement_locked", true)
	if terminal != null:
		terminal.set_dialogue_open(true)
	$Prompt.hide()
	var clues_ok: bool = quest_manager != null and quest_manager.archive_clues_found.size() >= 3
	ledger_puzzle.open_puzzle(clues_ok)
	_update_selection()

func open_crest_puzzle(source: StaticBody2D) -> void:
	if crest_puzzle == null or crest_puzzle.solved:
		return
	terminal = source
	if player != null:
		player.set("movement_locked", true)
	if terminal != null:
		terminal.set_dialogue_open(true)
	$Prompt.hide()
	var clues_ok: bool = quest_manager != null and quest_manager.crest_clues_found.size() >= 3
	crest_puzzle.open_puzzle(clues_ok)
	_update_selection()

func _open_modal_panel(modal_panel: Panel, source: StaticBody2D) -> void:
	terminal = source
	if player != null:
		player.set("movement_locked", true)
	if terminal != null:
		terminal.set_dialogue_open(true)
	$Prompt.hide()
	modal_panel.open_puzzle()
	_update_selection()

func _on_rune_puzzle_solved() -> void:
	if quest_manager != null:
		quest_manager.complete_objective("solve_rune_puzzle")
		var lines: Array[String] = quest_manager.get_story_lines("beacon_revelation")
		show_dialogue("STONE RUNE PEDESTAL", lines, terminal)
	else:
		_on_modal_closed()

func _on_bridge_repaired() -> void:
	if quest_manager != null:
		quest_manager.complete_objective("repair_bridge")
		show_dialogue("OLD BRIDGE", ["Left beam locked, walkway planks seated, and hemp lashings pulled tight. The Old Bridge now holds firm!", "Lyra steps lightly onto the northern bank toward the erased village ruins and Mirror Grove."], terminal)
	else:
		_on_modal_closed()

func _on_mirror_solved() -> void:
	if quest_manager != null:
		quest_manager.complete_objective("solve_mirror_puzzle")
		show_dialogue("MIRROR GROVE", ["Three golden-cyan sunbeams lock across the mossy receptors and shatter the ward-barrier ahead!", "The sanctuary path into the First Beacon Shrine stands open."], terminal)
	else:
		_on_modal_closed()

func _on_watermill_repaired() -> void:
	if quest_manager != null:
		quest_manager.complete_objective("restore_watermill")
		show_dialogue("OLD WATERMILL", ["Iron drive gear, bronze pinion, and oak coupling belt lock cleanly! The great waterwheel turns and sends pressure north to the Sluice Console."], terminal)
	else:
		_on_modal_closed()

func _on_sluice_states_changed(states: Array[int]) -> void:
	if quest_manager != null:
		quest_manager.sluice_gate_states = states.duplicate()
	var parent := get_parent()
	if parent != null and parent.name == "FloodmillVillage" and parent.has_node("Landscape"):
		parent.get_node("Landscape").sluice_gate_states = states.duplicate()
		parent.get_node("Landscape").queue_redraw()

func _on_sluice_solved() -> void:
	if quest_manager != null:
		quest_manager.sluice_gate_states.assign([2, 1, 3])
		quest_manager.complete_objective("redirect_water_flow")
		show_dialogue("CANAL SLUICE CONSOLE", ["Weirs divert, center lock drains, and east spillway vents cleanly! The floodwaters recede from the limestone steps into the Forgotten Archive."], terminal)
	else:
		_on_modal_closed()

func _on_ledger_solved() -> void:
	if quest_manager != null:
		quest_manager.complete_objective("reconstruct_village_ledger")
		show_dialogue("FORGOTTEN ARCHIVE", ["With all three fragments fitted together, the faded parish ledger lies open upon the oak table—examine it closely to read the villagers' fate."], terminal)
	else:
		_on_modal_closed()

func _on_crest_solved() -> void:
	if quest_manager != null:
		quest_manager.crest_pillar_states.assign([1, 2, 3])
		quest_manager.complete_objective("solve_crest_puzzle")
		show_dialogue("HALL OF CRESTS", quest_manager.get_story_lines("crest_puzzle_completed"), terminal)
	else:
		_on_modal_closed()

func _on_rune_puzzle_closed() -> void:
	_on_modal_closed()

func _on_modal_closed() -> void:
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

func _finish_chapter1() -> void:
	if quest_manager != null:
		quest_manager.complete_objective("complete_chapter1")
	if prologue_banner != null:
		$PrologueComplete/BannerTitle.text = "CHAPTER 1 COMPLETE — WHISPERS OF BRIARWOOD"
		$PrologueComplete/Summary.text = "The First Ancient Beacon stands restored. Elena's echo and Lyra's compass point southeast toward Floodmill Wetlands.\n\nCHAPTER 2 UNLOCKED: THE DROWNED VILLAGE"
		$PrologueComplete/ContinueHint.text = "[E] / [ESC] CONTINUE EXPLORING BRIARWOOD"
		prologue_banner.show()
	if player != null:
		player.set("movement_locked", true)
	if terminal != null:
		terminal.set_dialogue_open(true)
	$Prompt.hide()
	_update_selection()

func _finish_chapter2() -> void:
	if quest_manager != null:
		quest_manager.complete_objective("complete_chapter2")
	if prologue_banner != null:
		$PrologueComplete/BannerTitle.text = "CHAPTER 2 COMPLETE — THE DROWNED VILLAGE"
		$PrologueComplete/Summary.text = "The Second Ancient Beacon burns above Floodmill. The truth of thirty-six forgotten hearths points northeast toward Ironwatch Keep.\n\nCHAPTER 3 UNLOCKED: THE KEEPER'S LIE"
		$PrologueComplete/ContinueHint.text = "[E] / [ESC] CONTINUE EXPLORING FLOODMILL"
		prologue_banner.show()
	if player != null:
		player.set("movement_locked", true)
	if terminal != null:
		terminal.set_dialogue_open(true)
	$Prompt.hide()
	_update_selection()

func _finish_chapter3() -> void:
	if quest_manager != null:
		quest_manager.complete_objective("complete_chapter3")
	if prologue_banner != null:
		$PrologueComplete/BannerTitle.text = "CHAPTER 3 COMPLETE — THE KEEPER'S LIE"
		$PrologueComplete/Summary.text = "The Third Ancient Beacon burns above Ironwatch Vault, uniting Briarwood, Floodmill, and Ironwatch in harmonic light.\n\nTHE ROAD TO DAWNSPIRE STANDS UNLOCKED"
		$PrologueComplete/ContinueHint.text = "[E] / [ESC] CONTINUE EXPLORING IRONWATCH"
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

func open_inventory() -> void:
	if inventory_panel == null:
		return
	if player != null:
		player.set("movement_locked", true)
	if terminal != null:
		terminal.set_dialogue_open(true)
	$Prompt.hide()
	inventory_panel.open_inventory(quest_manager)
	_update_selection()

func _on_menu_inventory_requested() -> void:
	if title_menu != null:
		title_menu.hide()
	open_inventory()

func open_title_menu(status_text: String = "") -> void:
	if title_menu == null:
		return
	var summary: Dictionary = QuestManagerScript.peek_save_summary(save_path)
	if player != null:
		player.set("movement_locked", true)
	if terminal != null:
		terminal.set_dialogue_open(true)
	$Prompt.hide()
	title_menu.open_menu(bool(summary.get("valid", false)), status_text)
	_update_selection()

func manual_save(custom_path: String = "") -> bool:
	if quest_manager == null:
		return false
	var target_path: String = save_path if custom_path == "" else custom_path
	var err: Error = quest_manager.save_to_file(target_path)
	var ok: bool = (err == OK)
	if title_menu != null and title_menu.visible:
		if ok:
			title_menu.has_save = true
			title_menu._refresh_buttons()
			title_menu.set_feedback("Progress saved safely to chronicle file.", false)
		else:
			title_menu.set_feedback("Save failed with error code %d." % err, true)
	return ok

func start_new_game() -> void:
	if title_menu != null:
		title_menu.hide()
	if terminal != null:
		terminal.set_dialogue_open(false)
	QuestManagerScript.pending_load_path = ""
	QuestManagerScript.carry_prologue_completed = false
	QuestManagerScript.carry_chapter1_completed = false
	QuestManagerScript.carry_chapter2_completed = false
	var parent := get_parent()
	if parent != null and parent.has_method("reset_new_game"):
		parent.reset_new_game()
	elif is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/sjt_exterior.tscn")

func continue_game(custom_path: String = "") -> bool:
	var target_path: String = save_path if custom_path == "" else custom_path
	var summary: Dictionary = QuestManagerScript.peek_save_summary(target_path)
	if not bool(summary.get("valid", false)):
		if title_menu != null:
			title_menu.has_save = false
			title_menu._refresh_buttons()
			title_menu.set_feedback("No valid save data found to continue.", true)
		return false
	if title_menu != null:
		title_menu.hide()
	var target_region: String = String(summary.get("region_scene", "res://scenes/sjt_exterior.tscn"))
	var parent := get_parent()
	var same_briarwood: bool = target_region.ends_with("briarwood_forest.tscn") and parent != null and parent.name == "BriarwoodForest"
	var same_bellhaven: bool = target_region.ends_with("sjt_exterior.tscn") and parent != null and parent.has_method("reset_new_game")
	var same_floodmill: bool = target_region.ends_with("floodmill_village.tscn") and parent != null and parent.name == "FloodmillVillage"
	var same_ironwatch: bool = target_region.ends_with("ironwatch_keep.tscn") and parent != null and parent.name == "IronwatchKeep"
	if same_briarwood or same_bellhaven or same_floodmill or same_ironwatch:
		var loaded: bool = parent.apply_saved_state(target_path)
		if loaded and player != null:
			player.set("movement_locked", false)
		if loaded and terminal != null:
			terminal.set_dialogue_open(false)
		_update_selection()
		return loaded
	QuestManagerScript.pending_load_path = target_path
	if is_inside_tree():
		get_tree().change_scene_to_file(target_region)
	return true

func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	var vp: Viewport = get_viewport()
	if not _is_modal_open() and event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_I or event.keycode == KEY_TAB:
			open_inventory()
			if vp != null and is_inside_tree():
				vp.set_input_as_handled()
			return
		elif event.keycode == KEY_M or event.keycode == KEY_F10:
			open_title_menu()
			if vp != null and is_inside_tree():
				vp.set_input_as_handled()
			return
		elif event.keycode == KEY_F5:
			manual_save()
			if vp != null and is_inside_tree():
				vp.set_input_as_handled()
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
		if vp != null and is_inside_tree():
			vp.set_input_as_handled()
		return
	if panel.visible:
		if is_confirm:
			if vp != null and is_inside_tree():
				vp.set_input_as_handled()
			if dialogue_index + 1 < dialogue_lines.size():
				dialogue_index += 1
				_render_dialogue_page()
			else:
				_close_dialogue(true)
		elif is_cancel:
			if vp != null and is_inside_tree():
				vp.set_input_as_handled()
			var on_last_page: bool = (dialogue_index >= dialogue_lines.size() - 1)
			_close_dialogue(on_last_page)
