extends Node
## Data-driven chronological quest tracker supporting Prologue, Chapters 1-5, Epilogue, and atomic saves.

signal objective_changed(objective_id: String, objective_text: String)
signal objective_completed(objective_id: String)
signal quest_completed(quest_id: String)

const QUEST_DATA_PATH := "res://data/prologue_quest.json"
const CHAPTER3_DATA_PATH := "res://data/chapter3_quest.json"
const CHAPTER4_DATA_PATH := "res://data/chapter4_quest.json"
const CHAPTER5_DATA_PATH := "res://data/chapter5_quest.json"
const SAVE_VERSION := 5
const CREST_SYMBOLS: Array[String] = ["IRON SWORD", "SILVER BELL", "SUNDERED SHIELD", "CROWNED FLAME"]
const CELESTIAL_ALIGNMENTS: Array[String] = ["ECLIPSE SHADOW", "FIRST BEACON DAWN", "SECOND BEACON TIDE", "THIRD BEACON CROWN"]

static var pending_load_path: String = ""
static var pending_entry_pose: bool = false
static var pending_entry_position: Vector2 = Vector2.ZERO
static var pending_entry_facing: int = 2
static var pending_session_restore: bool = false
static var session_state: Dictionary = {}
static var carry_prologue_completed: bool = false
static var carry_chapter1_completed: bool = false
static var carry_chapter2_completed: bool = false
static var carry_chapter3_completed: bool = false
static var carry_chapter4_completed: bool = false
static var carry_storm_resolved: bool = false
static var carry_optional_discoveries: Dictionary = {}
static var pending_chapter5_snapshot: Dictionary = {}

const CUMULATIVE_BOOL_FLAGS := [
	"letter_found", "puzzle_solved", "briarwood_discovered", "prologue_completed", "briarwood_unlocked",
	"bridge_repaired", "mirror_puzzle_solved", "beacon_activated", "elena_echo_heard", "chapter1_completed", "floodmill_unlocked",
	"watermill_repaired", "sluice_solved", "ledger_reconstructed", "villagers_truth_discovered", "second_beacon_activated", "chapter2_elena_echo_heard", "chapter2_completed", "ironwatch_unlocked",
	"warden_records_found", "barracks_explored", "barracks_keepsake_found", "crest_puzzle_solved", "shadow_passage_cleared", "warden_confronted", "elena_research_found", "third_beacon_activated", "dawnspire_unlocked", "chapter3_completed",
	"cliffs_navigated", "skybridge_diagram_read", "skybridge_mechanism_discovered", "skybridge_repaired", "pilgrim_refuge_discovered", "elena_journal_read", "observatory_reached", "observatory_solved", "sanctuary_entered", "beacons_synchronized", "sanctuary_revelation_witnessed", "great_bell_gate_unlocked", "chapter4_completed",
	"chapter5_active", "chapter5_completed", "great_bell_chamber_entered", "lyra_antechamber_spoken", "forgotten_hall_investigated", "warden_record_revealed", "elena_final_message_heard", "memory_binding_examined", "protective_network_stabilized", "binding_severed", "last_bell_cinematic_seen", "storm_resolved", "dawn_terrace_returned", "epilogue_completed", "elena_journal_placed", "credits_viewed",
]

const CUMULATIVE_DICT_FIELDS := [
	"completed_objectives", "talked_npcs", "materials_collected", "inscriptions_read",
	"optional_discoveries", "mill_parts_collected", "archive_clues_found",
	"crest_clues_found", "skybridge_parts_collected", "celestial_clues_found",
	"memory_fragments_recovered", "beacon_conduits_activated",
]

var chapter_progress: Dictionary = {}

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

# Phase 5 (Chapter 4: The Road to Dawnspire) state
var celestial_solution: Array[String] = ["FIRST BEACON DAWN", "SECOND BEACON TIDE", "THIRD BEACON CROWN"]
var cliffs_navigated: bool = false
var cliff_checkpoint_id: String = "cliff_cp_0"
var cliff_checkpoint_pos: Vector2 = Vector2(30, 184)
var cliff_resets_count: int = 0
var skybridge_diagram_read: bool = false
var skybridge_parts_collected: Dictionary = {}
var skybridge_mechanism_discovered: bool = false
var skybridge_repaired: bool = false
var pilgrim_refuge_discovered: bool = false
var elena_journal_read: bool = false
var observatory_reached: bool = false
var celestial_clues_found: Dictionary = {}
var celestial_ring_states: Array[int] = [0, 0, 0]
var observatory_solved: bool = false
var sanctuary_entered: bool = false
var beacons_synchronized: bool = false
var sanctuary_revelation_witnessed: bool = false
var great_bell_gate_unlocked: bool = false
var chapter4_completed: bool = false

