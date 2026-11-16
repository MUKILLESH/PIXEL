extends Node
## Data-driven chronological quest tracker supporting Prologue, Chapter 1, Chapter 2, Chapter 3, and atomic saves.

signal objective_changed(objective_id: String, objective_text: String)
signal objective_completed(objective_id: String)
signal quest_completed(quest_id: String)

const QUEST_DATA_PATH := "res://data/prologue_quest.json"
const CHAPTER3_DATA_PATH := "res://data/chapter3_quest.json"
const SAVE_VERSION := 3
const CREST_SYMBOLS: Array[String] = ["IRON SWORD", "SILVER BELL", "SUNDERED SHIELD", "CROWNED FLAME"]

static var pending_load_path: String = ""
static var pending_entry_pose: bool = false
static var pending_entry_position: Vector2 = Vector2.ZERO
static var pending_entry_facing: int = 2
static var carry_prologue_completed: bool = false
static var carry_chapter1_completed: bool = false
static var carry_chapter2_completed: bool = false
static var carry_optional_discoveries: Dictionary = {}

@export var quest_data_path: String = QUEST_DATA_PATH

var quest_id: String = "prologue_thirteenth_toll"
var quest_title: String = "Prologue: The Thirteenth Toll"
var data: Dictionary = {}
var objectives: Array = []
var current_index: int = 0
var completed_objectives: Dictionary = {}

# Phase 1 state
var talked_npcs: Dictionary = {}
var letter_found: bool = false
var puzzle_solved: bool = false
var briarwood_discovered: bool = false
var prologue_completed: bool = false
var briarwood_unlocked: bool = false

# Phase 2 (Chapter 1) state
var materials_collected: Dictionary = {}
var inscriptions_read: Dictionary = {}
var optional_discoveries: Dictionary = {}
var bridge_repaired: bool = false
var mirror_puzzle_solved: bool = false
var beacon_activated: bool = false
var elena_echo_heard: bool = false
var chapter1_completed: bool = false
var floodmill_unlocked: bool = false

# Phase 3 (Chapter 2: The Drowned Village) state
var mill_parts_collected: Dictionary = {}
var watermill_repaired: bool = false
var sluice_gate_states: Array[int] = [0, 0, 0]
var sluice_solved: bool = false
var archive_clues_found: Dictionary = {}
var ledger_reconstructed: bool = false
var villagers_truth_discovered: bool = false
var second_beacon_activated: bool = false
var chapter2_elena_echo_heard: bool = false
var chapter2_completed: bool = false
var ironwatch_unlocked: bool = false

# Phase 4 (Chapter 3: The Keeper's Lie) state
var crest_solution: Array[String] = ["SILVER BELL", "SUNDERED SHIELD", "CROWNED FLAME"]
var warden_records_found: bool = false
var barracks_explored: bool = false
var barracks_keepsake_found: bool = false
var crest_clues_found: Dictionary = {}
var crest_pillar_states: Array[int] = [0, 0, 0]
var crest_puzzle_solved: bool = false
var stealth_checkpoint_id: String = "checkpoint_0"
var stealth_checkpoint_pos: Vector2 = Vector2(-150, -32)
var stealth_detections_count: int = 0
var shadow_passage_cleared: bool = false
var warden_confronted: bool = false
var elena_research_found: bool = false
var third_beacon_activated: bool = false
var dawnspire_unlocked: bool = false
var chapter3_completed: bool = false

# Saved region & player pose
var saved_region_scene: String = ""
var saved_player_position: Vector2 = Vector2.ZERO
var saved_player_facing: int = 2
var has_saved_player_pose: bool = false

func _ready() -> void:
	load_quest_data()

