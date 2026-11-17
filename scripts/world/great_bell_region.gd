extends Node2D
## Main Chapter 5 scene controller for the Great Bell Sanctum and Finale Epilogue.
## Areas A-D: The Bell Antechamber, Hall of Forgotten Names, The Heart of the Bell, and The Dawn Terrace.

const BuildingScript = preload("res://scripts/world/great_bell_building.gd")
const PropScript = preload("res://scripts/world/great_bell_prop.gd")
const InteractableScript = preload("res://scripts/interactables/great_bell_interactable.gd")
const NpcScene = preload("res://scenes/characters/npc.tscn")
const QuestManagerScript = preload("res://scripts/systems/quest_manager.gd")
const AudioManagerScript = preload("res://scripts/systems/audio_manager.gd")

var quest_manager: Node
var lyra: StaticBody2D

var heart_blocker_shape: CollisionShape2D
var terrace_blocker_shape: CollisionShape2D

var dawnspire_return_gate: StaticBody2D
var antechamber_threshold: StaticBody2D
var forgotten_hall_arch: StaticBody2D
var memory_frags: Dictionary = {}
var warden_complete_record: StaticBody2D
var elena_final_echo: StaticBody2D
var great_bell_binding: StaticBody2D
var conduits: Dictionary = {}
var dawn_terrace_overlook: StaticBody2D
var dawn_memorial: StaticBody2D
var bellhaven_sunrise_arch: StaticBody2D

var great_bell_monolith_bldg: StaticBody2D
var approach_positions: Array[Vector2] = []
var atmosphere_modulate: CanvasModulate