# Phase 6 (Chapter 5: The Last Bell & Epilogue) state
var chapter5_active: bool = false
var chapter5_completed: bool = false
var great_bell_chamber_entered: bool = false
var lyra_antechamber_spoken: bool = false
var forgotten_hall_investigated: bool = false
var memory_fragments_recovered: Dictionary = {}
var warden_record_revealed: bool = false
var elena_final_message_heard: bool = false
var memory_binding_examined: bool = false
var beacon_conduits_activated: Dictionary = {}
var protective_network_stabilized: bool = false
var binding_severed: bool = false
var last_bell_cinematic_seen: bool = false
var storm_resolved: bool = false
var dawn_terrace_returned: bool = false
var epilogue_completed: bool = false
var elena_journal_placed: bool = false
var credits_viewed: bool = false
var _chapter5_data_cache: Dictionary = {}

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
	var raw_celestial_sol: Variant = data.get("celestial_solution", ["FIRST BEACON DAWN", "SECOND BEACON TIDE", "THIRD BEACON CROWN"])
	if raw_celestial_sol is Array and raw_celestial_sol.size() == 3:
		celestial_solution = []
		for c_item in raw_celestial_sol:
			celestial_solution.append(String(c_item))

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
	cliffs_navigated = false
	cliff_checkpoint_id = "cliff_cp_0"
	cliff_checkpoint_pos = Vector2(30, 184)
	cliff_resets_count = 0
	skybridge_diagram_read = false
	skybridge_parts_collected.clear()
	skybridge_mechanism_discovered = false
	skybridge_repaired = false
	pilgrim_refuge_discovered = false
	elena_journal_read = false
	observatory_reached = false
	celestial_clues_found.clear()
	celestial_ring_states = [0, 0, 0]
	observatory_solved = false
	sanctuary_entered = false
	beacons_synchronized = false
	sanctuary_revelation_witnessed = false
	great_bell_gate_unlocked = false
	chapter4_completed = false
	chapter5_active = false
	chapter5_completed = false
	great_bell_chamber_entered = false
	lyra_antechamber_spoken = false
	forgotten_hall_investigated = false
	memory_fragments_recovered.clear()
	warden_record_revealed = false
	elena_final_message_heard = false
	memory_binding_examined = false
	beacon_conduits_activated.clear()
	protective_network_stabilized = false
	binding_severed = false
	last_bell_cinematic_seen = false
	storm_resolved = false
	dawn_terrace_returned = false
	epilogue_completed = false
	elena_journal_placed = false
	credits_viewed = false
	saved_region_scene = ""
	saved_player_position = Vector2.ZERO
	saved_player_facing = 2
	has_saved_player_pose = false
	chapter_progress.clear()
	load_quest_data(path)
	objective_changed.emit(get_current_objective_id(), get_current_objective_text())

static func reset_session_state() -> void:
	session_state.clear()
	pending_session_restore = false
	pending_load_path = ""
	pending_entry_pose = false
	pending_entry_position = Vector2.ZERO
	pending_entry_facing = 2
	carry_prologue_completed = false
	carry_chapter1_completed = false
	carry_chapter2_completed = false
	carry_chapter3_completed = false
	carry_chapter4_completed = false
	carry_storm_resolved = false
	carry_optional_discoveries.clear()
	pending_chapter5_snapshot.clear()