func load_quest_data(path: String = "") -> void:
	if path != "":
		quest_data_path = path
	var file := FileAccess.open(quest_data_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open quest data: " + quest_data_path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid JSON in quest data: " + quest_data_path)
		return
	data = parsed
	quest_id = String(data.get("quest_id", quest_id))
	quest_title = String(data.get("title", quest_title))
	objectives = data.get("objectives", [])
	var raw_crest_sol: Variant = data.get("crest_solution", ["SILVER BELL", "SUNDERED SHIELD", "CROWNED FLAME"])
	if raw_crest_sol is Array and raw_crest_sol.size() == 3:
		crest_solution = []
		for cs in raw_crest_sol:
			crest_solution.append(String(cs))

func reload_quest(path: String) -> void:
	current_index = 0
	completed_objectives.clear()
	talked_npcs.clear()
	letter_found = false
	puzzle_solved = false
	briarwood_discovered = false
	prologue_completed = false
	briarwood_unlocked = false
	materials_collected.clear()
	inscriptions_read.clear()
	optional_discoveries.clear()
	bridge_repaired = false
	mirror_puzzle_solved = false
	beacon_activated = false
	elena_echo_heard = false
	chapter1_completed = false
	floodmill_unlocked = false
	mill_parts_collected.clear()
	watermill_repaired = false
	sluice_gate_states = [0, 0, 0]
	sluice_solved = false
	archive_clues_found.clear()
	ledger_reconstructed = false
	villagers_truth_discovered = false
	second_beacon_activated = false
	chapter2_elena_echo_heard = false
	chapter2_completed = false
	ironwatch_unlocked = false
	warden_records_found = false
	barracks_explored = false
	barracks_keepsake_found = false
	crest_clues_found.clear()
	crest_pillar_states = [0, 0, 0]
	crest_puzzle_solved = false
	stealth_checkpoint_id = "checkpoint_0"
	stealth_checkpoint_pos = Vector2(-150, -32)
	stealth_detections_count = 0
	shadow_passage_cleared = false
	warden_confronted = false
	elena_research_found = false
	third_beacon_activated = false
	dawnspire_unlocked = false
	chapter3_completed = false
	saved_region_scene = ""
	saved_player_position = Vector2.ZERO
	saved_player_facing = 2
	has_saved_player_pose = false
	load_quest_data(path)
	objective_changed.emit(get_current_objective_id(), get_current_objective_text())

func start_chapter3() -> void:
	carry_prologue_completed = true
	carry_chapter1_completed = true
	carry_chapter2_completed = true
	reload_quest(CHAPTER3_DATA_PATH)
	prologue_completed = true
	briarwood_unlocked = true
	chapter1_completed = true
	floodmill_unlocked = true
	beacon_activated = true
	chapter2_completed = true
	ironwatch_unlocked = true
	second_beacon_activated = true
	objective_changed.emit(get_current_objective_id(), get_current_objective_text())

func get_current_objective_id() -> String:
	if current_index < objectives.size():
		return String(objectives[current_index].get("id", ""))
	return "completed"

func get_current_objective_text() -> String:
	if quest_id == "chapter3_keepers_lie":
		if chapter3_completed or current_index >= objectives.size():
			return "Chapter 3 Complete - Dawnspire Road Unlocked."
		var ch3_id: String = get_current_objective_id()
		if ch3_id == "find_crest_clues":
			return "Find the three historical crest clues (%d/3)." % crest_clues_found.size()
		return String(objectives[current_index].get("text", ""))

	if quest_id == "chapter2_drowned_village":
		if chapter2_completed or current_index >= objectives.size():
			return "Chapter 2 Complete - Ironwatch Keep Unlocked."
		var ch2_id: String = get_current_objective_id()
		if ch2_id == "find_watermill_parts":
			return "Find the watermill repair components (%d/3)." % mill_parts_collected.size()
		if ch2_id == "reconstruct_village_ledger":
			return "Gather 3 damaged records and reconstruct the ledger (%d/3)." % archive_clues_found.size()
		return String(objectives[current_index].get("text", ""))

	if quest_id == "chapter1_whispers_of_briarwood":
		if chapter1_completed or current_index >= objectives.size():
			return "Chapter 1 Complete - Floodmill Unlocked."
		var ch1_id: String = get_current_objective_id()
		if ch1_id == "find_repair_materials":
			return "Gather bridge materials at the worksite (%d/3)." % materials_collected.size()
		if ch1_id == "discover_inscriptions":
			return "Read the three ancient forest inscriptions (%d/3)." % inscriptions_read.size()
		return String(objectives[current_index].get("text", ""))

	if prologue_completed or current_index >= objectives.size():
		return "Prologue Complete - Briarwood Unlocked."
	var obj_id: String = get_current_objective_id()
	if obj_id == "speak_npcs":
		return "Speak with the three villagers (%d/3)." % talked_npcs.size()
	return String(objectives[current_index].get("text", ""))