func _build_great_bell_world() -> void:
	_build_boundaries()

	# Atmosphere lighting node shifted warmly when storm resolves
	atmosphere_modulate = CanvasModulate.new()
	atmosphere_modulate.name = "AtmosphereModulate"
	atmosphere_modulate.color = Color(0.88, 0.90, 0.98, 1.0)
	add_child(atmosphere_modulate)

	# Sanctum Archways & Landmarks (positioned clear of walkable doorways and interactables)
	_spawn_building("AntechamberArch", "sanctum_arch", Vector2(-176, 128))
	_spawn_building("HeartArch", "sanctum_arch", Vector2(30, -2))
	_spawn_building("WardenSteleBack", "warden_stele", Vector2(-24, 24))
	great_bell_monolith_bldg = _spawn_building("GreatBellMonolith", "great_bell_monolith", Vector2(30, -104))

	# Environmental Storytelling Props
	_spawn_prop("AntechamberBrazierWest", "sanctum_brazier", Vector2(-248, 166))
	_spawn_prop("AntechamberBrazierEast", "sanctum_brazier", Vector2(-56, 166))
	_spawn_prop("HallCrystalWest", "crystal_column", Vector2(-290, 26))
	_spawn_prop("HallCrystalMid", "crystal_column", Vector2(-132, 22))
	_spawn_prop("HallCrystalEast", "crystal_column", Vector2(88, 22))
	_spawn_prop("HeartChainNorthWest", "chain_pylon", Vector2(-92, -158))
	_spawn_prop("HeartChainNorthEast", "chain_pylon", Vector2(150, -158))
	_spawn_prop("HeartChainSouthWest", "sanctum_brazier", Vector2(-96, -24))
	_spawn_prop("HeartChainSouthEast", "sanctum_brazier", Vector2(150, -24))

	# Historian Lyra companion
	lyra = NpcScene.instantiate()
	lyra.name = "Lyra"
	lyra.npc_id = "lyra"
	lyra.speaker_name = "HISTORIAN LYRA"
	lyra.prompt_text = "[E] SPEAK WITH LYRA"
	lyra.interaction_priority = 8
	lyra.position = Vector2(-88, 202)
	lyra.facing = 4
	$Actors.add_child(lyra)

	# Core Story, Memory, Ritual & Epilogue Interactables
	dawnspire_return_gate = _spawn_interactable(
		"DawnspireReturnGate", "sanctum_dawnspire_gate", "", "GREAT BELL THRESHOLD",
		"[E] RETURN TO DAWNSPIRE SUMMIT", Vector2(-264, 214), 6, ""
	)
	antechamber_threshold = _spawn_interactable(
		"AntechamberThreshold", "antechamber_threshold", "", "THE BELL ANTECHAMBER",
		"[E] ENTER THE GREAT BELL CHAMBER", Vector2(-152, 184), 10, ""
	)
	forgotten_hall_arch = _spawn_interactable(
		"ForgottenHallArch", "forgotten_hall_arch", "", "HALL OF FORGOTTEN NAMES",
		"[E] INVESTIGATE FORGOTTEN HALL", Vector2(-176, 86), 10, ""
	)
	memory_frags["frag_home"] = _spawn_interactable(
		"MemoryFragHome", "memory_crystal", "frag_home", "MEMORY FRAGMENT I - THE HOME",
		"[E] RECOVER MEMORY FRAGMENT (1/3)", Vector2(-254, 64), 10, ""
	)
	memory_frags["frag_promise"] = _spawn_interactable(
		"MemoryFragPromise", "memory_crystal", "frag_promise", "MEMORY FRAGMENT II - THE PROMISE",
		"[E] RECOVER MEMORY FRAGMENT (2/3)", Vector2(-176, 30), 10, ""
	)
	memory_frags["frag_sacrifice"] = _spawn_interactable(
		"MemoryFragSacrifice", "memory_crystal", "frag_sacrifice", "MEMORY FRAGMENT III - THE SACRIFICE",
		"[E] RECOVER MEMORY FRAGMENT (3/3)", Vector2(-86, 44), 10, ""
	)
	warden_complete_record = _spawn_interactable(
		"WardenCompleteRecord", "warden_record", "", "BELL WARDENS' COMPLETE RECORD",
		"[E] REVEAL COMPLETE RECORD", Vector2(-24, 52), 10, ""
	)
	elena_final_echo = _spawn_interactable(
		"ElenaFinalEcho", "elena_echo_plinth", "", "ELENA'S FINAL MESSAGE",
		"[E] HEAR ELENA'S FINAL MESSAGE", Vector2(44, 48), 11, ""
	)
	great_bell_binding = _spawn_interactable(
		"GreatBellBinding", "great_bell_binding", "", "HEART OF THE GREAT BELL",
		"[E] EXAMINE MEMORY BINDING", Vector2(30, -76), 11, ""
	)
	conduits["conduit_briarwood"] = _spawn_interactable(
		"ConduitBriarwood", "beacon_conduit", "conduit_briarwood", "FIRST CONDUIT - BRIARWOOD DAWN",
		"[E] ACTIVATE BRIARWOOD CONDUIT", Vector2(-96, -84), 10, ""
	)
	conduits["conduit_floodmill"] = _spawn_interactable(
		"ConduitFloodmill", "beacon_conduit", "conduit_floodmill", "SECOND CONDUIT - FLOODMILL TIDE",
		"[E] ACTIVATE FLOODMILL CONDUIT", Vector2(30, -154), 10, ""
	)
	conduits["conduit_ironwatch"] = _spawn_interactable(
		"ConduitIronwatch", "beacon_conduit", "conduit_ironwatch", "THIRD CONDUIT - IRONWATCH CROWN",
		"[E] ACTIVATE IRONWATCH CONDUIT", Vector2(150, -84), 10, ""
	)
	dawn_terrace_overlook = _spawn_interactable(
		"DawnTerraceOverlook", "dawn_terrace_overlook", "", "THE DAWN TERRACE",
		"[E] LOOK OUT OVER ASHVALE", Vector2(236, -110), 9, ""
	)
	dawn_memorial = _spawn_interactable(
		"DawnMemorial", "dawn_memorial", "", "MEMORIAL OF REMEMBERED NAMES",
		"[E] PLACE ELENA'S JOURNAL AT MEMORIAL", Vector2(298, -84), 11, ""
	)
	bellhaven_sunrise_arch = _spawn_interactable(
		"BellhavenSunriseArch", "bellhaven_sunrise_arch", "", "ASHVALE SUNRISE DESCENT",
		"[E] RETURN TO BELLHAVEN AT SUNRISE", Vector2(318, -32), 9, ""
	)

	approach_positions = [
		Vector2(-236, 214),
		Vector2(-152, 206),
		Vector2(-112, 202),
		Vector2(-176, 108),
		Vector2(-226, 64),
		Vector2(-176, 54),
		Vector2(-86, 68),
		Vector2(-24, 76),
		Vector2(44, 74),
		Vector2(30, -50),
		Vector2(-68, -84),
		Vector2(30, -130),
		Vector2(124, -84),
		Vector2(236, -86),
		Vector2(270, -84),
		Vector2(296, -32),
	]