static func commit_state_to_session(qm: Node) -> void:
	if qm == null or not qm.has_method("capture_state"):
		return
	var snap: Dictionary = qm.capture_state()
	if session_state.is_empty():
		session_state = snap.duplicate(true)
	else:
		for bk: String in CUMULATIVE_BOOL_FLAGS:
			session_state[bk] = bool(session_state.get(bk, false)) or bool(snap.get(bk, false))
		for dk: String in CUMULATIVE_DICT_FIELDS:
			var merged: Dictionary = (session_state.get(dk, {}) as Dictionary).duplicate()
			var incoming: Variant = snap.get(dk, {})
			if incoming is Dictionary:
				for item_k in incoming.keys():
					merged[item_k] = incoming[item_k]
			session_state[dk] = merged
		var cp_merged: Dictionary = (session_state.get("chapter_progress", {}) as Dictionary).duplicate()
		var cp_inc: Variant = snap.get("chapter_progress", {})
		if cp_inc is Dictionary:
			for cpk in cp_inc.keys():
				cp_merged[cpk] = maxi(int(cp_merged.get(cpk, 0)), int(cp_inc[cpk]))
		var qid_now: String = String(snap.get("quest_id", ""))
		if qid_now != "":
			cp_merged[qid_now] = maxi(int(cp_merged.get(qid_now, 0)), int(snap.get("current_index", 0)))
		session_state["chapter_progress"] = cp_merged
		# Preserve active checkpoints and puzzle ring arrays when progressed/solved
		if bool(snap.get("sluice_solved", false)) or not bool(session_state.get("sluice_solved", false)):
			session_state["sluice_gate_states"] = (snap.get("sluice_gate_states", [0, 0, 0]) as Array).duplicate()
		if bool(snap.get("crest_puzzle_solved", false)) or not bool(session_state.get("crest_puzzle_solved", false)):
			session_state["crest_pillar_states"] = (snap.get("crest_pillar_states", [0, 0, 0]) as Array).duplicate()
		if bool(snap.get("observatory_solved", false)) or not bool(session_state.get("observatory_solved", false)):
			session_state["celestial_ring_states"] = (snap.get("celestial_ring_states", [0, 0, 0]) as Array).duplicate()
		if String(snap.get("quest_id", "")) == "chapter3_keepers_lie":
			session_state["stealth_checkpoint_id"] = snap.get("stealth_checkpoint_id", session_state.get("stealth_checkpoint_id", "checkpoint_0"))
			session_state["stealth_checkpoint_pos_x"] = snap.get("stealth_checkpoint_pos_x", session_state.get("stealth_checkpoint_pos_x", -150.0))
			session_state["stealth_checkpoint_pos_y"] = snap.get("stealth_checkpoint_pos_y", session_state.get("stealth_checkpoint_pos_y", -32.0))
			session_state["stealth_detections_count"] = maxi(int(session_state.get("stealth_detections_count", 0)), int(snap.get("stealth_detections_count", 0)))
		if String(snap.get("quest_id", "")) == "chapter4_road_to_dawnspire":
			session_state["cliff_checkpoint_id"] = snap.get("cliff_checkpoint_id", session_state.get("cliff_checkpoint_id", "cliff_cp_0"))
			session_state["cliff_checkpoint_pos_x"] = snap.get("cliff_checkpoint_pos_x", session_state.get("cliff_checkpoint_pos_x", 30.0))
			session_state["cliff_checkpoint_pos_y"] = snap.get("cliff_checkpoint_pos_y", session_state.get("cliff_checkpoint_pos_y", 184.0))
			session_state["cliff_resets_count"] = maxi(int(session_state.get("cliff_resets_count", 0)), int(snap.get("cliff_resets_count", 0)))
		session_state["version"] = SAVE_VERSION
	qm.set("chapter_progress", (session_state.get("chapter_progress", {}) as Dictionary).duplicate())

static func begin_region_travel(tree: SceneTree, current_qm: Node, target_scene: String, entry_pos: Vector2, entry_facing: int, use_entry_pose: bool = true) -> void:
	if current_qm != null:
		commit_state_to_session(current_qm)
	pending_session_restore = true
	pending_entry_pose = use_entry_pose
	pending_entry_position = entry_pos
	pending_entry_facing = entry_facing
	if tree != null:
		tree.change_scene_to_file(target_scene)

static func restore_into_region_quest(qm: Node, region_quest_path: String, region_quest_id: String, region_done_prop: String) -> bool:
	if qm == null or not pending_session_restore or session_state.is_empty():
		return false
	pending_session_restore = false
	var restored: Dictionary = session_state.duplicate(true)
	restored["quest_data_path"] = region_quest_path
	restored["quest_id"] = region_quest_id
	var cp_map: Dictionary = (restored.get("chapter_progress", {}) as Dictionary).duplicate()
	restored["current_index"] = int(cp_map.get(region_quest_id, 0))
	restored["has_player_pose"] = false
	qm.apply_state(restored, false)
	if bool(qm.get(region_done_prop)):
		qm.current_index = qm.objectives.size()
		qm.objective_changed.emit("completed", qm.get_current_objective_text())
	return true

func start_chapter5() -> bool:
	if not chapter4_completed and not carry_chapter4_completed:
		return false
	var preserved_opt: Dictionary = optional_discoveries.duplicate()
	for ok in carry_optional_discoveries.keys():
		preserved_opt[ok] = true
	carry_prologue_completed = true
	carry_chapter1_completed = true
	carry_chapter2_completed = true
	carry_chapter3_completed = true
	carry_chapter4_completed = true
	reload_quest(CHAPTER5_DATA_PATH)
	prologue_completed = true
	briarwood_unlocked = true
	chapter1_completed = true
	floodmill_unlocked = true
	beacon_activated = true
	chapter2_completed = true
	ironwatch_unlocked = true
	second_beacon_activated = true
	chapter3_completed = true
	dawnspire_unlocked = true
	third_beacon_activated = true
	chapter4_completed = true
	great_bell_gate_unlocked = true
	beacons_synchronized = true
	sanctuary_revelation_witnessed = true
	optional_discoveries = preserved_opt
	chapter5_active = true
	objective_changed.emit(get_current_objective_id(), get_current_objective_text())
	return true

