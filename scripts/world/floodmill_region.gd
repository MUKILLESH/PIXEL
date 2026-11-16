extends Node2D
## Main Chapter 2 scene controller populating Floodmill: The Drowned Village subregions,
## mechanical Watermill, Sluice Canal barriers, Forgotten Archive, Lyra, and Second Beacon.

const BuildingScript = preload("res://scripts/world/floodmill_building.gd")
const PropScript = preload("res://scripts/world/floodmill_prop.gd")
const InteractableScript = preload("res://scripts/interactables/floodmill_interactable.gd")
const NpcScene = preload("res://scenes/characters/npc.tscn")
const QuestManagerScript = preload("res://scripts/systems/quest_manager.gd")
const AudioManagerScript = preload("res://scripts/systems/audio_manager.gd")

var quest_manager: Node
var lyra: StaticBody2D
var archive_blocker_shape: CollisionShape2D

var old_watermill_building: StaticBody2D
var entrance_arch: StaticBody2D
var village_monument: StaticBody2D
var homestead_relic: StaticBody2D
var broken_watermill: StaticBody2D
var sluice_console: StaticBody2D
var archive_entrance: StaticBody2D
var ledger_table: StaticBody2D
var second_beacon: StaticBody2D
var ironwatch_gate: StaticBody2D
var mill_parts: Dictionary = {}
var archive_records: Dictionary = {}