func _ready() -> void:
	_build_great_bell_world()

	quest_manager = QuestManagerScript.new()
	quest_manager.name = "QuestManager"
	quest_manager.quest_data_path = QuestManagerScript.CHAPTER5_DATA_PATH
	add_child(quest_manager)
	quest_manager.objective_changed.connect(_on_objective_changed)
	quest_manager.objective_completed.connect(_on_objective_completed)

	$HUD.player = $Actors/Player
	$HUD.terminal = antechamber_threshold
	$HUD.bind_quest_manager(quest_manager)
	$HUD/Subtitle.text = "THE GREAT BELL SANCTUM"
	$HUD/Clock.text = "FINAL CHAPTER"
	$Actors/Player.facing = 0
	$Actors/Player/Camera2D.framing = Vector2(0, -40)
	$Actors/Player/Camera2D.set_camera_limits(-355, -275, 480, 275)
	$Actors/Player/Camera2D.snap_to_target()

	if QuestManagerScript.pending_load_path == "":
		if not QuestManagerScript.pending_chapter5_snapshot.is_empty():
			var snap: Dictionary = QuestManagerScript.pending_chapter5_snapshot
			QuestManagerScript.pending_chapter5_snapshot = {}
			quest_manager.apply_state(snap, false)
		else:
			QuestManagerScript.restore_into_region_quest(quest_manager, QuestManagerScript.CHAPTER5_DATA_PATH, "chapter5_the_last_bell", "chapter5_completed")
	else:
		QuestManagerScript.pending_chapter5_snapshot = {}
	_apply_carry_flags()

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
	_update_region_audio()
	if quest_manager.storm_resolved or quest_manager.chapter5_completed:
		$HUD.play_region_transition("THE DAWN TERRACE", "EPILOGUE - ASHVALE REMEMBERED")
	else:
		$HUD.play_region_transition("THE GREAT BELL SANCTUM", "CHAPTER 5 - THE LAST BELL")

func _apply_carry_flags() -> void:
	if quest_manager == null:
		return
	if QuestManagerScript.carry_prologue_completed:
		quest_manager.prologue_completed = true
		quest_manager.briarwood_unlocked = true
		QuestManagerScript.carry_prologue_completed = false
	if QuestManagerScript.carry_chapter1_completed:
		quest_manager.chapter1_completed = true
		quest_manager.floodmill_unlocked = true
		quest_manager.beacon_activated = true
		QuestManagerScript.carry_chapter1_completed = false
	if QuestManagerScript.carry_chapter2_completed:
		quest_manager.chapter2_completed = true
		quest_manager.ironwatch_unlocked = true
		quest_manager.second_beacon_activated = true
		QuestManagerScript.carry_chapter2_completed = false
	if QuestManagerScript.carry_chapter3_completed:
		quest_manager.chapter3_completed = true
		quest_manager.dawnspire_unlocked = true
		quest_manager.third_beacon_activated = true
		QuestManagerScript.carry_chapter3_completed = false
	if QuestManagerScript.carry_chapter4_completed:
		quest_manager.chapter4_completed = true
		quest_manager.great_bell_gate_unlocked = true
		quest_manager.beacons_synchronized = true
		quest_manager.sanctuary_revelation_witnessed = true
		quest_manager.chapter5_active = true
		QuestManagerScript.carry_chapter4_completed = false
	if not QuestManagerScript.carry_optional_discoveries.is_empty():
		for k in QuestManagerScript.carry_optional_discoveries.keys():
			quest_manager.optional_discoveries[k] = true
		QuestManagerScript.carry_optional_discoveries.clear()