func start_chapter4() -> void:
	carry_prologue_completed = true
	carry_chapter1_completed = true
	carry_chapter2_completed = true
	carry_chapter3_completed = true
	reload_quest(CHAPTER4_DATA_PATH)
	prologue_completed = true
	briarwood_unlocked = true
	chapter1_completed = true
	floodmill_unlocked = true
	beacon_activated = true
	chapter2_completed = true
	ironwatch_unlocked = true
	second_beacon_activated = true
	chapter3_completed = true
	dawnspire_unlocked = true
	third_beacon_activated = true
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
	if chapter5_completed or (storm_resolved and epilogue_completed):
		return "Chapter 5 Complete - Ashvale Remembered."

	if quest_id == "chapter5_the_last_bell":
		if chapter5_completed or current_index >= objectives.size():
			return "Chapter 5 Complete - Ashvale Remembered."
		var ch5_id: String = get_current_objective_id()
		if ch5_id == "recover_memory_fragments":
			return "Recover the three essential memory fragments (%d/3)." % get_recovered_memory_fragment_count()
		if ch5_id == "activate_beacon_conduits":
			return "Activate the three beacon conduits (%d/3)." % get_activated_beacon_conduit_count()
		return String(objectives[current_index].get("text", ""))

	if quest_id == "chapter4_road_to_dawnspire":
		if chapter4_completed or current_index >= objectives.size():
			return "Chapter 4 Complete - Great Bell Gate Unlocked."
		var ch4_id: String = get_current_objective_id()
		if ch4_id == "discover_bridge_mechanism":
			var diag_hint: String = "" if skybridge_diagram_read else " and inspect diagram"
			return "Gather Skybridge components (%d/3)%s." % [skybridge_parts_collected.size(), diag_hint]
		if ch4_id == "repair_skybridge" and skybridge_repaired:
			return "Cross the repaired Skybridge north."
		if ch4_id == "find_celestial_clues":
			return "Find the celestial alignment clues (%d/3)." % celestial_clues_found.size()
		return String(objectives[current_index].get("text", ""))

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
	match id:
		"chapter5_the_last_bell":
			return chapter5_completed
		"chapter4_road_to_dawnspire":
			return chapter4_completed
		"chapter3_keepers_lie":
			return chapter3_completed
		"chapter2_drowned_village":
			return chapter2_completed
		"chapter1_whispers_of_briarwood":
			return chapter1_completed
		"prologue_thirteenth_toll":
			return prologue_completed
	return false

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

func set_cliff_checkpoint(cp_id: String, cp_pos: Vector2) -> void:
	cliff_checkpoint_id = cp_id
	cliff_checkpoint_pos = cp_pos

func record_cliff_reset() -> void:
	cliff_resets_count += 1

func can_collect_skybridge_parts() -> bool:
	return get_current_objective_id() == "discover_bridge_mechanism"

func can_open_skybridge_repair() -> bool:
	return get_current_objective_id() == "repair_skybridge" and not skybridge_repaired and skybridge_parts_collected.size() >= 3 and skybridge_diagram_read

func mark_skybridge_repaired() -> void:
	if skybridge_repaired:
		return
	skybridge_repaired = true
	objective_changed.emit(get_current_objective_id(), get_current_objective_text())

func can_read_elena_journal() -> bool:
	return get_current_objective_id() == "read_elena_journal" and not elena_journal_read

func can_collect_celestial_clues() -> bool:
	return get_current_objective_id() == "find_celestial_clues"

func can_open_celestial_puzzle() -> bool:
	return get_current_objective_id() == "solve_observatory_puzzle" and not observatory_solved and celestial_clues_found.size() >= 3

func check_celestial_combination(rings: Array) -> bool:
	if rings.size() != celestial_solution.size():
		return false
	for i in range(celestial_solution.size()):
		if String(rings[i]).strip_edges().to_upper() != celestial_solution[i].strip_edges().to_upper():
			return false
	return true

func can_synchronize_beacons() -> bool:
	return get_current_objective_id() == "synchronize_three_beacons" and not beacons_synchronized

func can_witness_sanctuary_revelation() -> bool:
	return get_current_objective_id() == "witness_sanctuary_revelation" and not sanctuary_revelation_witnessed

func can_unlock_great_bell_gate() -> bool:
	return get_current_objective_id() == "reach_great_bell_gate" and not great_bell_gate_unlocked

func is_chapter5() -> bool:
	return quest_id == "chapter5_the_last_bell"