func _ready() -> void:
	# Generate full wetland ground tiles covering camera boundaries (-38..38)
	var ground: TileMapLayer = $Ground
	for x in range(-38, 39):
		for y in range(-38, 39):
			ground.set_cell(Vector2i(x, y), 0, Vector2i(posmod(x * 11 + y * 17, 3), 0))

	# 2.5D Isometric Buildings across Abandoned Village, Lockhouse, Watermill, and Archive
	var buildings := [
		[0, "MillerCottage", Vector2(-152, 74)],
		[1, "RuinedHomestead", Vector2(56, 178)],
		[2, "CanalLockhouse", Vector2(-216, -16)],
		[3, "OldWatermill", Vector2(174, 44)],
		[4, "ArchiveHall", Vector2(-134, -76)],
	]
	for b in buildings:
		var node := StaticBody2D.new()
		node.set_script(BuildingScript)
		node.name = b[1]
		node.kind = b[0]
		node.position = b[2]
		$Actors.add_child(node)
		if b[0] == 3:
			old_watermill_building = node

	# Atmospheric props and ruins keeping all walkways and spots clear
	var props := [
		[0, Vector2(-242, 168)], [0, Vector2(-192, 128)], [0, Vector2(-250, -64)],
		[0, Vector2(246, -140)], [0, Vector2(242, 152)], [0, Vector2(-202, -214)],
		[0, Vector2(0, -244)], [0, Vector2(-134, 234)], [0, Vector2(-26, 206)], [0, Vector2(120, 202)],
		[1, Vector2(-180, 154)], [1, Vector2(48, -96)], [1, Vector2(116, -138)],
		[2, Vector2(-108, 22)], [2, Vector2(18, 148)], [2, Vector2(94, 146)],
		[3, Vector2(136, 118)], [3, Vector2(202, 128)], [3, Vector2(-188, 96)],
		[4, Vector2(-164, 168)], [4, Vector2(-118, 118)], [4, Vector2(-100, -56)], [4, Vector2(94, -184)],
		[5, Vector2(-210, 48)], [5, Vector2(-14, -10)], [5, Vector2(108, -14)], [5, Vector2(198, -14)],
		[5, Vector2(-88, -56)], [5, Vector2(38, -56)], [5, Vector2(192, 124)],
		[6, Vector2(-74, 108)], [6, Vector2(-4, 62)], [6, Vector2(142, 118)],
	]
	for p in props:
		var node := StaticBody2D.new()
		node.set_script(PropScript)
		node.kind = p[0]
		node.position = p[1]
		$Actors.add_child(node)

	# East-West Sluice Canal & Drainable Archive Causeway barrier
	_build_canal_barriers()

	# Traveling Historian Lyra NPC
	lyra = NpcScene.instantiate() as StaticBody2D
	lyra.name = "Lyra"
	lyra.npc_id = "lyra"
	lyra.speaker_name = "HISTORIAN LYRA"
	lyra.prompt_text = "[E] TALK TO LYRA"
	lyra.position = Vector2(-128, 184)
	lyra.facing = 4
	$Actors.add_child(lyra)

	# Interactive Landmarks, Components, Clues, Minigame Stations, and Sanctuary
	entrance_arch = _spawn_interactable(
		"FloodmillEntranceArch", "entrance_arch", "", "FLOODMILL ENTRANCE",
		"[E] SURVEY DROWNED VILLAGE", Vector2(-212, 212), 10, ""
	)
	village_monument = _spawn_interactable(
		"VillageMonument", "village_plaque", "", "FLOODMILL CENSUS STONE",
		"[E] INSPECT CENSUS STONE", Vector2(-56, 92), 10, ""
	)
	homestead_relic = _spawn_interactable(
		"HomesteadRelic", "optional_lore", "homestead_locket", "WEAVER'S HOMESTEAD",
		"[E] INSPECT SILVER LOCKET", Vector2(44, 122), 10, ""
	)
	broken_watermill = _spawn_interactable(
		"BrokenWatermill", "watermill_mechanism", "", "OLD WATERMILL",
		"[E] INSPECT WATERMILL", Vector2(158, 58), 10, ""
	)
	_spawn_interactable(
		"MillDiagram", "mill_diagram", "", "MILLWRIGHT DIAGRAM",
		"[E] READ MILL DIAGRAM", Vector2(108, 44), 10, ""
	)
	mill_parts["iron_drive_gear"] = _spawn_interactable(
		"MillPartGear", "mill_part", "iron_drive_gear", "IRON DRIVE GEAR",
		"[E] TAKE IRON DRIVE GEAR", Vector2(66, 98), 10,
		"Recovered the heavy forged Iron Drive Gear beside the sunken village cart."
	)
	mill_parts["bronze_pinion"] = _spawn_interactable(
		"MillPartPinion", "mill_part", "bronze_pinion", "BRONZE PINION",
		"[E] TAKE BRONZE PINION", Vector2(194, 96), 10,
		"Took a finely toothed Bronze Pinion resting dry atop the millpond barrels."
	)
	mill_parts["oak_coupling_belt"] = _spawn_interactable(
		"MillPartBelt", "mill_part", "oak_coupling_belt", "OAK COUPLING BELT",
		"[E] TAKE OAK COUPLING BELT", Vector2(10, 68), 10,
		"Collected a tar-sealed Oak Coupling Belt from the village square fence post."
	)
	sluice_console = _spawn_interactable(
		"SluiceConsole", "sluice_console", "", "CANAL SLUICE CONSOLE",
		"[E] INSPECT SLUICE CONSOLE", Vector2(36, 4), 10, ""
	)
	_spawn_interactable(
		"CanalGauge", "canal_clue", "", "CANAL DEPTH GAUGE",
		"[E] READ DEPTH GAUGE", Vector2(-22, 10), 10, ""
	)
	archive_entrance = _spawn_interactable(
		"ArchiveEntrance", "archive_entrance", "", "FORGOTTEN ARCHIVE",
		"[E] ENTER FORGOTTEN ARCHIVE", Vector2(-100, -82), 10, ""
	)
	archive_records["record_census"] = _spawn_interactable(
		"ArchiveRecordCensus", "archive_record", "record_census", "TORN PARISH ROLL",
		"[E] READ PARISH ROLL", Vector2(-172, -112), 10, ""
	)
	archive_records["record_tribute"] = _spawn_interactable(
		"ArchiveRecordTribute", "archive_record", "record_tribute", "ASH-STAINED DECREE",
		"[E] READ BELLHAVEN DECREE", Vector2(-134, -134), 10, ""
	)
	archive_records["record_transfer"] = _spawn_interactable(
		"ArchiveRecordTransfer", "archive_record", "record_transfer", "LOCKBOX RECEIPT",
		"[E] READ VAULT RECEIPT", Vector2(-94, -112), 10, ""
	)
	ledger_table = _spawn_interactable(
		"LedgerTable", "ledger_table", "", "MASTER VILLAGE LEDGER",
		"[E] RECONSTRUCT VILLAGE LEDGER", Vector2(-134, -106), 10, ""
	)
	second_beacon = _spawn_interactable(
		"SecondBeacon", "second_beacon", "", "SECOND ANCIENT BEACON",
		"[E] APPROACH SECOND BEACON", Vector2(64, -208), 11, ""
	)
	ironwatch_gate = _spawn_interactable(
		"IronwatchGate", "ironwatch_gate", "", "IRONWATCH KEEP GATE",
		"[E] INSPECT IRONWATCH GATE", Vector2(186, -196), 9, ""
	)

	# World perimeter diamond boundary
	var corners := PackedVector2Array([Vector2(0, -400), Vector2(780, 0), Vector2(0, 400), Vector2(-780, 0)])
	for i in range(4):
		var edge := StaticBody2D.new()
		var col := CollisionShape2D.new()
		var seg := SegmentShape2D.new()
		seg.a = corners[i]
		seg.b = corners[(i + 1) % 4]
		col.shape = seg
		edge.add_child(col)
		$Boundary.add_child(edge)

	# Chapter 2 QuestManager & HUD setup
	quest_manager = QuestManagerScript.new()
	quest_manager.name = "QuestManager"
	quest_manager.quest_data_path = "res://data/chapter2_quest.json"
	add_child(quest_manager)
	quest_manager.objective_completed.connect(_on_objective_completed)

	$HUD.player = $Actors/Player
	$HUD.terminal = entrance_arch
	$HUD.bind_quest_manager(quest_manager)
	$HUD/Subtitle.text = "FLOODMILL - THE DROWNED VILLAGE"
	$HUD/Clock.text = "CHAPTER 2"
	$Actors/Player.facing = 0
	$Actors/Player/Camera2D.framing = Vector2(0, -48)
	$Actors/Player/Camera2D.snap_to_target()

	if QuestManagerScript.carry_prologue_completed:
		quest_manager.prologue_completed = true
		quest_manager.briarwood_unlocked = true
		quest_manager.letter_found = true
		quest_manager.puzzle_solved = true
		quest_manager.talked_npcs = {"caelen": true, "mira": true, "elara": true}
		QuestManagerScript.carry_prologue_completed = false
	if QuestManagerScript.carry_chapter1_completed:
		quest_manager.chapter1_completed = true
		quest_manager.floodmill_unlocked = true
		quest_manager.bridge_repaired = true
		quest_manager.mirror_puzzle_solved = true
		quest_manager.beacon_activated = true
		quest_manager.elena_echo_heard = true
		quest_manager.materials_collected = {"plank_1": true, "plank_2": true, "rope_coil": true}
		quest_manager.inscriptions_read = {"west": true, "center": true, "east": true}
		QuestManagerScript.carry_chapter1_completed = false
	if not QuestManagerScript.carry_optional_discoveries.is_empty():
		for k in QuestManagerScript.carry_optional_discoveries.keys():
			quest_manager.optional_discoveries[k] = true
		QuestManagerScript.carry_optional_discoveries.clear()

	if QuestManagerScript.pending_load_path != "":
		var load_p: String = QuestManagerScript.pending_load_path
		QuestManagerScript.pending_load_path = ""
		apply_saved_state(load_p)
	else:
		if QuestManagerScript.pending_entry_pose:
			QuestManagerScript.pending_entry_pose = false
			$Actors/Player.position = QuestManagerScript.pending_entry_position
			$Actors/Player.facing = QuestManagerScript.pending_entry_facing
			$Actors/Player/Camera2D.snap_to_target()
		_sync_world_from_quest()
	$Landscape.queue_redraw()
	AudioManagerScript.play_global_region(get_tree(), "floodmill")
	$HUD.play_region_transition("FLOODMILL WETLANDS", "CHAPTER 2 - THE DROWNED VILLAGE")