func _build_boundaries() -> void:
	var outer := StaticBody2D.new()
	outer.name = "OuterWalls"
	outer.collision_layer = 1
	outer.collision_mask = 2
	var specs := [
		# Exterior Sanctum Perimeter
		{"pos": Vector2(-320, 123), "size": Vector2(16, 266)},
		{"pos": Vector2(2, 192), "size": Vector2(16, 128)},
		{"pos": Vector2(-159, 248), "size": Vector2(338, 16)},
		{"pos": Vector2(114, 63), "size": Vector2(16, 130)},
		{"pos": Vector2(-170, -99), "size": Vector2(16, 194)},
		{"pos": Vector2(15, -190), "size": Vector2(390, 16)},
		{"pos": Vector2(277, -152), "size": Vector2(158, 16)},
		{"pos": Vector2(277, -10), "size": Vector2(158, 16)},
		{"pos": Vector2(350, -80), "size": Vector2(16, 160)},
		# Area A / Area B Dividing Wall (opening x = -212..-140)
		{"pos": Vector2(-271, 128), "size": Vector2(118, 16)},
		{"pos": Vector2(110, 128), "size": Vector2(500, 16)},
		# Area B / Area C Dividing Wall (opening x = -6..66)
		{"pos": Vector2(-168, -2), "size": Vector2(324, 16)},
		{"pos": Vector2(213, -2), "size": Vector2(294, 16)},
		# Area C / Area D Dividing Wall (opening y = -110..-46)
		{"pos": Vector2(198, -153), "size": Vector2(16, 86)},
		{"pos": Vector2(198, 105), "size": Vector2(16, 302)},
	]
	for sp in specs:
		var col := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = sp["size"]
		col.shape = rect
		col.position = sp["pos"]
		outer.add_child(col)
	$Boundary.add_child(outer)

	var heart_blocker := StaticBody2D.new()
	heart_blocker.name = "HeartChamberBlocker"
	heart_blocker.collision_layer = 1
	heart_blocker.collision_mask = 2
	heart_blocker_shape = CollisionShape2D.new()
	var hb_rect := RectangleShape2D.new()
	hb_rect.size = Vector2(76, 16)
	heart_blocker_shape.shape = hb_rect
	heart_blocker_shape.position = Vector2(30, -2)
	heart_blocker.add_child(heart_blocker_shape)
	$Boundary.add_child(heart_blocker)

	var terrace_blocker := StaticBody2D.new()
	terrace_blocker.name = "DawnTerraceBlocker"
	terrace_blocker.collision_layer = 1
	terrace_blocker.collision_mask = 2
	terrace_blocker_shape = CollisionShape2D.new()
	var tb_rect := RectangleShape2D.new()
	tb_rect.size = Vector2(16, 68)
	terrace_blocker_shape.shape = tb_rect
	terrace_blocker_shape.position = Vector2(198, -78)
	terrace_blocker.add_child(terrace_blocker_shape)
	$Boundary.add_child(terrace_blocker)

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

func _update_region_audio() -> void:
	if quest_manager != null and (quest_manager.binding_severed or quest_manager.storm_resolved):
		AudioManagerScript.play_global_region(get_tree(), "epilogue_dawn")
	else:
		AudioManagerScript.play_global_region(get_tree(), "great_bell")
	if is_inside_tree() and quest_manager != null:
		var audio_mgr := AudioManagerScript.ensure(get_tree())
		if audio_mgr != null and audio_mgr.has_method("sync_quest_music_state"):
			audio_mgr.sync_quest_music_state(quest_manager)