func is_objective_completed(id: String) -> bool:
	return bool(completed_objectives.get(id, false))

func is_quest_completed(id: String = "prologue_thirteenth_toll") -> bool:
	if id != quest_id:
		return false
	if quest_id == "chapter3_keepers_lie":
		return chapter3_completed
	if quest_id == "chapter2_drowned_village":
		return chapter2_completed
	if quest_id == "chapter1_whispers_of_briarwood":
		return chapter1_completed
	return prologue_completed

func can_open_mothers_letter() -> bool:
	return is_objective_completed("speak_npcs")

func can_open_rune_puzzle() -> bool:
	return get_current_objective_id() == "solve_rune_puzzle" and not puzzle_solved

func can_collect_materials() -> bool:
	return get_current_objective_id() == "find_repair_materials"

func can_open_bridge_repair() -> bool:
	return get_current_objective_id() == "repair_bridge" and not bridge_repaired

func can_open_mirror_puzzle() -> bool:
	return get_current_objective_id() == "solve_mirror_puzzle" and not mirror_puzzle_solved

func can_collect_mill_parts() -> bool:
	return get_current_objective_id() == "find_watermill_parts"

func can_open_watermill_repair() -> bool:
	return get_current_objective_id() == "restore_watermill" and not watermill_repaired and mill_parts_collected.size() >= 3

func can_open_sluice_puzzle() -> bool:
	return get_current_objective_id() == "redirect_water_flow" and not sluice_solved and watermill_repaired

func can_open_ledger_puzzle() -> bool:
	return get_current_objective_id() == "reconstruct_village_ledger" and not ledger_reconstructed and archive_clues_found.size() >= 3

func can_inspect_courtyard() -> bool:
	return get_current_objective_id() == "investigate_courtyard"

func can_read_warden_records() -> bool:
	return get_current_objective_id() == "discover_warden_records" and not warden_records_found

func can_explore_barracks() -> bool:
	return get_current_objective_id() == "explore_barracks" and not barracks_explored

func can_collect_crest_clues() -> bool:
	return get_current_objective_id() == "find_crest_clues"

func can_open_crest_puzzle() -> bool:
	return get_current_objective_id() == "solve_crest_puzzle" and not crest_puzzle_solved and crest_clues_found.size() >= 3

func check_crest_combination(symbols: Array) -> bool:
	if symbols.size() != crest_solution.size():
		return false
	for i in range(crest_solution.size()):
		if String(symbols[i]).strip_edges().to_upper() != crest_solution[i].strip_edges().to_upper():
			return false
	return true

func set_stealth_checkpoint(cp_id: String, cp_pos: Vector2) -> void:
	stealth_checkpoint_id = cp_id
	stealth_checkpoint_pos = cp_pos

func record_stealth_detection() -> void:
	stealth_detections_count += 1

func can_confront_warden() -> bool:
	return get_current_objective_id() == "confront_last_warden" and not warden_confronted

func can_read_elena_research() -> bool:
	return get_current_objective_id() == "discover_elena_research" and not elena_research_found

func can_activate_third_beacon() -> bool:
	return get_current_objective_id() == "restore_third_beacon" and not third_beacon_activated

func can_unlock_dawnspire() -> bool:
	return get_current_objective_id() == "unlock_dawnspire_road" and not dawnspire_unlocked

