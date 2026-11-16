extends Node2D
## Main Chapter 4 scene controller populating Dawnspire Mountain's 7 alpine areas:
## Foothills, Whispering Cliffs (wind hazards & shelters), Broken Skybridge,
## Pilgrim's Refuge (Elena's journal), Celestial Observatory, Dawnspire Sanctuary,
## and the Great Bell Gate.

const BuildingScript = preload("res://scripts/world/dawnspire_building.gd")
const PropScript = preload("res://scripts/world/dawnspire_prop.gd")
const InteractableScript = preload("res://scripts/interactables/dawnspire_interactable.gd")
const NpcScene = preload("res://scenes/characters/npc.tscn")
const QuestManagerScript = preload("res://scripts/systems/quest_manager.gd")
const AudioManagerScript = preload("res://scripts/systems/audio_manager.gd")

const CLIFF_CHECKPOINTS := [
	{"id": "cliff_cp_0", "pos": Vector2(30, 184), "radius": 22.0},
	{"id": "cliff_cp_1", "pos": Vector2(180, 174), "radius": 22.0},
	{"id": "cliff_cp_2", "pos": Vector2(210, 74), "radius": 22.0},
]

var quest_manager: Node
var lyra: StaticBody2D

var skybridge_blocker_shape: CollisionShape2D
var sanctuary_blocker_shape: CollisionShape2D

var ironwatch_return_gate: StaticBody2D
var foothills_entrance: StaticBody2D
var cliff_cairn: StaticBody2D
var skybridge_console: StaticBody2D
var skybridge_diagram: StaticBody2D
var refuge_mural: StaticBody2D
var elena_journal: StaticBody2D
var observatory_arch: StaticBody2D
var celestial_mechanism: StaticBody2D
var sanctuary_threshold: StaticBody2D
var sanctuary_nexus: StaticBody2D
var great_bell_gate: StaticBody2D

var dawnspire_sanctum_bldg: StaticBody2D
var great_bell_portal_bldg: StaticBody2D

var skybridge_parts: Dictionary = {}
var celestial_clues: Dictionary = {}
var optional_spots: Dictionary = {}
var approach_positions: Array[Vector2] = []

var wind_clock: float = 0.0
var forced_wind_gust_active: bool = false
var _wind_sfx_played: bool = false
var _hazard_cooldown: float = 0.0