func _sync_world_from_quest() -> void:
	if quest_manager == null:
		return

	if antechamber_threshold != null:
		antechamber_threshold.inspected = quest_manager.great_bell_chamber_entered
		antechamber_threshold.refresh_prompt("[E] SURVEY THE ANTECHAMBER" if antechamber_threshold.inspected else "[E] ENTER THE GREAT BELL CHAMBER")
		antechamber_threshold.queue_redraw()
	if forgotten_hall_arch != null:
		forgotten_hall_arch.inspected = quest_manager.forgotten_hall_investigated
		forgotten_hall_arch.refresh_prompt("[E] EXAMINE FORGOTTEN HALL ARCH" if forgotten_hall_arch.inspected else "[E] INVESTIGATE FORGOTTEN HALL")
		forgotten_hall_arch.queue_redraw()

	for fid in memory_frags.keys():
		var f_node: StaticBody2D = memory_frags[fid]
		f_node.collected = quest_manager.memory_fragments_recovered.has(fid)
		f_node.queue_redraw()

	if warden_complete_record != null:
		warden_complete_record.inspected = quest_manager.warden_record_revealed
		warden_complete_record.refresh_prompt("[E] READ COMPLETE WARDEN RECORD" if warden_complete_record.inspected else "[E] REVEAL COMPLETE RECORD")
		warden_complete_record.queue_redraw()
	if elena_final_echo != null:
		elena_final_echo.inspected = quest_manager.elena_final_message_heard
		elena_final_echo.refresh_prompt("[E] REMEMBER ELENA'S ECHO" if elena_final_echo.inspected else "[E] HEAR ELENA'S FINAL MESSAGE")
		elena_final_echo.queue_redraw()

	if heart_blocker_shape != null:
		heart_blocker_shape.set_deferred("disabled", quest_manager.elena_final_message_heard)
		heart_blocker_shape.disabled = quest_manager.elena_final_message_heard

	for cid in conduits.keys():
		var c_node: StaticBody2D = conduits[cid]
		c_node.activated = quest_manager.beacon_conduits_activated.has(cid)
		c_node.queue_redraw()

	if great_bell_binding != null:
		great_bell_binding.inspected = quest_manager.memory_binding_examined
		great_bell_binding.stabilized = quest_manager.protective_network_stabilized
		great_bell_binding.severed = quest_manager.binding_severed
		var g_obj: String = quest_manager.get_current_objective_id()
		if g_obj == "examine_memory_binding":
			great_bell_binding.refresh_prompt("[E] EXAMINE MEMORY BINDING")
		elif g_obj == "activate_beacon_conduits":
			great_bell_binding.refresh_prompt("[E] CHECK CONDUIT STATUS (%d/3)" % quest_manager.get_activated_beacon_conduit_count())
		elif g_obj == "stabilize_protective_network":
			great_bell_binding.refresh_prompt("[E] STABILIZE PROTECTIVE NETWORK")
		elif g_obj == "sever_memory_binding":
			great_bell_binding.refresh_prompt("[E] SEVER MEMORY BINDING")
		elif g_obj == "witness_last_bell_cinematic":
			great_bell_binding.refresh_prompt("[E] WITNESS THE LAST BELL")
		else:
			great_bell_binding.refresh_prompt("[E] EXAMINE SILENT GREAT BELL")
		great_bell_binding.queue_redraw()

	if great_bell_monolith_bldg != null:
		great_bell_monolith_bldg.set("binding_severed", quest_manager.binding_severed)
		great_bell_monolith_bldg.set("network_stabilized", quest_manager.protective_network_stabilized)
		great_bell_monolith_bldg.set("storm_resolved", quest_manager.storm_resolved)
		great_bell_monolith_bldg.queue_redraw()

	if terrace_blocker_shape != null:
		terrace_blocker_shape.set_deferred("disabled", quest_manager.last_bell_cinematic_seen)
		terrace_blocker_shape.disabled = quest_manager.last_bell_cinematic_seen

	if dawn_terrace_overlook != null:
		dawn_terrace_overlook.inspected = quest_manager.dawn_terrace_returned
		dawn_terrace_overlook.queue_redraw()
	if dawn_memorial != null:
		dawn_memorial.journal_placed = quest_manager.elena_journal_placed
		if quest_manager.epilogue_completed:
			dawn_memorial.refresh_prompt("[E] READ MEMORIAL INSCRIPTION")
		else:
			dawn_memorial.refresh_prompt("[E] PLACE ELENA'S JOURNAL AT MEMORIAL")
		dawn_memorial.queue_redraw()

	if lyra != null:
		var obj_now: String = quest_manager.get_current_objective_id()
		if quest_manager.last_bell_cinematic_seen or obj_now in ["return_to_dawn_terrace", "complete_final_epilogue", "display_ending_credits", "completed"]:
			lyra.position = Vector2(258, -46)
			lyra.facing = 6
		elif quest_manager.elena_final_message_heard or obj_now in ["examine_memory_binding", "activate_beacon_conduits", "stabilize_protective_network", "sever_memory_binding", "witness_last_bell_cinematic"]:
			lyra.position = Vector2(-28, -42)
			lyra.facing = 7
		elif quest_manager.forgotten_hall_investigated or obj_now in ["recover_memory_fragments", "reveal_warden_record", "discover_elena_final_message"]:
			lyra.position = Vector2(-126, 76)
			lyra.facing = 7
		else:
			lyra.position = Vector2(-88, 202)
			lyra.facing = 4
		lyra.queue_redraw()

	if atmosphere_modulate != null:
		atmosphere_modulate.color = Color(1.04, 0.98, 0.89, 1.0) if quest_manager.storm_resolved else Color(0.88, 0.90, 0.98, 1.0)

	$Landscape.memory_fragments_count = quest_manager.get_recovered_memory_fragment_count()
	$Landscape.elena_message_heard = quest_manager.elena_final_message_heard
	$Landscape.conduit_briarwood = quest_manager.beacon_conduits_activated.has("conduit_briarwood")
	$Landscape.conduit_floodmill = quest_manager.beacon_conduits_activated.has("conduit_floodmill")
	$Landscape.conduit_ironwatch = quest_manager.beacon_conduits_activated.has("conduit_ironwatch")
	$Landscape.network_stabilized = quest_manager.protective_network_stabilized
	$Landscape.binding_severed = quest_manager.binding_severed
	$Landscape.storm_resolved = quest_manager.storm_resolved
	$Landscape.elena_journal_placed = quest_manager.elena_journal_placed
	$Landscape.queue_redraw()
	_update_region_audio()

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