func complete_objective(id: String) -> bool:
	var active_quest_done: bool = chapter3_completed if quest_id == "chapter3_keepers_lie" else (chapter2_completed if quest_id == "chapter2_drowned_village" else (chapter1_completed if quest_id == "chapter1_whispers_of_briarwood" else prologue_completed))
	if active_quest_done or get_current_objective_id() != id or completed_objectives.has(id):
		return false
	completed_objectives[id] = true
	match id:
		"find_mothers_letter":
			letter_found = true
		"solve_rune_puzzle":
			puzzle_solved = true
		"discover_briarwood_path":
			briarwood_discovered = true
		"repair_bridge":
			bridge_repaired = true
		"solve_mirror_puzzle":
			mirror_puzzle_solved = true
		"activate_first_beacon":
			beacon_activated = true
		"experience_elena_recording":
			elena_echo_heard = true
		"restore_watermill":
			watermill_repaired = true
		"redirect_water_flow":
			sluice_solved = true
		"reconstruct_village_ledger":
			ledger_reconstructed = true
		"discover_villagers_truth":
			villagers_truth_discovered = true
		"restore_second_beacon":
			second_beacon_activated = true
		"witness_elena_message":
			chapter2_elena_echo_heard = true
		"discover_warden_records":
			warden_records_found = true
		"explore_barracks":
			barracks_explored = true
		"solve_crest_puzzle":
			crest_puzzle_solved = true
		"navigate_shadowed_passage":
			shadow_passage_cleared = true
		"confront_last_warden":
			warden_confronted = true
		"discover_elena_research":
			elena_research_found = true
		"restore_third_beacon":
			third_beacon_activated = true
		"unlock_dawnspire_road":
			dawnspire_unlocked = true
	current_index += 1
	var reached_end: bool = (current_index >= objectives.size())
	if reached_end:
		if quest_id == "chapter3_keepers_lie":
			chapter3_completed = true
			dawnspire_unlocked = true
		elif quest_id == "chapter2_drowned_village":
			chapter2_completed = true
			ironwatch_unlocked = true
		elif quest_id == "chapter1_whispers_of_briarwood":
			chapter1_completed = true
			floodmill_unlocked = true
		else:
			prologue_completed = true
			briarwood_unlocked = true
	objective_completed.emit(id)
	if reached_end:
		objective_changed.emit("completed", get_current_objective_text())
		quest_completed.emit(quest_id)
	else:
		objective_changed.emit(get_current_objective_id(), get_current_objective_text())
	return true

func record_npc_talked(npc_id: String) -> bool:
	if get_current_objective_id() != "speak_npcs":
		return false
	if talked_npcs.has(npc_id):
		return false
	talked_npcs[npc_id] = true
	if talked_npcs.size() >= 3:
		return complete_objective("speak_npcs")
	objective_changed.emit("speak_npcs", get_current_objective_text())
	return true

func record_material_collected(mat_id: String) -> bool:
	if get_current_objective_id() != "find_repair_materials":
		return false
	if materials_collected.has(mat_id):
		return false
	materials_collected[mat_id] = true
	if materials_collected.size() >= 3:
		return complete_objective("find_repair_materials")
	objective_changed.emit("find_repair_materials", get_current_objective_text())
	return true

func record_inscription_read(insc_id: String) -> bool:
	if get_current_objective_id() != "discover_inscriptions":
		return false
	if inscriptions_read.has(insc_id):
		return false
	inscriptions_read[insc_id] = true
	if inscriptions_read.size() >= 3:
		return complete_objective("discover_inscriptions")
	objective_changed.emit("discover_inscriptions", get_current_objective_text())
	return true

func record_optional_discovery(disc_id: String) -> bool:
	optional_discoveries[disc_id] = true
	return true

func record_mill_part_collected(part_id: String) -> bool:
	if get_current_objective_id() != "find_watermill_parts":
		return false
	if mill_parts_collected.has(part_id):
		return false
	mill_parts_collected[part_id] = true
	if mill_parts_collected.size() >= 3:
		return complete_objective("find_watermill_parts")
	objective_changed.emit("find_watermill_parts", get_current_objective_text())
	return true