func get_recovered_memory_fragment_count() -> int:
	return memory_fragments_recovered.size()

func get_activated_beacon_conduit_count() -> int:
	return beacon_conduits_activated.size()

func enter_great_bell_chamber() -> bool:
	if get_current_objective_id() != "enter_great_bell_chamber":
		return false
	great_bell_chamber_entered = true
	return complete_objective("enter_great_bell_chamber")

func speak_lyra_antechamber() -> bool:
	if get_current_objective_id() != "speak_lyra_antechamber":
		return false
	lyra_antechamber_spoken = true
	return complete_objective("speak_lyra_antechamber")

func investigate_forgotten_hall() -> bool:
	if get_current_objective_id() != "investigate_forgotten_hall":
		return false
	forgotten_hall_investigated = true
	return complete_objective("investigate_forgotten_hall")

func recover_memory_fragment(frag_id: String) -> bool:
	if get_current_objective_id() != "recover_memory_fragments":
		return false
	if frag_id not in ["frag_home", "frag_promise", "frag_sacrifice"]:
		return false
	if memory_fragments_recovered.has(frag_id):
		return false
	memory_fragments_recovered[frag_id] = true
	if get_recovered_memory_fragment_count() >= 3:
		return complete_objective("recover_memory_fragments")
	objective_changed.emit("recover_memory_fragments", get_current_objective_text())
	return true

func reveal_warden_complete_record() -> bool:
	if get_current_objective_id() != "reveal_warden_record" or get_recovered_memory_fragment_count() < 3:
		return false
	warden_record_revealed = true
	return complete_objective("reveal_warden_record")

func discover_elena_final_message() -> bool:
	if get_current_objective_id() != "discover_elena_final_message" or not warden_record_revealed:
		return false
	elena_final_message_heard = true
	return complete_objective("discover_elena_final_message")

func examine_memory_binding() -> bool:
	if get_current_objective_id() != "examine_memory_binding" or not elena_final_message_heard:
		return false
	memory_binding_examined = true
	return complete_objective("examine_memory_binding")

func activate_beacon_conduit(conduit_id: String) -> bool:
	if get_current_objective_id() != "activate_beacon_conduits" or not memory_binding_examined:
		return false
	if conduit_id not in ["conduit_briarwood", "conduit_floodmill", "conduit_ironwatch"]:
		return false
	if beacon_conduits_activated.has(conduit_id):
		return false
	beacon_conduits_activated[conduit_id] = true
	if get_activated_beacon_conduit_count() >= 3:
		return complete_objective("activate_beacon_conduits")
	objective_changed.emit("activate_beacon_conduits", get_current_objective_text())
	return true

func can_stabilize_protective_network() -> bool:
	return get_current_objective_id() == "stabilize_protective_network" and get_activated_beacon_conduit_count() >= 3 and not protective_network_stabilized

func stabilize_protective_network() -> bool:
	if not can_stabilize_protective_network():
		return false
	protective_network_stabilized = true
	return complete_objective("stabilize_protective_network")

func can_sever_memory_binding() -> bool:
	return get_current_objective_id() == "sever_memory_binding" and protective_network_stabilized and not binding_severed

func sever_memory_binding() -> bool:
	if not can_sever_memory_binding():
		return false
	binding_severed = true
	storm_resolved = true
	return complete_objective("sever_memory_binding")

func complete_last_bell_cinematic() -> bool:
	if get_current_objective_id() != "witness_last_bell_cinematic" or not binding_severed:
		return false
	last_bell_cinematic_seen = true
	storm_resolved = true
	return complete_objective("witness_last_bell_cinematic")

func return_to_dawn_terrace() -> bool:
	if get_current_objective_id() != "return_to_dawn_terrace" or not last_bell_cinematic_seen:
		return false
	dawn_terrace_returned = true
	return complete_objective("return_to_dawn_terrace")

func complete_final_epilogue() -> bool:
	if get_current_objective_id() != "complete_final_epilogue" or not dawn_terrace_returned:
		return false
	epilogue_completed = true
	elena_journal_placed = true
	return complete_objective("complete_final_epilogue")

func complete_ending_credits() -> bool:
	if get_current_objective_id() != "display_ending_credits" or not epilogue_completed:
		return false
	return complete_objective("display_ending_credits")

func _ensure_chapter5_cache() -> Dictionary:
	if _chapter5_data_cache.is_empty():
		var file := FileAccess.open(CHAPTER5_DATA_PATH, FileAccess.READ)
		if file != null:
			var parsed: Variant = JSON.parse_string(file.get_as_text())
			file.close()
			if parsed is Dictionary:
				_chapter5_data_cache = parsed
	return _chapter5_data_cache