func travel_to_dawnspire() -> void:
	if not is_inside_tree() or quest_manager == null:
		return
	QuestManagerScript.carry_prologue_completed = true
	QuestManagerScript.carry_chapter1_completed = true
	QuestManagerScript.carry_chapter2_completed = true
	QuestManagerScript.carry_chapter3_completed = true
	QuestManagerScript.carry_chapter4_completed = quest_manager.chapter4_completed
	QuestManagerScript.carry_optional_discoveries = quest_manager.optional_discoveries.duplicate()
	QuestManagerScript.begin_region_travel(get_tree(), quest_manager, "res://scenes/dawnspire_mountain.tscn", Vector2(96, -172), 2, true)

func travel_to_bellhaven_sunrise() -> void:
	if not is_inside_tree() or quest_manager == null or not (quest_manager.storm_resolved or quest_manager.chapter5_completed):
		return
	QuestManagerScript.carry_storm_resolved = true
	QuestManagerScript.carry_chapter4_completed = true
	QuestManagerScript.carry_optional_discoveries = quest_manager.optional_discoveries.duplicate()
	QuestManagerScript.pending_chapter5_snapshot = quest_manager.capture_state()
	QuestManagerScript.begin_region_travel(get_tree(), quest_manager, "res://scenes/sjt_exterior.tscn", Vector2(-10, 114), 6, true)