func record_archive_clue_found(clue_id: String) -> bool:
	if get_current_objective_id() != "reconstruct_village_ledger" or ledger_reconstructed:
		return false
	if archive_clues_found.has(clue_id):
		return false
	archive_clues_found[clue_id] = true
	objective_changed.emit("reconstruct_village_ledger", get_current_objective_text())
	return true

func record_crest_clue_found(clue_id: String) -> bool:
	if get_current_objective_id() != "find_crest_clues":
		return false
	if crest_clues_found.has(clue_id):
		return false
	crest_clues_found[clue_id] = true
	if crest_clues_found.size() >= 3:
		return complete_objective("find_crest_clues")
	objective_changed.emit("find_crest_clues", get_current_objective_text())
	return true

func get_npc_dialogue(npc_id: String) -> Array[String]:
	var npcs: Dictionary = data.get("npcs", {})
	var entry: Dictionary = npcs.get(npc_id, {})
	var stage_key := "investigation"
	if quest_id == "chapter3_keepers_lie":
		stage_key = get_current_objective_id()
		if not entry.has(stage_key):
			stage_key = "default"
	elif quest_id == "chapter2_drowned_village":
		var ch2_obj: String = get_current_objective_id()
		match ch2_obj:
			"enter_floodmill":
				stage_key = "before_entry"
			"speak_lyra_arrival":
				stage_key = "arrival"
			"explore_ruined_village":
				stage_key = "explore_village"
			"discover_watermill":
				stage_key = "watermill_search"
			"find_watermill_parts":
				stage_key = "watermill_parts"
			"restore_watermill":
				stage_key = "watermill_ready"
			"investigate_sluice_gates":
				stage_key = "sluice_search"
			"redirect_water_flow":
				stage_key = "sluice_ready"
			"enter_forgotten_archive":
				stage_key = "archive_search"
			"reconstruct_village_ledger":
				stage_key = "ledger_ready" if archive_clues_found.size() >= 3 else "archive_clues"
			"discover_villagers_truth":
				stage_key = "truth_reveal"
			"restore_second_beacon":
				stage_key = "beacon_ready"
			"witness_elena_message":
				stage_key = "echo_ready"
			"complete_chapter2":
				stage_key = "finale"
			_:
				stage_key = "completed"
	elif npc_id == "lyra" or quest_id == "chapter1_whispers_of_briarwood":
		var obj_id: String = get_current_objective_id()
		match obj_id:
			"enter_briarwood":
				stage_key = "before_entry"
			"meet_lyra":
				stage_key = "meet_lyra"
			"investigate_bridge", "find_repair_materials":
				stage_key = "bridge_search"
			"repair_bridge":
				stage_key = "bridge_ready"
			"discover_inscriptions":
				stage_key = "north_exploration"
			"solve_mirror_puzzle":
				stage_key = "mirror_ready"
			"activate_first_beacon":
				stage_key = "beacon_ready"
			"experience_elena_recording":
				stage_key = "echo_ready"
			"complete_chapter1":
				stage_key = "finale"
			_:
				stage_key = "completed"
	else:
		if current_index == 0:
			stage_key = "before_pedestal"
		elif current_index >= 4:
			stage_key = "after_puzzle"
	var raw_lines: Array = entry.get(stage_key, entry.get("default", []))
	var lines: Array[String] = []
	for item in raw_lines:
		lines.append(String(item))
	return lines

func get_story_lines(event_id: String) -> Array[String]:
	var events: Dictionary = data.get("story_events", {})
	var raw_lines: Array = events.get(event_id, [])
	var lines: Array[String] = []
	for item in raw_lines:
		lines.append(String(item))
	return lines

func get_rune_solution() -> Array[String]:
	var raw: Array = data.get("rune_solution", ["MOON", "SUN", "STAR"])
	var solution: Array[String] = []
	for item in raw:
		solution.append(String(item))
	return solution