func get_chapter5_npc_lines(npc_key: String) -> Array[String]:
	var d: Dictionary = _ensure_chapter5_cache()
	var npcs: Dictionary = d.get("npcs", {})
	var raw: Variant = npcs.get(npc_key, [])
	var out: Array[String] = []
	if raw is Array:
		for item in raw:
			out.append(String(item))
	return out

func get_optional_discovery_summary() -> Array[String]:
	var notes: Array[String] = []
	if optional_discoveries.has("ruined_camp_relic"):
		notes.append("Elena's Briarwood Survey Compass rests beside her journal beneath the memorial.")
	if optional_discoveries.has("homestead_locket"):
		notes.append("A Floodmill silver locket bears the restored names of thirty-six remembered hearths.")
	if optional_discoveries.has("wardens_locket") or barracks_keepsake_found:
		notes.append("An Ironwatch sentry keepsake records the duty of watchers who wished never to forget.")
	if optional_discoveries.has("dawnspire_pilgrim_letter") or optional_discoveries.has("dawnspire_memorial"):
		notes.append("Names carried by Dawnspire's mountain pilgrims stand freshly engraved in limestone.")
	return notes

func complete_objective(id: String) -> bool:
	var active_quest_done: bool = chapter5_completed if quest_id == "chapter5_the_last_bell" else (chapter4_completed if quest_id == "chapter4_road_to_dawnspire" else (chapter3_completed if quest_id == "chapter3_keepers_lie" else (chapter2_completed if quest_id == "chapter2_drowned_village" else (chapter1_completed if quest_id == "chapter1_whispers_of_briarwood" else prologue_completed))))
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
		"navigate_whispering_cliffs":
			cliffs_navigated = true
		"discover_bridge_mechanism":
			skybridge_mechanism_discovered = true
		"repair_skybridge":
			skybridge_repaired = true
		"discover_pilgrims_refuge":
			pilgrim_refuge_discovered = true
		"read_elena_journal":
			elena_journal_read = true
		"reach_observatory":
			observatory_reached = true
		"solve_observatory_puzzle":
			observatory_solved = true
		"enter_dawnspire_sanctuary":
			sanctuary_entered = true
		"synchronize_three_beacons":
			beacons_synchronized = true
		"witness_sanctuary_revelation":
			sanctuary_revelation_witnessed = true
		"reach_great_bell_gate":
			great_bell_gate_unlocked = true
		"enter_great_bell_chamber":
			great_bell_chamber_entered = true
		"speak_lyra_antechamber":
			lyra_antechamber_spoken = true
		"investigate_forgotten_hall":
			forgotten_hall_investigated = true
		"reveal_warden_record":
			warden_record_revealed = true
		"discover_elena_final_message":
			elena_final_message_heard = true
		"examine_memory_binding":
			memory_binding_examined = true
		"stabilize_protective_network":
			protective_network_stabilized = true
		"sever_memory_binding":
			binding_severed = true
			storm_resolved = true
		"witness_last_bell_cinematic":
			last_bell_cinematic_seen = true
			storm_resolved = true
		"return_to_dawn_terrace":
			dawn_terrace_returned = true
		"complete_final_epilogue":
			epilogue_completed = true
			elena_journal_placed = true
		"display_ending_credits":
			credits_viewed = true
			chapter5_completed = true
	current_index += 1
	var reached_end: bool = (current_index >= objectives.size())
	if reached_end:
		if quest_id == "chapter5_the_last_bell":
			chapter5_completed = true
			credits_viewed = true
		elif quest_id == "chapter4_road_to_dawnspire":
			chapter4_completed = true
			great_bell_gate_unlocked = true
		elif quest_id == "chapter3_keepers_lie":
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

func record_skybridge_part_collected(part_id: String) -> bool:
	if get_current_objective_id() != "discover_bridge_mechanism":
		return false
	if skybridge_parts_collected.has(part_id):
		return false
	skybridge_parts_collected[part_id] = true
	if skybridge_parts_collected.size() >= 3 and skybridge_diagram_read:
		return complete_objective("discover_bridge_mechanism")
	objective_changed.emit("discover_bridge_mechanism", get_current_objective_text())
	return true

func record_skybridge_diagram_read() -> bool:
	skybridge_diagram_read = true
	if get_current_objective_id() == "discover_bridge_mechanism":
		if skybridge_parts_collected.size() >= 3:
			return complete_objective("discover_bridge_mechanism")
		objective_changed.emit("discover_bridge_mechanism", get_current_objective_text())
	return true