func _build_dawnspire_world() -> void:
	_build_boundaries()

	# Area A..G Alpine Architecture
	_spawn_building("FoothillsArch", "foothills_arch", Vector2(-196, 150))
	_spawn_building("CliffShelter1", "cliff_shelter", Vector2(180, 150))
	_spawn_building("SkybridgeAnchors", "skybridge_anchors", Vector2(0, 6))
	_spawn_building("PilgrimChapel", "pilgrim_chapel", Vector2(-214, -120))
	_spawn_building("ObservatoryDome", "observatory_dome", Vector2(252, -126))
	dawnspire_sanctum_bldg = _spawn_building("DawnspireSanctum", "dawnspire_sanctum", Vector2(-74, -222))
	great_bell_portal_bldg = _spawn_building("GreatBellPortal", "great_bell_portal", Vector2(128, -222))

	# Alpine Vegetation & Environmental Storytelling Props (clear of paths & spots)
	_spawn_prop("PineFoothillWest", "mountain_pine", Vector2(-292, 204))
	_spawn_prop("PineFoothillNorth", "mountain_pine", Vector2(-95, 162))
	_spawn_prop("PineCliffSouth", "mountain_pine", Vector2(76, 208))
	_spawn_prop("PineCliffNorth", "mountain_pine", Vector2(78, 78))
	_spawn_prop("CrimsonFrostTreeWest", "crimson_frost_tree", Vector2(-276, -128))
	_spawn_prop("CrimsonFrostTreeEast", "crimson_frost_tree", Vector2(-146, -134))
	_spawn_prop("FoothillLantern", "stone_lantern", Vector2(-128, 170))
	_spawn_prop("RefugePack", "pilgrim_pack", Vector2(-246, -94))
	_spawn_prop("SanctumLantern", "stone_lantern", Vector2(-2, -168))
	_spawn_prop("ObservatoryObeliskNorth", "star_obelisk", Vector2(114, -128))
	_spawn_prop("ObservatoryObeliskEast", "star_obelisk", Vector2(282, -112))
	_spawn_prop("BridgeBrazierWest", "wind_brazier", Vector2(-46, 2))
	_spawn_prop("BridgeBrazierEast", "wind_brazier", Vector2(46, 2))

	# Historian Lyra companion
	lyra = NpcScene.instantiate()
	lyra.name = "Lyra"
	lyra.npc_id = "lyra"
	lyra.speaker_name = "HISTORIAN LYRA"
	lyra.prompt_text = "[E] SPEAK WITH LYRA"
	lyra.interaction_priority = 8
	lyra.position = Vector2(-72, 202)
	lyra.facing = 6
	$Actors.add_child(lyra)

	# Core Story & Puzzle Interactables (spaced >= 48px cleanly)
	ironwatch_return_gate = _spawn_interactable(
		"IronwatchReturnGate", "ironwatch_return_gate", "", "IRONWATCH MOUNTAIN TRAIL",
		"[E] RETURN TO IRONWATCH KEEP", Vector2(-252, 222), 6, ""
	)
	foothills_entrance = _spawn_interactable(
		"FoothillsEntrance", "foothills_entrance", "", "DAWNSPIRE FOOTHILLS",
		"[E] SURVEY DAWNSPIRE ROAD", Vector2(-158, 180), 10, ""
	)
	cliff_cairn = _spawn_interactable(
		"CliffCairn", "cliff_marker", "", "WHISPERING CLIFFS CAIRN",
		"[E] INSPECT PILGRIM CAIRN", Vector2(168, 56), 10, ""
	)
	skybridge_console = _spawn_interactable(
		"SkybridgeConsole", "skybridge_console", "", "ANCIENT SKYBRIDGE WINCH",
		"[E] INSPECT BROKEN SKYBRIDGE", Vector2(-30, 18), 10, ""
	)
	skybridge_diagram = _spawn_interactable(
		"SkybridgeDiagram", "skybridge_diagram", "", "MASONRY WINCH DIAGRAM",
		"[E] READ ENGINEERING DIAGRAM", Vector2(44, 22), 10, ""
	)

	skybridge_parts["granite_counterweight"] = _spawn_interactable(
		"SkybridgePart1", "skybridge_part", "granite_counterweight", "GRANITE COUNTERWEIGHT",
		"[E] RECOVER COUNTERWEIGHT (1/3)", Vector2(94, 28), 10,
		"Aren straps the carved Granite Counterweight block to his satchel for Bay 1 of the Skybridge winch."
	)
	skybridge_parts["bronze_pinion"] = _spawn_interactable(
		"SkybridgePart2", "skybridge_part", "bronze_pinion", "BRONZE PINION WHEEL",
		"[E] RECOVER PINION WHEEL (2/3)", Vector2(-108, 48), 10,
		"Aren recovers an intact Bronze Pinion Wheel half-buried in scree for Bay 2 of the lift assembly."
	)
	skybridge_parts["tension_chain"] = _spawn_interactable(
		"SkybridgePart3", "skybridge_part", "tension_chain", "TENSION ANCHOR CHAIN",
		"[E] RECOVER ANCHOR CHAIN (3/3)", Vector2(-196, 36), 10,
		"Aren unhooks a forged Tension Anchor Chain intact along the western cliff spur for Bay 3."
	)

	refuge_mural = _spawn_interactable(
		"RefugeMural", "refuge_mural", "", "PILGRIM'S REFUGE MURALS",
		"[E] EXAMINE REFUGE MURALS", Vector2(-146, -84), 10, ""
	)
	elena_journal = _spawn_interactable(
		"ElenaJournal", "elena_journal", "", "ELENA'S PRESERVED JOURNAL",
		"[E] READ ELENA'S JOURNAL", Vector2(-224, -92), 10, ""
	)
	observatory_arch = _spawn_interactable(
		"ObservatoryArch", "observatory_arch", "", "CELESTIAL OBSERVATORY ARCH",
		"[E] ENTER OBSERVATORY TERRACE", Vector2(88, -108), 10, ""
	)

	celestial_clues["sun"] = _spawn_interactable(
		"CelestialClue1", "celestial_clue", "sun", "SOLAR ALIGNMENT PILLAR",
		"[E] READ SOLAR PILLAR (1/3)", Vector2(146, -120), 10, ""
	)
	celestial_clues["moon"] = _spawn_interactable(
		"CelestialClue2", "celestial_clue", "moon", "LUNAR ALIGNMENT PILLAR",
		"[E] READ LUNAR PILLAR (2/3)", Vector2(270, -72), 10, ""
	)
	celestial_clues["stars"] = _spawn_interactable(
		"CelestialClue3", "celestial_clue", "stars", "STELLAR ALIGNMENT PILLAR",
		"[E] READ STELLAR PILLAR (3/3)", Vector2(174, -58), 10, ""
	)
	celestial_mechanism = _spawn_interactable(
		"CelestialMechanism", "celestial_mechanism", "", "CELESTIAL ASTROLABE",
		"[E] ALIGN CELESTIAL RINGS", Vector2(204, -102), 11, ""
	)

	sanctuary_threshold = _spawn_interactable(
		"SanctuaryThreshold", "sanctuary_threshold", "", "DAWNSPIRE SANCTUARY ARCH",
		"[E] STEP INTO SANCTUARY", Vector2(48, -172), 10, ""
	)
	sanctuary_nexus = _spawn_interactable(
		"SanctuaryNexus", "sanctuary_nexus", "", "DAWNSPIRE BEACON NEXUS",
		"[E] SYNCHRONIZE THREE BEACONS", Vector2(-32, -196), 11, ""
	)
	great_bell_gate = _spawn_interactable(
		"GreatBellGate", "great_bell_gate", "", "GREAT BELL GATE",
		"[E] INSPECT GREAT BELL GATE", Vector2(96, -194), 10, ""
	)

	# 4 Optional Explorations reinforcing memory & sacrifice themes
	optional_spots["dawnspire_campsite"] = _spawn_interactable(
		"OptMountainCamp", "optional_discovery", "dawnspire_campsite", "ABANDONED MOUNTAIN CAMPSITE",
		"[E] INSPECT CAMPSITE", Vector2(-284, 152), 10, "optional_mountain_campsite"
	)
	optional_spots["dawnspire_pilgrim_letter"] = _spawn_interactable(
		"OptPilgrimLetter", "optional_discovery", "dawnspire_pilgrim_letter", "FORGOTTEN PILGRIM'S LETTER",
		"[E] READ PILGRIM'S LETTER", Vector2(-18, 218), 10, "optional_pilgrim_letter"
	)
	optional_spots["dawnspire_memorial"] = _spawn_interactable(
		"OptPilgrimMemorial", "optional_discovery", "dawnspire_memorial", "MOUNTAIN MEMORIAL PLAQUE",
		"[E] READ PILGRIM MEMORIAL", Vector2(252, 118), 10, "optional_pilgrim_memorial"
	)
	optional_spots["dawnspire_hidden_overlook"] = _spawn_interactable(
		"OptHiddenOverlook", "optional_discovery", "dawnspire_hidden_overlook", "HIDDEN VALLEY OVERLOOK",
		"[E] VIEW ASHVALE VALLEY", Vector2(-286, -84), 10, "optional_hidden_overlook"
	)

	approach_positions = [
		Vector2(-224, 212),
		Vector2(-158, 198),
		Vector2(-94, 202),
		Vector2(-262, 166),
		Vector2(-44, 210),
		Vector2(232, 118),
		Vector2(144, 68),
		Vector2(-12, 26),
		Vector2(28, 34),
		Vector2(78, 38),
		Vector2(-90, 54),
		Vector2(-174, 48),
		Vector2(-126, -78),
		Vector2(-204, -76),
		Vector2(-264, -76),
		Vector2(80, -86),
		Vector2(130, -104),
		Vector2(248, -72),
		Vector2(154, -58),
		Vector2(188, -94),
		Vector2(26, -162),
		Vector2(-12, -184),
		Vector2(74, -184),
	]