func capture_state() -> Dictionary:
	var region_scene: String = "res://scenes/sjt_exterior.tscn"
	if quest_id == "chapter3_keepers_lie":
		region_scene = "res://scenes/ironwatch_keep.tscn"
	elif quest_id == "chapter2_drowned_village":
		region_scene = "res://scenes/floodmill_village.tscn"
	elif quest_id == "chapter1_whispers_of_briarwood":
		region_scene = "res://scenes/briarwood_forest.tscn"
	var parent_node := get_parent()
	if parent_node != null:
		if parent_node.scene_file_path != "":
			region_scene = parent_node.scene_file_path
		var p_node := parent_node.get_node_or_null("Actors/Player") as Node2D
		if p_node != null:
			saved_player_position = p_node.position
			saved_player_facing = int(p_node.get("facing"))
			has_saved_player_pose = true
	saved_region_scene = region_scene
	return {
		"version": SAVE_VERSION,
		"quest_id": quest_id,
		"quest_data_path": quest_data_path,
		"region_scene": region_scene,
		"has_player_pose": has_saved_player_pose,
		"player_x": saved_player_position.x,
		"player_y": saved_player_position.y,
		"player_facing": saved_player_facing,
		"current_index": current_index,
		"completed_objectives": completed_objectives.duplicate(),
		"talked_npcs": talked_npcs.duplicate(),
		"letter_found": letter_found,
		"puzzle_solved": puzzle_solved,
		"briarwood_discovered": briarwood_discovered,
		"prologue_completed": prologue_completed,
		"briarwood_unlocked": briarwood_unlocked,
		"materials_collected": materials_collected.duplicate(),
		"inscriptions_read": inscriptions_read.duplicate(),
		"optional_discoveries": optional_discoveries.duplicate(),
		"bridge_repaired": bridge_repaired,
		"mirror_puzzle_solved": mirror_puzzle_solved,
		"beacon_activated": beacon_activated,
		"elena_echo_heard": elena_echo_heard,
		"chapter1_completed": chapter1_completed,
		"floodmill_unlocked": floodmill_unlocked,
		"mill_parts_collected": mill_parts_collected.duplicate(),
		"watermill_repaired": watermill_repaired,
		"sluice_gate_states": sluice_gate_states.duplicate(),
		"sluice_solved": sluice_solved,
		"archive_clues_found": archive_clues_found.duplicate(),
		"ledger_reconstructed": ledger_reconstructed,
		"villagers_truth_discovered": villagers_truth_discovered,
		"second_beacon_activated": second_beacon_activated,
		"chapter2_elena_echo_heard": chapter2_elena_echo_heard,
		"chapter2_completed": chapter2_completed,
		"ironwatch_unlocked": ironwatch_unlocked,
		"warden_records_found": warden_records_found,
		"barracks_explored": barracks_explored,
		"barracks_keepsake_found": barracks_keepsake_found,
		"crest_clues_found": crest_clues_found.duplicate(),
		"crest_pillar_states": crest_pillar_states.duplicate(),
		"crest_puzzle_solved": crest_puzzle_solved,
		"stealth_checkpoint_id": stealth_checkpoint_id,
		"stealth_checkpoint_pos_x": stealth_checkpoint_pos.x,
		"stealth_checkpoint_pos_y": stealth_checkpoint_pos.y,
		"stealth_detections_count": stealth_detections_count,
		"shadow_passage_cleared": shadow_passage_cleared,
		"warden_confronted": warden_confronted,
		"elena_research_found": elena_research_found,
		"third_beacon_activated": third_beacon_activated,
		"dawnspire_unlocked": dawnspire_unlocked,
		"chapter3_completed": chapter3_completed,
	}