func record_celestial_clue_found(clue_id: String) -> bool:
	if get_current_objective_id() != "find_celestial_clues":
		return false
	if celestial_clues_found.has(clue_id):
		return false
	celestial_clues_found[clue_id] = true
	if celestial_clues_found.size() >= 3:
		return complete_objective("find_celestial_clues")
	objective_changed.emit("find_celestial_clues", get_current_objective_text())
	return true

func get_npc_dialogue(npc_id: String) -> Array[String]:
	if (storm_resolved or chapter5_completed) and npc_id in ["caelen", "mira", "elara", "lyra_bellhaven"]:
		var key: String = "bellhaven_lyra" if npc_id == "lyra_bellhaven" else "bellhaven_" + npc_id
		var dawn_lines: Array[String] = get_chapter5_npc_lines(key)
		if not dawn_lines.is_empty():
			return dawn_lines
	var npcs: Dictionary = data.get("npcs", {})
	var entry: Dictionary = npcs.get(npc_id, {})
	var stage_key := "investigation"
	if quest_id == "chapter5_the_last_bell":
		stage_key = get_current_objective_id()
		if not entry.has(stage_key):
			stage_key = "default"
	elif quest_id == "chapter4_road_to_dawnspire":
		stage_key = get_current_objective_id()
		if not entry.has(stage_key):
			stage_key = "default"
	elif quest_id == "chapter3_keepers_lie":
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
	if quest_id == "chapter5_the_last_bell":
		region_scene = "res://scenes/great_bell_sanctum.tscn"
	elif quest_id == "chapter4_road_to_dawnspire":
		region_scene = "res://scenes/dawnspire_mountain.tscn"
	elif quest_id == "chapter3_keepers_lie":
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
	chapter_progress[quest_id] = maxi(int(chapter_progress.get(quest_id, 0)), current_index)
	return {
		"version": SAVE_VERSION,
		"quest_id": quest_id,
		"quest_data_path": quest_data_path,
		"chapter_progress": chapter_progress.duplicate(),
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
		"cliffs_navigated": cliffs_navigated,
		"cliff_checkpoint_id": cliff_checkpoint_id,
		"cliff_checkpoint_pos_x": cliff_checkpoint_pos.x,
		"cliff_checkpoint_pos_y": cliff_checkpoint_pos.y,
		"cliff_resets_count": cliff_resets_count,
		"skybridge_diagram_read": skybridge_diagram_read,
		"skybridge_parts_collected": skybridge_parts_collected.duplicate(),
		"skybridge_mechanism_discovered": skybridge_mechanism_discovered,
		"skybridge_repaired": skybridge_repaired,
		"pilgrim_refuge_discovered": pilgrim_refuge_discovered,
		"elena_journal_read": elena_journal_read,
		"observatory_reached": observatory_reached,
		"celestial_clues_found": celestial_clues_found.duplicate(),
		"celestial_ring_states": celestial_ring_states.duplicate(),
		"observatory_solved": observatory_solved,
		"sanctuary_entered": sanctuary_entered,
		"beacons_synchronized": beacons_synchronized,
		"sanctuary_revelation_witnessed": sanctuary_revelation_witnessed,
		"great_bell_gate_unlocked": great_bell_gate_unlocked,
		"chapter4_completed": chapter4_completed,
		"chapter5_active": chapter5_active,
		"chapter5_completed": chapter5_completed,
		"great_bell_chamber_entered": great_bell_chamber_entered,
		"lyra_antechamber_spoken": lyra_antechamber_spoken,
		"forgotten_hall_investigated": forgotten_hall_investigated,
		"memory_fragments_recovered": memory_fragments_recovered.duplicate(),
		"warden_record_revealed": warden_record_revealed,
		"elena_final_message_heard": elena_final_message_heard,
		"memory_binding_examined": memory_binding_examined,
		"beacon_conduits_activated": beacon_conduits_activated.duplicate(),
		"protective_network_stabilized": protective_network_stabilized,
		"binding_severed": binding_severed,
		"last_bell_cinematic_seen": last_bell_cinematic_seen,
		"storm_resolved": storm_resolved,
		"dawn_terrace_returned": dawn_terrace_returned,
		"epilogue_completed": epilogue_completed,
		"elena_journal_placed": elena_journal_placed,
		"credits_viewed": credits_viewed,
	}

