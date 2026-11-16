extends Node2D
## Main Chapter 3 scene controller populating Ironwatch Keep's 6 fortress areas,
## Hall of Crests heraldic puzzle, Shadowed Passage stealth sentinels, Last Bell Warden,
## Elena's research, Third Ancient Beacon triad, and northern Dawnspire Gate.

const BuildingScript = preload("res://scripts/world/ironwatch_building.gd")
const PropScript = preload("res://scripts/world/ironwatch_prop.gd")
const InteractableScript = preload("res://scripts/interactables/ironwatch_interactable.gd")
const SentinelScript = preload("res://scripts/world/shadow_sentinel.gd")
const NpcScene = preload("res://scenes/characters/npc.tscn")
const QuestManagerScript = preload("res://scripts/systems/quest_manager.gd")
const AudioManagerScript = preload("res://scripts/systems/audio_manager.gd")

const SAFE_ALCOVES := [
	{"id": "checkpoint_0", "pos": Vector2(-160, -48), "radius": 22.0},
	{"id": "checkpoint_1", "pos": Vector2(-160, -110), "radius": 22.0},
	{"id": "checkpoint_2", "pos": Vector2(-160, -164), "radius": 24.0},
]

var quest_manager: Node
var lyra: StaticBody2D
var last_warden: StaticBody2D

var crest_blocker_shape: CollisionShape2D
var passage_exit_blocker_shape: CollisionShape2D

var courtyard_arch: StaticBody2D
var floodmill_return_gate: StaticBody2D
var courtyard_monument: StaticBody2D
var warden_records: StaticBody2D
var barracks_log: StaticBody2D
var barracks_keepsake: StaticBody2D
var crest_altar: StaticBody2D
var shadow_ward_switch: StaticBody2D
var elena_research: StaticBody2D
var third_beacon: StaticBody2D
var dawnspire_gate: StaticBody2D
var vault_sanctum: StaticBody2D

var crest_clues: Dictionary = {}
var sentinels: Array[Node2D] = []
var approach_positions: Array[Vector2] = []
var stealth_recovery_cooldown: float = 0.0