func _ready() -> void:
	_build_dawnspire_world()

	quest_manager = QuestManagerScript.new()
	quest_manager.name = "QuestManager"
	quest_manager.quest_data_path = QuestManagerScript.CHAPTER4_DATA_PATH
	add_child(quest_manager)
	quest_manager.objective_changed.connect(_on_objective_changed)
	quest_manager.objective_completed.connect(_on_objective_completed)

	$HUD.player = $Actors/Player
	$HUD.terminal = foothills_entrance
	$HUD.bind_quest_manager(quest_manager)
	$HUD/Subtitle.text = "DAWNSPIRE MOUNTAIN - ROAD TO THE LAST BELL"
	$HUD/Clock.text = "CHAPTER 4"
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
	if QuestManagerScript.carry_chapter2_completed:
		quest_manager.chapter2_completed = true
		quest_manager.ironwatch_unlocked = true
		quest_manager.watermill_repaired = true
		quest_manager.sluice_solved = true
		quest_manager.ledger_reconstructed = true
		quest_manager.villagers_truth_discovered = true
		quest_manager.second_beacon_activated = true
		quest_manager.chapter2_elena_echo_heard = true
		QuestManagerScript.carry_chapter2_completed = false
	if QuestManagerScript.carry_chapter3_completed:
		quest_manager.chapter3_completed = true
		quest_manager.dawnspire_unlocked = true
		quest_manager.warden_records_found = true
		quest_manager.barracks_explored = true
		quest_manager.crest_puzzle_solved = true
		quest_manager.shadow_passage_cleared = true
		quest_manager.warden_confronted = true
		quest_manager.elena_research_found = true
		quest_manager.third_beacon_activated = true
		QuestManagerScript.carry_chapter3_completed = false
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
	AudioManagerScript.play_global_region(get_tree(), "dawnspire")
	$HUD.play_region_transition("DAWNSPIRE MOUNTAIN", "CHAPTER 4 - THE ROAD TO DAWNSPIRE")

