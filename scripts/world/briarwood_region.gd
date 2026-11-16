extends Node2D
## Main Chapter 1 scene controller populating Briarwood Forest subregions, Lyra, and progression state.

const PropScript = preload("res://scripts/world/briarwood_prop.gd")
const InteractableScript = preload("res://scripts/interactables/briarwood_interactable.gd")
const NpcScene = preload("res://scenes/characters/npc.tscn")
const QuestManagerScript = preload("res://scripts/systems/quest_manager.gd")
const AudioManagerScript = preload("res://scripts/systems/audio_manager.gd")

var quest_manager: Node
var lyra: StaticBody2D
var bridge_blocker_shape: CollisionShape2D

var waystone_entrance: StaticBody2D
var broken_bridge: StaticBody2D
var mirror_dais: StaticBody2D
var first_beacon: StaticBody2D
var floodmill_gate: StaticBody2D
var hidden_relic: StaticBody2D
var materials: Dictionary = {}
var inscriptions: Dictionary = {}

func _ready() -> void:
	# Generate full grass ground tiles covering all camera boundaries (-36..36)
	var ground: TileMapLayer = $Ground
	for x in range(-36, 37):
		for y in range(-36, 37):
			ground.set_cell(Vector2i(x, y), 0, Vector2i(posmod(x * 13 + y * 29, 3), 0))

	# Outer forest perimeter & atmospheric props (keeping trails and spots clear)
	var props := [
		[0, Vector2(-190, 228)], [0, Vector2(-130, 195)], [0, Vector2(145, 215)], [0, Vector2(215, 190)],
		[0, Vector2(-215, 125)], [1, Vector2(-160, 100)], [0, Vector2(235, 120)],
		[0, Vector2(-240, 20)], [0, Vector2(-210, -55)], [1, Vector2(35, 15)], [0, Vector2(250, 20)],
		[0, Vector2(265, -55)], [0, Vector2(-235, -135)], [0, Vector2(-205, -205)],
		[0, Vector2(-100, -238)], [0, Vector2(40, -252)], [0, Vector2(145, -250)],
		[0, Vector2(245, -195)], [0, Vector2(255, -110)], [1, Vector2(-60, 125)],
		[1, Vector2(68, 28)], [1, Vector2(242, 48)], [1, Vector2(142, -55)],
		[2, Vector2(-150, 150)], [2, Vector2(80, 130)], [2, Vector2(-160, -55)], [2, Vector2(56, -150)],
		[3, Vector2(-64, 154)], [3, Vector2(65, 24)], [3, Vector2(168, -162)],
		[4, Vector2(-62, -116)], [4, Vector2(42, -116)], [4, Vector2(-188, -124)],
		[5, Vector2(78, 170)], [5, Vector2(214, -152)], # Forest Edge & Ruined Camp tents
		[6, Vector2(-168, -158)], [6, Vector2(-132, -172)], [6, Vector2(-96, -158)], # Mirror Grove stands
		[7, Vector2(-140, 165)], [7, Vector2(85, 148)], [7, Vector2(-155, -12)], [7, Vector2(-50, -148)], [7, Vector2(165, -122)],
		[8, Vector2(-24, 185)], [8, Vector2(40, 118)], [8, Vector2(158, 95)], [8, Vector2(-104, -74)], [8, Vector2(-6, -178)],
	]
	for p in props:
		var node := StaticBody2D.new()
		node.set_script(PropScript)
		node.kind = p[0]
		node.position = p[1]
		$Actors.add_child(node)

	# Stream & Bridge physical barriers
	_build_stream_barriers()

	# Traveling Historian Lyra NPC
	lyra = NpcScene.instantiate() as StaticBody2D
	lyra.name = "Lyra"
	lyra.npc_id = "lyra"
	lyra.speaker_name = "HISTORIAN LYRA"
	lyra.prompt_text = "[E] TALK TO LYRA"
	lyra.position = Vector2(28, 172)
	lyra.facing = 4
	$Actors.add_child(lyra)

	# Interactive landmarks, clues, materials, minigames, and Shrine
	waystone_entrance = _spawn_interactable(
		"WaystoneEntrance", "waystone_entrance", "", "BRIARWOOD TRAIL STONE",
		"[E] INSPECT TRAIL WAYSTONE", Vector2(-36, 198), 10, ""
	)
	_spawn_interactable(
		"DirectionSign", "direction_sign", "", "WHISPERING FORK SIGN",
		"[E] READ SIGNPOST", Vector2(0, 80), 8,
		"NORTH-WEST: OLD BRIDGE AND SHRINE - EAST: CARPENTER WORKSITE - SOUTH: BELLHAVEN TRAIL"
	)
	broken_bridge = _spawn_interactable(
		"BrokenBridge", "broken_bridge", "", "OLD BRIDGE",
		"[E] INSPECT BROKEN BRIDGE", Vector2(-120, 12), 10, ""
	)
	_spawn_interactable(
		"WorksiteLedger", "worksite_ledger", "", "CARPENTER'S LEDGER",
		"[E] READ REPAIR PLAN", Vector2(138, 52), 9, ""
	)
	materials["plank_1"] = _spawn_interactable(
		"MaterialPlank1", "repair_material", "plank_1", "SEASONED OAK PLANK",
		"[E] TAKE LEFT BEAM OAK", Vector2(188, 38), 9,
		"Gathered a sturdy seasoned oak support beam (Left Beam) from the carpenter's rack."
	)
	materials["plank_2"] = _spawn_interactable(
		"MaterialPlank2", "repair_material", "plank_2", "WALKWAY OAK PLANK",
		"[E] TAKE RIGHT PLANK", Vector2(204, 106), 9,
		"Gathered a broad oak walkway plank (Right Plank) stacked beneath the saplings."
	)
	materials["rope_coil"] = _spawn_interactable(
		"MaterialRope", "repair_material", "rope_coil", "HEMP ROPE COIL",
		"[E] TAKE ROPE LASHING", Vector2(116, 126), 9,
		"Coiled a stout length of tarred hemp rope (Rope Lashing) onto Aren's satchel."
	)
	inscriptions["west"] = _spawn_interactable(
		"InscriptionWest", "inscription", "west", "WEST INSCRIPTION",
		"[E] READ WEST INSCRIPTION", Vector2(-176, -84), 9, ""
	)
	inscriptions["center"] = _spawn_interactable(
		"InscriptionCenter", "inscription", "center", "CENTER INSCRIPTION",
		"[E] READ CENTER INSCRIPTION", Vector2(8, -112), 9, ""
	)
	inscriptions["east"] = _spawn_interactable(
		"InscriptionEast", "inscription", "east", "EAST INSCRIPTION",
		"[E] READ EAST INSCRIPTION", Vector2(106, -98), 9, ""
	)
	mirror_dais = _spawn_interactable(
		"MirrorDais", "mirror_pedestal", "", "MIRROR GROVE DAIS",
		"[E] ALIGN ANCIENT MIRRORS", Vector2(-132, -144), 10, ""
	)
	first_beacon = _spawn_interactable(
		"FirstBeacon", "first_beacon", "", "FIRST ANCIENT BEACON",
		"[E] APPROACH FIRST BEACON", Vector2(-32, -216), 11, ""
	)
	hidden_relic = _spawn_interactable(
		"HiddenRelic", "hidden_relic", "ruined_camp_relic", "RUINED SURVEY CHEST",
		"[E] SEARCH RUINED CAMP", Vector2(192, -138), 8, ""
	)
	floodmill_gate = _spawn_interactable(
		"FloodmillGate", "floodmill_gate", "", "FLOODMILL TRAIL GATE",
		"[E] INSPECT FLOODMILL GATE", Vector2(168, -196), 9, ""
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

	# Chapter 1 QuestManager & HUD setup
	quest_manager = QuestManagerScript.new()
	quest_manager.name = "QuestManager"
	quest_manager.quest_data_path = "res://data/chapter1_quest.json"
	add_child(quest_manager)
	quest_manager.objective_completed.connect(_on_objective_completed)

	$HUD.player = $Actors/Player
	$HUD.terminal = waystone_entrance
	$HUD.bind_quest_manager(quest_manager)
	$HUD/Subtitle.text = "BRIARWOOD FOREST"
	$HUD/Clock.text = "CHAPTER 1"
	$Actors/Player/Camera2D.framing = Vector2(0, -48)
	$Actors/Player/Camera2D.snap_to_target()
	if QuestManagerScript.carry_prologue_completed:
		quest_manager.prologue_completed = true
		quest_manager.briarwood_unlocked = true
		quest_manager.letter_found = true
		quest_manager.puzzle_solved = true
		quest_manager.talked_npcs = {"caelen": true, "mira": true, "elara": true}
		QuestManagerScript.carry_prologue_completed = false
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
	AudioManagerScript.play_global_region(get_tree(), "briarwood")
	$HUD.play_region_transition("BRIARWOOD FOREST", "CHAPTER 1 - WHISPERS OF BRIARWOOD")

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

func _build_stream_barriers() -> void:
	var river := StaticBody2D.new()
	river.name = "RiverBarrier"
	river.collision_layer = 1
	river.collision_mask = 2
	var west_shape := CollisionShape2D.new()
	var w_rect := RectangleShape2D.new()
	w_rect.size = Vector2(340, 28)
	west_shape.shape = w_rect
	west_shape.position = Vector2(-294, -20)
	river.add_child(west_shape)
	var east_shape := CollisionShape2D.new()
	var e_rect := RectangleShape2D.new()
	e_rect.size = Vector2(520, 28)
	east_shape.shape = e_rect
	east_shape.position = Vector2(204, -20)
	river.add_child(east_shape)
	add_child(river)

	var blocker := StaticBody2D.new()
	blocker.name = "BridgeBlocker"
	blocker.collision_layer = 1
	blocker.collision_mask = 2
	bridge_blocker_shape = CollisionShape2D.new()
	bridge_blocker_shape.name = "Shape"
	var b_rect := RectangleShape2D.new()
	b_rect.size = Vector2(68, 28)
	bridge_blocker_shape.shape = b_rect
	bridge_blocker_shape.position = Vector2(-90, -20)
	blocker.add_child(bridge_blocker_shape)
	add_child(blocker)

func _on_objective_completed(_objective_id: String) -> void:
	_sync_world_from_quest()

func _sync_world_from_quest() -> void:
	if quest_manager == null:
		return
	for mat_key in materials.keys():
		var mat_node: StaticBody2D = materials[mat_key]
		mat_node.collected = quest_manager.materials_collected.has(mat_key)
		mat_node.queue_redraw()
	for insc_key in inscriptions.keys():
		var insc_node: StaticBody2D = inscriptions[insc_key]
		insc_node.inspected = quest_manager.inscriptions_read.has(insc_key)
		insc_node.queue_redraw()
	if hidden_relic != null:
		hidden_relic.collected = quest_manager.optional_discoveries.has("ruined_camp_relic")
		hidden_relic.queue_redraw()

	var bridge_ok: bool = quest_manager.bridge_repaired
	if bridge_blocker_shape != null:
		bridge_blocker_shape.set_deferred("disabled", bridge_ok)
		bridge_blocker_shape.disabled = bridge_ok
	if broken_bridge != null:
		broken_bridge.repaired = bridge_ok
		broken_bridge.refresh_prompt("[E] INSPECT REPAIRED BRIDGE" if bridge_ok else ("[E] REPAIR OLD BRIDGE" if quest_manager.can_open_bridge_repair() else "[E] INSPECT BROKEN BRIDGE"))
		broken_bridge.queue_redraw()
	$Landscape.bridge_repaired = bridge_ok
	var bridge_panel := get_node_or_null("HUD/BridgeRepair")
	if bridge_panel != null:
		bridge_panel.set("repaired", bridge_ok)

	var mirror_ok: bool = quest_manager.mirror_puzzle_solved
	if mirror_dais != null:
		mirror_dais.activated = mirror_ok
		mirror_dais.queue_redraw()
	$Landscape.mirror_solved = mirror_ok
	var mirror_panel := get_node_or_null("HUD/MirrorPuzzle")
	if mirror_panel != null:
		mirror_panel.set("solved", mirror_ok)

	var beacon_ok: bool = quest_manager.beacon_activated
	if first_beacon != null:
		first_beacon.activated = beacon_ok
		if quest_manager.get_current_objective_id() == "experience_elena_recording":
			first_beacon.refresh_prompt("[E] TOUCH ELENA'S ECHO")
		elif beacon_ok:
			first_beacon.refresh_prompt("[E] EXAMINE FIRST BEACON")
		elif mirror_ok:
			first_beacon.refresh_prompt("[E] ACTIVATE FIRST BEACON")
		first_beacon.queue_redraw()
	$Landscape.beacon_activated = beacon_ok

	if floodmill_gate != null:
		floodmill_gate.unlocked = quest_manager.floodmill_unlocked
		floodmill_gate.ready_to_travel = false
		floodmill_gate.refresh_prompt("[E] INSPECT FLOODMILL GATE")
		floodmill_gate.queue_redraw()

	# Predefined story locations for Historian Lyra
	if lyra != null:
		if mirror_ok:
			lyra.position = Vector2(28, -206)
			lyra.facing = 4
		elif bridge_ok:
			lyra.position = Vector2(-40, -76)
			lyra.facing = 2
		else:
			lyra.position = Vector2(28, 172)
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

func travel_to_bellhaven() -> void:
	if is_inside_tree():
		QuestManagerScript.pending_entry_pose = true
		QuestManagerScript.pending_entry_position = Vector2(-170, 168)
		QuestManagerScript.pending_entry_facing = 0
		get_tree().change_scene_to_file("res://scenes/sjt_exterior.tscn")

func travel_to_floodmill() -> void:
	if quest_manager != null and quest_manager.floodmill_unlocked and is_inside_tree():
		QuestManagerScript.carry_prologue_completed = true
		QuestManagerScript.carry_chapter1_completed = true
		QuestManagerScript.carry_optional_discoveries = quest_manager.optional_discoveries.duplicate()
		QuestManagerScript.pending_entry_pose = false
		get_tree().change_scene_to_file("res://scenes/floodmill_village.tscn")