func _spawn_interactable(node_name: String, kind_name: String, item_key: String, speaker: String, prompt: String, pos: Vector2, prio: int, msg: String) -> StaticBody2D:
	var obj := StaticBody2D.new()
	obj.set_script(InteractableScript)
	obj.name = node_name
	obj.kind = kind_name
	obj.item_id = item_key
	obj.speaker_name = speaker
	obj.prompt_text = prompt
	obj.position = pos
	obj.interaction_priority = prio
	obj.message = msg
	$Actors.add_child(obj)
	return obj

func _build_canal_barriers() -> void:
	var canal := StaticBody2D.new()
	canal.name = "CanalBarrier"
	canal.collision_layer = 1
	canal.collision_mask = 2
	var west_shape := CollisionShape2D.new()
	var w_rect := RectangleShape2D.new()
	w_rect.size = Vector2(422, 26)
	west_shape.shape = w_rect
	west_shape.position = Vector2(-309, -32)
	canal.add_child(west_shape)
	var east_shape := CollisionShape2D.new()
	var e_rect := RectangleShape2D.new()
	e_rect.size = Vector2(520, 26)
	east_shape.shape = e_rect
	east_shape.position = Vector2(230, -32)
	canal.add_child(east_shape)
	add_child(canal)

	var blocker := StaticBody2D.new()
	blocker.name = "ArchiveFloodBlocker"
	blocker.collision_layer = 1
	blocker.collision_mask = 2
	archive_blocker_shape = CollisionShape2D.new()
	archive_blocker_shape.name = "Shape"
	var b_rect := RectangleShape2D.new()
	b_rect.size = Vector2(68, 26)
	archive_blocker_shape.shape = b_rect
	archive_blocker_shape.position = Vector2(-64, -32)
	blocker.add_child(archive_blocker_shape)
	add_child(blocker)