func apply_state(state: Dictionary, sync_session: bool = true) -> bool:
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
	var raw_cp: Variant = state.get("chapter_progress", {})
	chapter_progress = raw_cp.duplicate() if raw_cp is Dictionary else {}
	chapter_progress[quest_id] = maxi(int(chapter_progress.get(quest_id, 0)), current_index)
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

	# Phase 5 fields (safely defaulted when migrating v1/v2/v3 saves)
	cliffs_navigated = bool(state.get("cliffs_navigated", false))
	cliff_checkpoint_id = String(state.get("cliff_checkpoint_id", "cliff_cp_0"))
	cliff_checkpoint_pos = Vector2(
		float(state.get("cliff_checkpoint_pos_x", 30.0)),
		float(state.get("cliff_checkpoint_pos_y", 184.0))
	)
	cliff_resets_count = int(state.get("cliff_resets_count", 0))
	skybridge_diagram_read = bool(state.get("skybridge_diagram_read", false))
	var raw_sb_parts: Variant = state.get("skybridge_parts_collected", {})
	skybridge_parts_collected = raw_sb_parts.duplicate() if raw_sb_parts is Dictionary else {}
	skybridge_mechanism_discovered = bool(state.get("skybridge_mechanism_discovered", false))
	skybridge_repaired = bool(state.get("skybridge_repaired", false))
	pilgrim_refuge_discovered = bool(state.get("pilgrim_refuge_discovered", false))
	elena_journal_read = bool(state.get("elena_journal_read", false))
	observatory_reached = bool(state.get("observatory_reached", false))
	var raw_cel_clues: Variant = state.get("celestial_clues_found", {})
	celestial_clues_found = {}
	if raw_cel_clues is Dictionary:
		celestial_clues_found = raw_cel_clues.duplicate()
	elif raw_cel_clues is Array:
		for cc in raw_cel_clues:
			celestial_clues_found[String(cc)] = true
	var raw_cel_rings: Variant = state.get("celestial_ring_states", [0, 0, 0])
	celestial_ring_states = [0, 0, 0]
	if raw_cel_rings is Array and raw_cel_rings.size() == 3:
		for ri in range(3):
			celestial_ring_states[ri] = clampi(int(raw_cel_rings[ri]), 0, 3)
	observatory_solved = bool(state.get("observatory_solved", false))
	sanctuary_entered = bool(state.get("sanctuary_entered", false))
	beacons_synchronized = bool(state.get("beacons_synchronized", false))
	sanctuary_revelation_witnessed = bool(state.get("sanctuary_revelation_witnessed", false))
	great_bell_gate_unlocked = bool(state.get("great_bell_gate_unlocked", false))
	chapter4_completed = bool(state.get("chapter4_completed", false))

	# Phase 6 fields (safely defaulted when migrating v1/v2/v3/v4 saves)
	chapter5_active = bool(state.get("chapter5_active", false))
	chapter5_completed = bool(state.get("chapter5_completed", false))
	great_bell_chamber_entered = bool(state.get("great_bell_chamber_entered", false))
	lyra_antechamber_spoken = bool(state.get("lyra_antechamber_spoken", false))
	forgotten_hall_investigated = bool(state.get("forgotten_hall_investigated", false))
	var raw_mem_frags: Variant = state.get("memory_fragments_recovered", {})
	memory_fragments_recovered = raw_mem_frags.duplicate() if raw_mem_frags is Dictionary else {}
	warden_record_revealed = bool(state.get("warden_record_revealed", false))
	elena_final_message_heard = bool(state.get("elena_final_message_heard", false))
	memory_binding_examined = bool(state.get("memory_binding_examined", false))
	var raw_conduits: Variant = state.get("beacon_conduits_activated", {})
	beacon_conduits_activated = raw_conduits.duplicate() if raw_conduits is Dictionary else {}
	protective_network_stabilized = bool(state.get("protective_network_stabilized", false))
	binding_severed = bool(state.get("binding_severed", false))
	last_bell_cinematic_seen = bool(state.get("last_bell_cinematic_seen", false))
	storm_resolved = bool(state.get("storm_resolved", false))
	dawn_terrace_returned = bool(state.get("dawn_terrace_returned", false))
	epilogue_completed = bool(state.get("epilogue_completed", false))
	elena_journal_placed = bool(state.get("elena_journal_placed", false))
	credits_viewed = bool(state.get("credits_viewed", false))

	var restored_region: String = String(state.get("region_scene", ""))
	var restored_has_pose: bool = bool(state.get("has_player_pose", false))
	var restored_pos := Vector2(float(state.get("player_x", 0.0)), float(state.get("player_y", 0.0)))
	var restored_facing: int = int(state.get("player_facing", 2))
	saved_region_scene = restored_region
	has_saved_player_pose = restored_has_pose
	saved_player_position = restored_pos
	saved_player_facing = restored_facing
	if sync_session and is_inside_tree():
		session_state.clear()
		commit_state_to_session(self)
		# Restore saved pose fields loaded from state so apply_saved_state reads the file's pose, not pre-load player coordinates
		saved_region_scene = restored_region
		has_saved_player_pose = restored_has_pose
		saved_player_position = restored_pos
		saved_player_facing = restored_facing
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