func _build_ironwatch_world() -> void:
	_build_boundaries()

	# 6 Distinct Fortress Areas (No permanent oversized text labels)
	_spawn_building("GatehouseBastion", "gatehouse_bastion", Vector2(248, 178))
	_spawn_building("RuinedBarracks", "ruined_barracks", Vector2(-265, 118))
	_spawn_building("CutawayArchives", "cutaway_archives", Vector2(215, 24))
	_spawn_building("HallOfCrests", "hall_of_crests", Vector2(-18, -44))
	_spawn_building("ShadowColonnade", "shadow_colonnade", Vector2(-238, -108))
	vault_sanctum = _spawn_building("BeaconVaultSanctum", "beacon_vault_sanctum", Vector2(35, -206))

	# Non-intrusive Fortress Props placed clear of walkways
	_spawn_prop("SupplyWagon", "supply_wagon", Vector2(-68, 172))
	_spawn_prop("BarracksRack", "weapon_rack", Vector2(-252, 165))
	_spawn_prop("BarracksBunk", "barracks_bunk", Vector2(-165, 198))
	_spawn_prop("ArchiveDesk", "archive_desk", Vector2(264, 24))
	_spawn_prop("PortcullisBrazierWest", "ward_brazier", Vector2(-204, -12))
	_spawn_prop("PortcullisBrazierEast", "ward_brazier", Vector2(-116, -12))
	_spawn_prop("VaultObeliskWest", "arcane_obelisk", Vector2(-82, -190))
	_spawn_prop("VaultObeliskEast", "arcane_obelisk", Vector2(198, -190))

	# Patrolling Shadow Sentinels inside the Shadowed Passage (y = -82 and y = -136)
	var s1 := SentinelScript.new()
	s1.name = "ShadowSentinel1"
	s1.position = Vector2(-160, -82)
	s1.phase_offset = 0.0
	$Actors.add_child(s1)
	sentinels.append(s1)

	var s2 := SentinelScript.new()
	s2.name = "ShadowSentinel2"
	s2.position = Vector2(-160, -136)
	s2.phase_offset = PI
	$Actors.add_child(s2)
	sentinels.append(s2)

	# Key Characters: Historian Lyra & Last Bell Warden
	lyra = NpcScene.instantiate()
	lyra.name = "Lyra"
	lyra.npc_id = "lyra"
	lyra.speaker_name = "HISTORIAN LYRA"
	lyra.prompt_text = "[E] SPEAK WITH LYRA"
	lyra.interaction_priority = 8
	lyra.position = Vector2(56, 214)
	lyra.facing = 2
	$Actors.add_child(lyra)

	last_warden = NpcScene.instantiate()
	last_warden.name = "LastWarden"
	last_warden.npc_id = "warden"
	last_warden.speaker_name = "LAST BELL WARDEN"
	last_warden.prompt_text = "[E] CONFRONT LAST WARDEN"
	last_warden.interaction_priority = 8
	last_warden.position = Vector2(-35, -142)
	last_warden.facing = 4
	$Actors.add_child(last_warden)

	# All Chapter 3 Interactables (cleanly spaced >= 50px, standard priority 10)
	courtyard_arch = _spawn_interactable(
		"CourtyardArch", "courtyard_arch", "", "IRONWATCH GATEHOUSE",
		"[E] INSPECT KEEP THRESHOLD", Vector2(120, 178), 10, ""
	)
	floodmill_return_gate = _spawn_interactable(
		"FloodmillReturnGate", "floodmill_return_gate", "", "FLOODMILL MOUNTAIN PASS",
		"[E] RETURN TO FLOODMILL", Vector2(185, 222), 6, ""
	)
	courtyard_monument = _spawn_interactable(
		"CourtyardMonument", "courtyard_monument", "", "COURTYARD STATUE CIRCLE",
		"[E] INSPECT STATUE CIRCLE", Vector2(18, 148), 10, ""
	)
	warden_records = _spawn_interactable(
		"WardenRecords", "warden_records", "", "FIRST CATASTROPHE LEDGER",
		"[E] READ WARDENS' RECORDS", Vector2(185, 34), 10, ""
	)
	barracks_log = _spawn_interactable(
		"BarracksLog", "barracks_log", "", "BARRACKS DUTY ROSTER",
		"[E] INSPECT BARRACKS ROSTER", Vector2(-195, 128), 10, ""
	)
	barracks_keepsake = _spawn_interactable(
		"BarracksKeepsake", "barracks_keepsake", "wardens_locket", "WARDEN'S TARNISHED LOCKET",
		"[E] EXAMINE TARNISHED LOCKET", Vector2(-120, 178), 10, ""
	)

	crest_clues["clue_1"] = _spawn_interactable(
		"CrestClue1", "crest_clue", "clue_1", "FIRST WATCH TABLET (1/3)",
		"[E] READ ARCHIVES CREST TABLET", Vector2(238, 76), 10, ""
	)
	crest_clues["clue_2"] = _spawn_interactable(
		"CrestClue2", "crest_clue", "clue_2", "SECOND WATCH PLAQUE (2/3)",
		"[E] READ ARMORY CREST PLAQUE", Vector2(-190, 56), 10, ""
	)
	crest_clues["clue_3"] = _spawn_interactable(
		"CrestClue3", "crest_clue", "clue_3", "THIRD WATCH STELE (3/3)",
		"[E] READ HALL OF CRESTS STELE", Vector2(72, 22), 10, ""
	)

	crest_altar = _spawn_interactable(
		"CrestAltar", "crest_altar", "", "HALL OF CRESTS ALTAR",
		"[E] ALIGN WATCH CRESTS", Vector2(-18, 12), 10, ""
	)
	shadow_ward_switch = _spawn_interactable(
		"ShadowWardSwitch", "shadow_ward_switch", "", "NORTH WARD LANTERN",
		"[E] HARMONIZE WARD LANTERN", Vector2(-160, -164), 10, ""
	)
	elena_research = _spawn_interactable(
		"ElenaResearch", "elena_research", "", "ELENA'S RESEARCH FOLIO",
		"[E] EXAMINE ELENA'S RESEARCH", Vector2(18, -120), 10, ""
	)
	third_beacon = _spawn_interactable(
		"ThirdBeacon", "third_beacon", "", "THIRD ANCIENT BEACON",
		"[E] RESTORE THIRD BEACON", Vector2(70, -148), 11, ""
	)
	dawnspire_gate = _spawn_interactable(
		"DawnspireGate", "dawnspire_gate", "", "DAWNSPIRES CITADEL GATE",
		"[E] INSPECT DAWNSPIRE GATE", Vector2(152, -162), 10, ""
	)

	approach_positions = [
		Vector2(120, 198),
		Vector2(185, 206),
		Vector2(18, 176),
		Vector2(185, 62),
		Vector2(-195, 154),
		Vector2(-120, 156),
		Vector2(216, 76),
		Vector2(-164, 56),
		Vector2(44, 22),
		Vector2(-18, 36),
		Vector2(-160, -150),
		Vector2(18, -98),
		Vector2(70, -120),
		Vector2(152, -134),
		Vector2(-35, -118),
	]