func _physics_process(delta: float) -> void:
	if quest_manager == null or $Actors/Player == null:
		return
	if _hazard_cooldown > 0.0:
		_hazard_cooldown = maxf(0.0, _hazard_cooldown - delta)

	var p: CharacterBody2D = $Actors/Player
	var p_pos: Vector2 = p.position

	# Crossing the repaired Skybridge physically north across the ravine completes repair_skybridge
	if quest_manager.skybridge_repaired and quest_manager.get_current_objective_id() == "repair_skybridge":
		if p_pos.y <= -46.0:
			quest_manager.complete_objective("repair_skybridge")

	# Update Cliff Checkpoints whenever standing safely inside a Shelter Cairn (southeast ridge)
	var in_cliffs_band: bool = (p_pos.x >= 18.0 and p_pos.x <= 295.0 and p_pos.y >= 46.0 and p_pos.y <= 216.0)
	if not in_cliffs_band:
		p.external_wind_velocity = Vector2.ZERO
		$Landscape.wind_gust_active = false
		$Landscape.wind_warning_active = false
		$HUD.set_stealth_status("")
		return

	var sheltered: bool = false
	for cp in CLIFF_CHECKPOINTS:
		var cp_pos: Vector2 = cp["pos"]
		if p_pos.distance_to(cp_pos) <= float(cp["radius"]):
			sheltered = true
			var cp_id: String = String(cp["id"])
			if cp_id != quest_manager.cliff_checkpoint_id:
				quest_manager.set_cliff_checkpoint(cp_id, cp_pos)
				$Landscape.active_cliff_checkpoint_id = cp_id
				$Landscape.queue_redraw()
			break

	# Once Whispering Cliffs are navigated, fierce gusts calm down cleanly
	if quest_manager.cliffs_navigated and not forced_wind_gust_active:
		p.external_wind_velocity = Vector2.ZERO
		$Landscape.wind_gust_active = false
		$Landscape.wind_warning_active = false
		$HUD.set_stealth_status("")
		return

	if _hazard_cooldown > 0.0 or $HUD._is_modal_open():
		p.external_wind_velocity = Vector2.ZERO
		return

	# Check physical precipice fall edges along Whispering Cliffs (east ridge > 280 or south drop > 210)
	if (p_pos.x >= 280.0 and p_pos.y >= 74.0 and p_pos.y <= 212.0) or (p_pos.x >= 115.0 and p_pos.y >= 210.0):
		trigger_cliff_hazard_reset("The crumbling precipice gives way beneath loose scree! You recover safely back at the wind shelter.")
		return

	# Rhythmic 6.0s Whispering Cliffs gale cycle (or forced test gust)
	wind_clock = fmod(wind_clock + delta, 6.0)
	var warning_now: bool = (not forced_wind_gust_active and wind_clock >= 2.6 and wind_clock < 4.2)
	var gust_now: bool = forced_wind_gust_active or (wind_clock >= 4.2)
	$Landscape.wind_warning_active = warning_now
	$Landscape.wind_gust_active = gust_now

	var in_wind_corridor: bool = (p_pos.x >= 115.0 and p_pos.x <= 279.0 and p_pos.y >= 82.0 and p_pos.y <= 204.0)
	if gust_now:
		if not _wind_sfx_played:
			_wind_sfx_played = true
			AudioManagerScript.play_global_sfx(get_tree(), "mountain_wind")
		if sheltered:
			p.external_wind_velocity = Vector2.ZERO
			$HUD.set_stealth_status("WIND SHELTER: Stone cairn blocks the Whispering Cliffs gale.")
		elif in_wind_corridor:
			p.external_wind_velocity = Vector2(44.0, 0.0)
			$HUD.set_stealth_status("STRONG GALE: Crosswind pushing east toward cliff edge! Move west or shelter.")
		else:
			p.external_wind_velocity = Vector2.ZERO
			$HUD.set_stealth_status("WHISPERING CLIFFS: Gale sweeping the ridge above.")
	elif warning_now:
		_wind_sfx_played = false
		p.external_wind_velocity = Vector2.ZERO
		$HUD.set_stealth_status("GUST WARNING: Heavy wind gathering! Brace at a shelter stone.")
	else:
		_wind_sfx_played = false
		p.external_wind_velocity = Vector2.ZERO
		if sheltered:
			$HUD.set_stealth_status("WIND SHELTER: Safe resting cairn along Whispering Cliffs.")
		else:
			$HUD.set_stealth_status("WHISPERING CLIFFS: Climb the ridge toward the Skybridge overlook.")