func apply_state(state: Dictionary) -> bool:
	if not (state is Dictionary) or not state.has("version"):
		return false
	if typeof(state["version"]) not in [TYPE_INT, TYPE_FLOAT]:
		return false
	var ver: int = int(state["version"])
	if ver < 1 or ver > SAVE_VERSION:
		return false
	var path: String = String(state.get("quest_data_path", quest_data_path))
	if path == "" or not FileAccess.file_exists(path):
		return false
	if state.has("completed_objectives") and typeof(state["completed_objectives"]) != TYPE_DICTIONARY:
		return false
	if state.has("current_index") and (typeof(state["current_index"]) not in [TYPE_INT, TYPE_FLOAT] or int(state["current_index"]) < 0):
		return false
	if path != quest_data_path:
		load_quest_data(path)
	current_index = clampi(int(state.get("current_index", 0)), 0, objectives.size())
	completed_objectives = (state.get("completed_objectives", {}) as Dictionary).duplicate()
	talked_npcs = (state.get("talked_npcs", {}) as Dictionary).duplicate()
	letter_found = bool(state.get("letter_found", false))
	puzzle_solved = bool(state.get("puzzle_solved", false))
	briarwood_discovered = bool(state.get("briarwood_discovered", false))
	prologue_completed = bool(state.get("prologue_completed", false))
	briarwood_unlocked = bool(state.get("briarwood_unlocked", false))
	materials_collected = (state.get("materials_collected", {}) as Dictionary).duplicate()
	inscriptions_read = (state.get("inscriptions_read", {}) as Dictionary).duplicate()
	optional_discoveries = (state.get("optional_discoveries", {}) as Dictionary).duplicate()
	bridge_repaired = bool(state.get("bridge_repaired", false))
	mirror_puzzle_solved = bool(state.get("mirror_puzzle_solved", false))
	beacon_activated = bool(state.get("beacon_activated", false))
	elena_echo_heard = bool(state.get("elena_echo_heard", false))
	chapter1_completed = bool(state.get("chapter1_completed", false))
	floodmill_unlocked = bool(state.get("floodmill_unlocked", false))

	# Phase 3 fields (safely defaulted when migrating v1 saves)
	var raw_parts: Variant = state.get("mill_parts_collected", {})
	mill_parts_collected = raw_parts.duplicate() if raw_parts is Dictionary else {}
	watermill_repaired = bool(state.get("watermill_repaired", false))
	var raw_sluice: Variant = state.get("sluice_gate_states", [0, 0, 0])
	sluice_gate_states = [0, 0, 0]
	if raw_sluice is Array and raw_sluice.size() == 3:
		for si in range(3):
			sluice_gate_states[si] = clampi(int(raw_sluice[si]), 0, 3)
	sluice_solved = bool(state.get("sluice_solved", false))
	var raw_clues: Variant = state.get("archive_clues_found", {})
	archive_clues_found = raw_clues.duplicate() if raw_clues is Dictionary else {}
	ledger_reconstructed = bool(state.get("ledger_reconstructed", false))
	villagers_truth_discovered = bool(state.get("villagers_truth_discovered", false))
	second_beacon_activated = bool(state.get("second_beacon_activated", false))
	chapter2_elena_echo_heard = bool(state.get("chapter2_elena_echo_heard", false))
	chapter2_completed = bool(state.get("chapter2_completed", false))
	ironwatch_unlocked = bool(state.get("ironwatch_unlocked", false))

	# Phase 4 fields (safely defaulted when migrating v1/v2 saves)
	warden_records_found = bool(state.get("warden_records_found", false))
	barracks_explored = bool(state.get("barracks_explored", false))
	barracks_keepsake_found = bool(state.get("barracks_keepsake_found", false))
	var raw_crest_clues: Variant = state.get("crest_clues_found", {})
	crest_clues_found = {}
	if raw_crest_clues is Dictionary:
		crest_clues_found = raw_crest_clues.duplicate()
	elif raw_crest_clues is Array:
		for cc in raw_crest_clues:
			crest_clues_found[String(cc)] = true
	var raw_crest_pillars: Variant = state.get("crest_pillar_states", [0, 0, 0])
	crest_pillar_states = [0, 0, 0]
	if raw_crest_pillars is Array and raw_crest_pillars.size() == 3:
		for ci in range(3):
			crest_pillar_states[ci] = clampi(int(raw_crest_pillars[ci]), 0, 3)
	crest_puzzle_solved = bool(state.get("crest_puzzle_solved", false))
	stealth_checkpoint_id = String(state.get("stealth_checkpoint_id", "checkpoint_0"))
	stealth_checkpoint_pos = Vector2(
		float(state.get("stealth_checkpoint_pos_x", -150.0)),
		float(state.get("stealth_checkpoint_pos_y", -32.0))
	)
	stealth_detections_count = int(state.get("stealth_detections_count", 0))
	shadow_passage_cleared = bool(state.get("shadow_passage_cleared", false))
	warden_confronted = bool(state.get("warden_confronted", false))
	elena_research_found = bool(state.get("elena_research_found", false))
	third_beacon_activated = bool(state.get("third_beacon_activated", false))
	dawnspire_unlocked = bool(state.get("dawnspire_unlocked", false))
	chapter3_completed = bool(state.get("chapter3_completed", false))

	saved_region_scene = String(state.get("region_scene", ""))
	has_saved_player_pose = bool(state.get("has_player_pose", false))
	saved_player_position = Vector2(float(state.get("player_x", 0.0)), float(state.get("player_y", 0.0)))
	saved_player_facing = int(state.get("player_facing", 2))
	objective_changed.emit(get_current_objective_id(), get_current_objective_text())
	return true