func _ready() -> void:
	_build_ironwatch_world()

	quest_manager = QuestManagerScript.new()
	quest_manager.name = "QuestManager"
	quest_manager.quest_data_path = QuestManagerScript.CHAPTER3_DATA_PATH
	add_child(quest_manager)
	quest_manager.objective_changed.connect(_on_objective_changed)
	quest_manager.objective_completed.connect(_on_objective_completed)

	$HUD.player = $Actors/Player
	$HUD.terminal = courtyard_arch
	$HUD.bind_quest_manager(quest_manager)
	$HUD/Subtitle.text = "IRONWATCH KEEP - CITADEL OF BELL WARDENS"
	$HUD/Clock.text = "CHAPTER 3"
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
	AudioManagerScript.play_global_region(get_tree(), "ironwatch")
	$HUD.play_region_transition("IRONWATCH KEEP", "CHAPTER 3 - THE KEEPER'S LIE")

func _physics_process(delta: float) -> void:
	if quest_manager == null or $Actors/Player == null:
		return
	if stealth_recovery_cooldown > 0.0:
		stealth_recovery_cooldown = maxf(0.0, stealth_recovery_cooldown - delta)

	var p_pos: Vector2 = $Actors/Player.position

	# Entering the northern Warden's Chamber completes reach_wardens_chamber cleanly
	if quest_manager.shadow_passage_cleared and quest_manager.get_current_objective_id() == "reach_wardens_chamber":
		if p_pos.x > -96.0 and p_pos.y < -95.0:
			quest_manager.complete_objective("reach_wardens_chamber")

	# Stealth mechanics while inside the Shadowed Passage prior to harmonizing the North Ward Lantern
	var in_passage: bool = (p_pos.x > -208.0 and p_pos.x < -112.0 and p_pos.y < -40.0 and p_pos.y > -190.0)
	if not in_passage or quest_manager.shadow_passage_cleared:
		for s in sentinels:
			s.set("player_in_caution", false)
		$HUD.set_stealth_status("")
		return

	# Check Safe Alcoves & auto-update checkpoint_1 / checkpoint_2
	var in_safe_alcove: bool = false
	for alc in SAFE_ALCOVES:
		var a_pos: Vector2 = alc["pos"]
		var a_rad: float = float(alc["radius"])
		if p_pos.distance_to(a_pos) <= a_rad:
			in_safe_alcove = true
			var a_id: String = String(alc["id"])
			if a_id != quest_manager.stealth_checkpoint_id:
				if quest_manager.stealth_checkpoint_id == "checkpoint_0" or a_id == "checkpoint_2":
					quest_manager.set_stealth_checkpoint(a_id, a_pos)
					$Landscape.active_checkpoint_id = a_id
					$Landscape.queue_redraw()
			break

	if in_safe_alcove:
		for s in sentinels:
			s.set("player_in_caution", false)
		$HUD.set_stealth_status("SAFE ALCOVE: Ward rune shields Aren from Shadow Sentinels.")
		return

	if stealth_recovery_cooldown > 0.0 or $HUD._is_modal_open():
		return

	var nearest_dist: float = INF
	for s in sentinels:
		var d: float = p_pos.distance_to(s.position)
		nearest_dist = minf(nearest_dist, d)
		s.set("player_in_caution", d <= s.caution_radius)
		if d <= s.detection_radius:
			trigger_sentinel_detection()
			return

	if nearest_dist <= 38.0:
		$HUD.set_stealth_status("CAUTION: Shadow Sentinel beam sweeping! Step into a glowing Ward Alcove.")
	else:
		$HUD.set_stealth_status("SHADOWED PASSAGE: Slip north past the sentinels to the Ward Lantern.")