func trigger_cliff_hazard_reset(reason: String = "A sudden mountain gale knocks Aren off balance! Recovered cleanly at the active wind shelter.") -> void:
	if quest_manager == null or $Actors/Player == null:
		return
	_hazard_cooldown = 0.65
	forced_wind_gust_active = false
	quest_manager.record_cliff_reset()
	var p: CharacterBody2D = $Actors/Player
	p.external_wind_velocity = Vector2.ZERO
	p.velocity = Vector2.ZERO
	p.position = quest_manager.cliff_checkpoint_pos
	p.get_node("Camera2D").snap_to_target()
	AudioManagerScript.play_global_sfx(get_tree(), "mountain_wind")
	$HUD.set_stealth_status("CHECKPOINT RESET (%s): Footing recovered safely." % quest_manager.cliff_checkpoint_id.to_upper())
	if not $HUD._is_modal_open():
		var msg: Array[String] = [reason]
		$HUD.show_dialogue("WHISPERING CLIFFS", msg, cliff_cairn)

func _build_boundaries() -> void:
	var outer := StaticBody2D.new()
	outer.name = "OuterWalls"
	outer.collision_layer = 1
	outer.collision_mask = 2
	var specs := [
		{"pos": Vector2(0, -250), "size": Vector2(700, 18)},
		{"pos": Vector2(0, 248), "size": Vector2(700, 18)},
		{"pos": Vector2(-334, 0), "size": Vector2(18, 520)},
		{"pos": Vector2(334, 0), "size": Vector2(18, 520)},
		# Ravine chasm flanking the x=-26..26 Skybridge opening
		{"pos": Vector2(-174, -24), "size": Vector2(296, 24)},
		{"pos": Vector2(174, -24), "size": Vector2(296, 24)},
		# Summit ridge wall flanking the x=-4..52 Sanctuary stairway opening
		{"pos": Vector2(-164, -150), "size": Vector2(320, 16)},
		{"pos": Vector2(188, -150), "size": Vector2(272, 16)},
	]
	for sp in specs:
		var col := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = sp["size"]
		col.shape = rect
		col.position = sp["pos"]
		outer.add_child(col)
	$Boundary.add_child(outer)

	var bridge_blocker := StaticBody2D.new()
	bridge_blocker.name = "SkybridgeBlocker"
	bridge_blocker.collision_layer = 1
	bridge_blocker.collision_mask = 2
	skybridge_blocker_shape = CollisionShape2D.new()
	var sb_rect := RectangleShape2D.new()
	sb_rect.size = Vector2(58, 24)
	skybridge_blocker_shape.shape = sb_rect
	skybridge_blocker_shape.position = Vector2(0, -24)
	bridge_blocker.add_child(skybridge_blocker_shape)
	$Boundary.add_child(bridge_blocker)

	var sanc_blocker := StaticBody2D.new()
	sanc_blocker.name = "SanctuaryBlocker"
	sanc_blocker.collision_layer = 1
	sanc_blocker.collision_mask = 2
	sanctuary_blocker_shape = CollisionShape2D.new()
	var sc_rect := RectangleShape2D.new()
	sc_rect.size = Vector2(62, 18)
	sanctuary_blocker_shape.shape = sc_rect
	sanctuary_blocker_shape.position = Vector2(24, -150)
	sanc_blocker.add_child(sanctuary_blocker_shape)
	$Boundary.add_child(sanc_blocker)