func save_to_file(path: String = "user://ashvale_save.json") -> Error:
	var tmp_path := path + ".tmp"
	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(capture_state(), "\t"))
	file.close()
	var abs_path := ProjectSettings.globalize_path(path)
	var abs_tmp := ProjectSettings.globalize_path(tmp_path)
	var abs_bak := abs_path + ".bak"
	if FileAccess.file_exists(path):
		if FileAccess.file_exists(path + ".bak"):
			DirAccess.remove_absolute(abs_bak)
		DirAccess.rename_absolute(abs_path, abs_bak)
	return DirAccess.rename_absolute(abs_tmp, abs_path)

static func _parse_save_dict(text: String) -> Variant:
	var json := JSON.new()
	if json.parse(text) != OK:
		return null
	if json.data is Dictionary:
		return json.data
	return null

func load_from_file(path: String = "user://ashvale_save.json") -> bool:
	for candidate in [path, path + ".bak"]:
		if FileAccess.file_exists(candidate):
			var text := FileAccess.get_file_as_string(candidate)
			var parsed: Variant = _parse_save_dict(text)
			if parsed is Dictionary and apply_state(parsed):
				return true
	return false

static func peek_save_summary(path: String = "user://ashvale_save.json") -> Dictionary:
	for candidate in [path, path + ".bak"]:
		if FileAccess.file_exists(candidate):
			var text := FileAccess.get_file_as_string(candidate)
			var parsed: Variant = _parse_save_dict(text)
			if not (parsed is Dictionary) or not parsed.has("version"):
				continue
			if typeof(parsed["version"]) not in [TYPE_INT, TYPE_FLOAT]:
				continue
			var ver: int = int(parsed["version"])
			if ver < 1 or ver > SAVE_VERSION:
				continue
			var q_path: String = String(parsed.get("quest_data_path", ""))
			if q_path == "" or not FileAccess.file_exists(q_path):
				continue
			if parsed.has("completed_objectives") and typeof(parsed["completed_objectives"]) != TYPE_DICTIONARY:
				continue
			if parsed.has("current_index") and (typeof(parsed["current_index"]) not in [TYPE_INT, TYPE_FLOAT] or int(parsed["current_index"]) < 0):
				continue
			return {
				"valid": true,
				"region_scene": String(parsed.get("region_scene", "res://scenes/sjt_exterior.tscn")),
				"quest_id": String(parsed.get("quest_id", "")),
				"source_file": candidate,
			}
	return {"valid": false}