func trigger_sentinel_detection() -> void:
	if quest_manager == null or $Actors/Player == null:
		return
	stealth_recovery_cooldown = 0.65
	quest_manager.record_stealth_detection()
	$Actors/Player.position = quest_manager.stealth_checkpoint_pos
	$Actors/Player.velocity = Vector2.ZERO
	$Actors/Player/Camera2D.snap_to_target()
	$HUD.set_stealth_status("DETECTED: Returned safely to Ward Checkpoint (%s)." % quest_manager.stealth_checkpoint_id.to_upper())
	if not $HUD._is_modal_open():
		var det_lines: Array[String] = ["A Shadow Sentinel's violet gaze sweeps across the flagstones! The active Ward Alcove pulls Aren safely back to the checkpoint without losing any discoveries."]
		$HUD.show_dialogue("SHADOW SENTINEL", det_lines, shadow_ward_switch)

func _build_boundaries() -> void:
	var outer := StaticBody2D.new()
	outer.name = "OuterWalls"
	outer.collision_layer = 1
	outer.collision_mask = 2
	var specs := [
		{"pos": Vector2(0, -234), "size": Vector2(680, 18)},
		{"pos": Vector2(0, 238), "size": Vector2(680, 18)},
		{"pos": Vector2(-324, 0), "size": Vector2(18, 490)},
		{"pos": Vector2(324, 0), "size": Vector2(18, 490)},
		# Southern Vault retaining wall blocking direct central jump to Beacon Vault
		{"pos": Vector2(110, -76), "size": Vector2(440, 18)},
		# Shadowed Passage east wall (with north exit doorway at y = -195..-140)
		{"pos": Vector2(-112, -104), "size": Vector2(14, 68)},
		# Shadowed Passage west & north walls
		{"pos": Vector2(-214, -110), "size": Vector2(18, 176)},
		{"pos": Vector2(-160, -196), "size": Vector2(116, 16)},
	]
	for sp in specs:
		var col := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = sp["size"]
		col.shape = rect
		col.position = sp["pos"]
		outer.add_child(col)
	$Boundary.add_child(outer)

	var crest_blocker := StaticBody2D.new()
	crest_blocker.name = "CrestPortcullisBlocker"
	crest_blocker.collision_layer = 1
	crest_blocker.collision_mask = 2
	crest_blocker_shape = CollisionShape2D.new()
	var c_rect := RectangleShape2D.new()
	c_rect.size = Vector2(96, 14)
	crest_blocker_shape.shape = c_rect
	crest_blocker_shape.position = Vector2(-160, -36)
	crest_blocker.add_child(crest_blocker_shape)
	$Boundary.add_child(crest_blocker)

	var exit_blocker := StaticBody2D.new()
	exit_blocker.name = "PassageExitBlocker"
	exit_blocker.collision_layer = 1
	exit_blocker.collision_mask = 2
	passage_exit_blocker_shape = CollisionShape2D.new()
	var e_rect := RectangleShape2D.new()
	e_rect.size = Vector2(14, 52)
	passage_exit_blocker_shape.shape = e_rect
	passage_exit_blocker_shape.position = Vector2(-112, -165)
	exit_blocker.add_child(passage_exit_blocker_shape)
	$Boundary.add_child(exit_blocker)

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

	if courtyard_monument != null:
		courtyard_monument.inspected = quest_manager.is_objective_completed("investigate_courtyard")
		courtyard_monument.queue_redraw()
	if warden_records != null:
		warden_records.inspected = quest_manager.warden_records_found
		warden_records.queue_redraw()
	if barracks_log != null:
		barracks_log.inspected = quest_manager.barracks_explored
		barracks_log.queue_redraw()
	if barracks_keepsake != null:
		barracks_keepsake.collected = quest_manager.optional_discoveries.has("wardens_locket")
		barracks_keepsake.queue_redraw()

	for clue_key in crest_clues.keys():
		var c_node: StaticBody2D = crest_clues[clue_key]
		c_node.inspected = quest_manager.crest_clues_found.has(clue_key)
		c_node.queue_redraw()

	var crest_ok: bool = quest_manager.crest_puzzle_solved
	if crest_blocker_shape != null:
		crest_blocker_shape.set_deferred("disabled", crest_ok)
		crest_blocker_shape.disabled = crest_ok
	if crest_altar != null:
		crest_altar.solved = crest_ok
		crest_altar.refresh_prompt("[E] INSPECT SOLVED CREST ALTAR" if crest_ok else ("[E] ALIGN WATCH CRESTS" if quest_manager.can_open_crest_puzzle() else "[E] EXAMINE HERALDIC ALTAR"))
		crest_altar.queue_redraw()
	$Landscape.crest_puzzle_solved = crest_ok
	var crest_panel := get_node_or_null("HUD/CrestPuzzle")
	if crest_panel != null:
		crest_panel.set("solved", crest_ok)

	var passage_ok: bool = quest_manager.shadow_passage_cleared
	if passage_exit_blocker_shape != null:
		passage_exit_blocker_shape.set_deferred("disabled", passage_ok)
		passage_exit_blocker_shape.disabled = passage_ok
	if shadow_ward_switch != null:
		shadow_ward_switch.solved = passage_ok
		shadow_ward_switch.refresh_prompt("[E] WARD LANTERN HARMONIZED" if passage_ok else "[E] HARMONIZE WARD LANTERN")
		shadow_ward_switch.queue_redraw()
	for s in sentinels:
		s.set("cleared", passage_ok)
		s.queue_redraw()
	$Landscape.shadow_passage_cleared = passage_ok
	$Landscape.active_checkpoint_id = quest_manager.stealth_checkpoint_id

	if elena_research != null:
		elena_research.inspected = quest_manager.elena_research_found
		elena_research.queue_redraw()

	var beacon_ok: bool = quest_manager.third_beacon_activated
	if third_beacon != null:
		third_beacon.activated = beacon_ok
		third_beacon.refresh_prompt("[E] EXAMINE CONNECTED BEACONS" if beacon_ok else ("[E] RESTORE THIRD BEACON" if quest_manager.can_activate_third_beacon() else "[E] INSPECT DORMANT BEACON"))
		third_beacon.queue_redraw()
	if vault_sanctum != null:
		vault_sanctum.set("third_beacon_lit", beacon_ok)
		vault_sanctum.queue_redraw()
	$Landscape.third_beacon_activated = beacon_ok

	if dawnspire_gate != null:
		dawnspire_gate.unlocked = quest_manager.dawnspire_unlocked
		if quest_manager.get_current_objective_id() == "complete_chapter3":
			dawnspire_gate.refresh_prompt("[E] COMPLETE CHAPTER 3")
		elif quest_manager.dawnspire_unlocked:
			dawnspire_gate.refresh_prompt("[E] EXAMINE DAWNSPIRE ROAD")
		else:
			dawnspire_gate.refresh_prompt("[E] INSPECT DAWNSPIRE GATE")
		dawnspire_gate.queue_redraw()

	if last_warden != null:
		var cur_id: String = quest_manager.get_current_objective_id()
		if cur_id == "confront_last_warden":
			last_warden.refresh_prompt("[E] CONFRONT LAST WARDEN")
		else:
			last_warden.refresh_prompt("[E] SPEAK WITH LAST WARDEN")

	# Position Historian Lyra cleanly along the active chapter wing without blocking interactables or paths
	if lyra != null:
		var obj_now: String = quest_manager.get_current_objective_id()
		if quest_manager.chapter3_completed or obj_now in ["confront_last_warden", "discover_elena_research", "restore_third_beacon", "unlock_dawnspire_road", "complete_chapter3"]:
			lyra.position = Vector2(-84, -104)
			lyra.facing = 2
		elif obj_now in ["navigate_shadowed_passage", "reach_wardens_chamber"]:
			lyra.position = Vector2(-98, -42)
			lyra.facing = 0
		elif obj_now in ["explore_barracks", "find_crest_clues", "solve_crest_puzzle"]:
			lyra.position = Vector2(-68, 86)
			lyra.facing = 2
		elif obj_now == "discover_warden_records":
			lyra.position = Vector2(126, 114)
			lyra.facing = 2
		else:
			lyra.position = Vector2(56, 214)
			lyra.facing = 2
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

func travel_to_floodmill() -> void:
	if is_inside_tree():
		QuestManagerScript.pending_entry_pose = true
		QuestManagerScript.pending_entry_position = Vector2(170, -172)
		QuestManagerScript.pending_entry_facing = 4
		get_tree().change_scene_to_file("res://scenes/floodmill_village.tscn")