func _spawn_building(node_name: String, kind_name: String, pos: Vector2) -> StaticBody2D:
	var b := StaticBody2D.new()
	b.set_script(BuildingScript)
	b.name = node_name
	b.kind = kind_name
	b.position = pos
	$Actors.add_child(b)
	return b

func _spawn_prop(node_name: String, kind_name: String, pos: Vector2) -> StaticBody2D:
	var p := StaticBody2D.new()
	p.set_script(PropScript)
	p.name = node_name
	p.kind = kind_name
	p.position = pos
	$Actors.add_child(p)
	return p

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

func _on_objective_changed(_id: String, _text: String) -> void:
	_sync_world_from_quest()

func _on_objective_completed(_id: String) -> void:
	_sync_world_from_quest()

func _sync_world_from_quest() -> void:
	if quest_manager == null:
		return

	if foothills_entrance != null:
		foothills_entrance.inspected = quest_manager.is_objective_completed("enter_foothills")
		foothills_entrance.refresh_prompt("[E] SURVEY DAWNSPIRE OVERLOOK" if foothills_entrance.inspected else "[E] SURVEY DAWNSPIRE ROAD")
		foothills_entrance.queue_redraw()
	if cliff_cairn != null:
		cliff_cairn.inspected = quest_manager.cliffs_navigated
		cliff_cairn.refresh_prompt("[E] READ SHELTER INSCRIPTION" if cliff_cairn.inspected else "[E] INSPECT PILGRIM CAIRN")
		cliff_cairn.queue_redraw()
	if skybridge_diagram != null:
		skybridge_diagram.inspected = quest_manager.skybridge_diagram_read
		skybridge_diagram.queue_redraw()

	for part_id in skybridge_parts.keys():
		var p_node: StaticBody2D = skybridge_parts[part_id]
		p_node.collected = quest_manager.skybridge_parts_collected.has(part_id)
		p_node.queue_redraw()

	var bridge_ok: bool = quest_manager.skybridge_repaired
	if skybridge_blocker_shape != null:
		skybridge_blocker_shape.set_deferred("disabled", bridge_ok)
		skybridge_blocker_shape.disabled = bridge_ok
	if skybridge_console != null:
		skybridge_console.solved = bridge_ok
		skybridge_console.refresh_prompt("[E] INSPECT REPAIRED SKYBRIDGE" if bridge_ok else ("[E] REPAIR SKYBRIDGE" if quest_manager.can_open_skybridge_repair() else "[E] INSPECT SKYBRIDGE"))
		skybridge_console.queue_redraw()
	var sb_panel := get_node_or_null("HUD/SkybridgeRepair")
	if sb_panel != null:
		sb_panel.set("repaired", bridge_ok)

	if refuge_mural != null:
		refuge_mural.inspected = quest_manager.pilgrim_refuge_discovered
		refuge_mural.queue_redraw()
	if elena_journal != null:
		elena_journal.inspected = quest_manager.elena_journal_read
		elena_journal.queue_redraw()
	if observatory_arch != null:
		observatory_arch.inspected = quest_manager.observatory_reached
		observatory_arch.refresh_prompt("[E] EXAMINE OBSERVATORY ARCH" if observatory_arch.inspected else "[E] ENTER OBSERVATORY TERRACE")
		observatory_arch.queue_redraw()

	for clue_key in celestial_clues.keys():
		var c_node: StaticBody2D = celestial_clues[clue_key]
		c_node.inspected = quest_manager.celestial_clues_found.has(clue_key)
		c_node.queue_redraw()

	var obs_ok: bool = quest_manager.observatory_solved
	if sanctuary_blocker_shape != null:
		sanctuary_blocker_shape.set_deferred("disabled", obs_ok)
		sanctuary_blocker_shape.disabled = obs_ok
	if celestial_mechanism != null:
		celestial_mechanism.solved = obs_ok
		celestial_mechanism.refresh_prompt("[E] EXAMINE ALIGNED ASTROLABE" if obs_ok else ("[E] ALIGN CELESTIAL RINGS" if quest_manager.can_open_celestial_puzzle() else "[E] INSPECT CELESTIAL RINGS"))
		celestial_mechanism.queue_redraw()
	var cel_panel := get_node_or_null("HUD/CelestialPuzzle")
	if cel_panel != null:
		cel_panel.set("solved", obs_ok)

	if sanctuary_threshold != null:
		sanctuary_threshold.inspected = quest_manager.sanctuary_entered
		sanctuary_threshold.refresh_prompt("[E] VIEW ASHVALE VALLEY" if sanctuary_threshold.inspected else "[E] STEP INTO SANCTUARY")
		sanctuary_threshold.queue_redraw()

	var sync_ok: bool = quest_manager.beacons_synchronized
	if sanctuary_nexus != null:
		sanctuary_nexus.activated = sync_ok
		if quest_manager.get_current_objective_id() == "witness_sanctuary_revelation":
			sanctuary_nexus.refresh_prompt("[E] WITNESS SANCTUARY REVELATION")
		elif sync_ok:
			sanctuary_nexus.refresh_prompt("[E] EXAMINE SYNCHRONIZED NEXUS")
		else:
			sanctuary_nexus.refresh_prompt("[E] SYNCHRONIZE THREE BEACONS")
		sanctuary_nexus.queue_redraw()
	if dawnspire_sanctum_bldg != null:
		dawnspire_sanctum_bldg.set("beacons_synchronized", sync_ok)
		dawnspire_sanctum_bldg.queue_redraw()

	var gate_ok: bool = quest_manager.great_bell_gate_unlocked
	if great_bell_gate != null:
		great_bell_gate.unlocked = gate_ok
		if quest_manager.get_current_objective_id() == "complete_chapter4":
			great_bell_gate.refresh_prompt("[E] COMPLETE CHAPTER 4")
		elif gate_ok:
			great_bell_gate.refresh_prompt("[E] EXAMINE GREAT BELL GATE")
		else:
			great_bell_gate.refresh_prompt("[E] INSPECT GREAT BELL GATE")
		great_bell_gate.queue_redraw()
	if great_bell_portal_bldg != null:
		great_bell_portal_bldg.set("great_bell_unlocked", gate_ok)
		great_bell_portal_bldg.queue_redraw()

	for opt_id in optional_spots.keys():
		var opt_node: StaticBody2D = optional_spots[opt_id]
		opt_node.collected = quest_manager.optional_discoveries.has(opt_id)
		opt_node.queue_redraw()

	$Landscape.cliffs_navigated = quest_manager.cliffs_navigated
	$Landscape.skybridge_repaired = bridge_ok
	$Landscape.observatory_solved = obs_ok
	$Landscape.beacons_synchronized = sync_ok
	$Landscape.great_bell_gate_unlocked = gate_ok
	$Landscape.active_cliff_checkpoint_id = quest_manager.cliff_checkpoint_id

	# Relocate Historian Lyra along the mountain ascent without blocking roads or interactables
	if lyra != null:
		var obj_now: String = quest_manager.get_current_objective_id()
		if quest_manager.chapter4_completed or obj_now in ["enter_dawnspire_sanctuary", "synchronize_three_beacons", "witness_sanctuary_revelation", "reach_great_bell_gate", "complete_chapter4"]:
			lyra.position = Vector2(46, -206)
			lyra.facing = 4
		elif obj_now in ["reach_observatory", "find_celestial_clues", "solve_observatory_puzzle"]:
			lyra.position = Vector2(106, -110)
			lyra.facing = 0
		elif obj_now in ["discover_pilgrims_refuge", "read_elena_journal"]:
			lyra.position = Vector2(-106, -98)
			lyra.facing = 4
		elif obj_now in ["navigate_whispering_cliffs", "investigate_skybridge", "discover_bridge_mechanism", "repair_skybridge"]:
			lyra.position = Vector2(-52, 46)
			lyra.facing = 0
		else:
			lyra.position = Vector2(-72, 202)
			lyra.facing = 6
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

func travel_to_great_bell() -> bool:
	if quest_manager == null or not (quest_manager.chapter4_completed and quest_manager.great_bell_gate_unlocked):
		return false
	if not is_inside_tree():
		return false
	QuestManagerScript.carry_prologue_completed = true
	QuestManagerScript.carry_chapter1_completed = true
	QuestManagerScript.carry_chapter2_completed = true
	QuestManagerScript.carry_chapter3_completed = true
	QuestManagerScript.carry_chapter4_completed = true
	QuestManagerScript.carry_optional_discoveries = quest_manager.optional_discoveries.duplicate()
	QuestManagerScript.pending_entry_pose = true
	QuestManagerScript.pending_entry_position = Vector2(-216, 206)
	QuestManagerScript.pending_entry_facing = 0
	get_tree().change_scene_to_file("res://scenes/great_bell_sanctum.tscn")
	return true

func travel_to_ironwatch() -> void:
	if is_inside_tree():
		QuestManagerScript.pending_entry_pose = true
		QuestManagerScript.pending_entry_position = Vector2(152, -134)
		QuestManagerScript.pending_entry_facing = 2
		get_tree().change_scene_to_file("res://scenes/ironwatch_keep.tscn")