func _on_objective_completed(_objective_id: String) -> void:
	_sync_world_from_quest()

func _sync_world_from_quest() -> void:
	if quest_manager == null:
		return
	for p_key in mill_parts.keys():
		var p_node: StaticBody2D = mill_parts[p_key]
		p_node.collected = quest_manager.mill_parts_collected.has(p_key)
		p_node.queue_redraw()
	for r_key in archive_records.keys():
		var r_node: StaticBody2D = archive_records[r_key]
		r_node.collected = quest_manager.archive_clues_found.has(r_key)
		r_node.queue_redraw()
	if village_monument != null:
		village_monument.inspected = quest_manager.is_objective_completed("explore_ruined_village")
		village_monument.queue_redraw()
	if homestead_relic != null:
		homestead_relic.collected = quest_manager.optional_discoveries.has("homestead_locket")
		homestead_relic.queue_redraw()

	var mill_ok: bool = quest_manager.watermill_repaired
	if broken_watermill != null:
		broken_watermill.repaired = mill_ok
		broken_watermill.refresh_prompt("[E] INSPECT RUNNING WATERMILL" if mill_ok else ("[E] REPAIR WATERMILL GEARS" if quest_manager.can_open_watermill_repair() else "[E] INSPECT WATERMILL"))
		broken_watermill.queue_redraw()
	if old_watermill_building != null:
		old_watermill_building.set_watermill_active(mill_ok)
	$Landscape.watermill_repaired = mill_ok
	var mill_panel := get_node_or_null("HUD/WatermillRepair")
	if mill_panel != null:
		mill_panel.set("repaired", mill_ok)

	var sluice_ok: bool = quest_manager.sluice_solved
	if archive_blocker_shape != null:
		archive_blocker_shape.set_deferred("disabled", sluice_ok)
		archive_blocker_shape.disabled = sluice_ok
	if sluice_console != null:
		sluice_console.unlocked = sluice_ok
		sluice_console.refresh_prompt("[E] INSPECT DRAINED SLUICES" if sluice_ok else ("[E] ADJUST SLUICE GATES" if quest_manager.can_open_sluice_puzzle() else "[E] INSPECT SLUICE CONSOLE"))
		sluice_console.queue_redraw()
	$Landscape.sluice_gate_states = quest_manager.sluice_gate_states.duplicate()
	$Landscape.sluice_solved = sluice_ok
	var sluice_panel := get_node_or_null("HUD/SluicePuzzle")
	if sluice_panel != null:
		sluice_panel.set("solved", sluice_ok)
		sluice_panel.set("states", quest_manager.sluice_gate_states.duplicate())

	var ledger_ok: bool = quest_manager.ledger_reconstructed
	var truth_ok: bool = quest_manager.villagers_truth_discovered
	if ledger_table != null:
		ledger_table.activated = ledger_ok
		if truth_ok:
			ledger_table.refresh_prompt("[E] READ BOUND VILLAGE LEDGER")
		elif ledger_ok:
			ledger_table.refresh_prompt("[E] READ RESTORED LEDGER")
		elif quest_manager.can_open_ledger_puzzle():
			ledger_table.refresh_prompt("[E] RECONSTRUCT VILLAGE LEDGER")
		else:
			ledger_table.refresh_prompt("[E] EXAMINE LEDGER TABLE")
		ledger_table.queue_redraw()
	$Landscape.ledger_solved = ledger_ok
	var ledger_panel := get_node_or_null("HUD/LedgerPuzzle")
	if ledger_panel != null:
		ledger_panel.set("solved", ledger_ok)

	var beacon_ok: bool = quest_manager.second_beacon_activated
	if second_beacon != null:
		second_beacon.activated = beacon_ok
		if quest_manager.get_current_objective_id() == "witness_elena_message":
			second_beacon.refresh_prompt("[E] TOUCH ELENA'S ECHO")
		elif beacon_ok:
			second_beacon.refresh_prompt("[E] EXAMINE SECOND BEACON")
		elif truth_ok:
			second_beacon.refresh_prompt("[E] RESTORE SECOND BEACON")
		else:
			second_beacon.refresh_prompt("[E] INSPECT SEALED BEACON")
		second_beacon.queue_redraw()
	$Landscape.second_beacon_activated = beacon_ok

	if ironwatch_gate != null:
		ironwatch_gate.unlocked = quest_manager.ironwatch_unlocked
		ironwatch_gate.ready_to_travel = false
		ironwatch_gate.refresh_prompt("[E] INSPECT IRONWATCH GATE")
		ironwatch_gate.queue_redraw()

	# Predefined story positions for Historian Lyra across Chapter 2 progression
	if lyra != null:
		if truth_ok:
			lyra.position = Vector2(114, -196)
			lyra.facing = 4
		elif sluice_ok:
			lyra.position = Vector2(-32, -82)
			lyra.facing = 2
		elif quest_manager.is_objective_completed("explore_ruined_village"):
			lyra.position = Vector2(124, 118)
			lyra.facing = 0
		else:
			lyra.position = Vector2(-128, 184)
			lyra.facing = 4
		lyra.queue_redraw()

	$Landscape.queue_redraw()

func apply_saved_state(path: String = "user://ashvale_save.json") -> bool:
	if quest_manager == null:
		return false
	if quest_manager.load_from_file(path):
		if quest_manager.has_saved_player_pose:
			$Actors/Player.position = quest_manager.saved_player_position
			$Actors/Player.facing = quest_manager.saved_player_facing
			$Actors/Player/Camera2D.snap_to_target()
		_sync_world_from_quest()
		return true
	return false

func travel_to_briarwood() -> void:
	if is_inside_tree():
		QuestManagerScript.pending_entry_pose = true
		QuestManagerScript.pending_entry_position = Vector2(146, -188)
		QuestManagerScript.pending_entry_facing = 4
		get_tree().change_scene_to_file("res://scenes/briarwood_forest.tscn")

func travel_to_ironwatch() -> void:
	if quest_manager != null and quest_manager.ironwatch_unlocked and is_inside_tree():
		QuestManagerScript.carry_prologue_completed = true
		QuestManagerScript.carry_chapter1_completed = true
		QuestManagerScript.carry_chapter2_completed = true
		QuestManagerScript.carry_optional_discoveries = quest_manager.optional_discoveries.duplicate()
		QuestManagerScript.pending_entry_pose = false
		get_tree().change_scene_to_file("res://scenes/ironwatch_keep.tscn")
