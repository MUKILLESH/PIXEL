extends Node2D
const Prop = preload("res://scripts/world/prop.gd")
const BellhavenTree = preload("res://scripts/world/bellhaven_tree.gd")
const Landmark = preload("res://scripts/world/sjt_landmark.gd")
const Furniture = preload("res://scripts/world/campus_furniture.gd")
const QuestManagerScript = preload("res://scripts/systems/quest_manager.gd")
const AudioManagerScript = preload("res://scripts/systems/audio_manager.gd")
const NpcScene = preload("res://scenes/characters/npc.tscn")
const InteractableScene = preload("res://scenes/environment/terminal.tscn")

var quest_manager: Node
var mothers_letter: StaticBody2D
var briarwood_gate: StaticBody2D
var village_memorial: StaticBody2D
var dawn_terrace_arch: StaticBody2D
var lyra_bellhaven: StaticBody2D
var sunrise_modulate: CanvasModulate

func _ready() -> void:
	var ground: TileMapLayer = $Ground
	ground.tile_set = preload("res://assets/tiles/bellhaven/meadow.tres")
	for x in range(-28, 29):
		for y in range(-28, 29):
			ground.set_cell(Vector2i(x, y), 0, Vector2i(posmod((x*374761+y*668265) ^ ((x+29)*(y+31)*127),6), 0))
	for point: Vector2 in [Vector2(-240,-30),Vector2(-230,100),Vector2(-140,125),Vector2(220,-50),Vector2(245,80),Vector2(175,215),Vector2(-170,235),Vector2(-310,35),Vector2(280,5),Vector2(-160,-170),Vector2(85,-190),Vector2(300,170)]:
		var tree := StaticBody2D.new()
		tree.set_script(BellhavenTree)
		tree.position = point
		$Actors.add_child(tree)
	var furnishings: Array = [
		[0,Vector2(-80,155)],[0,Vector2(205,180)],[0,Vector2(-235,55)],
		[1,Vector2(-190,100)],[1,Vector2(105,110)],[1,Vector2(230,100)],[1,Vector2(-260,10)],
		[2,Vector2(85,125)],[2,Vector2(-90,90)],[2,Vector2(195,160)],
		[3,Vector2(230,190)],[3,Vector2(-105,155)]
	]
	for entry: Array in furnishings:
		var furnishing := StaticBody2D.new()
		furnishing.set_script(Furniture)
		furnishing.set("kind", entry[0])
		furnishing.position = entry[1]
		furnishing.name = "Furniture%d" % $Actors.get_child_count()
		$Actors.add_child(furnishing)
	for index in range(2):
		var landmark := StaticBody2D.new()
		landmark.set_script(Landmark)
		landmark.set("kind", index)
		landmark.position = Vector2(30, 150) if index == 0 else Vector2(30, 103)
		landmark.name = "Basin" if index == 0 else "Monument"
		$Actors.add_child(landmark)

	# Bellhaven Village prologue NPCs
	var npc_specs := [
		{"name": "MasterCaelen", "id": "caelen", "speaker": "MASTER CAELEN", "prompt": "[E] TALK TO MASTER CAELEN", "pos": Vector2(62, 56), "facing": 2},
		{"name": "Mira", "id": "mira", "speaker": "MIRA THE BLACKSMITH", "prompt": "[E] TALK TO MIRA", "pos": Vector2(104, -36), "facing": 2},
		{"name": "SisterElara", "id": "elara", "speaker": "SISTER ELARA", "prompt": "[E] TALK TO SISTER ELARA", "pos": Vector2(-22, 138), "facing": 0},
	]
	for spec: Dictionary in npc_specs:
		var npc := NpcScene.instantiate() as StaticBody2D
		npc.name = spec["name"]
		npc.npc_id = spec["id"]
		npc.speaker_name = spec["speaker"]
		npc.prompt_text = spec["prompt"]
		npc.position = spec["pos"]
		npc.facing = spec["facing"]
		$Actors.add_child(npc)

	# Story interactables: Mother's sealed survey chest and the Briarwood Waystone
	mothers_letter = InteractableScene.instantiate() as StaticBody2D
	mothers_letter.name = "MothersLetter"
	mothers_letter.role = 2
	mothers_letter.interaction_priority = 9
	mothers_letter.prompt_text = "[E] INSPECT SEALED CHEST"
	mothers_letter.position = Vector2(-88, 38)
	$Actors.add_child(mothers_letter)

	briarwood_gate = InteractableScene.instantiate() as StaticBody2D
	briarwood_gate.name = "BriarwoodGate"
	briarwood_gate.role = 3
	briarwood_gate.interaction_priority = 9
	briarwood_gate.prompt_text = "[E] INSPECT BRIARWOOD WAYSTONE"
	briarwood_gate.position = Vector2(-198, 178)
	$Actors.add_child(briarwood_gate)

	var corners := PackedVector2Array([Vector2(0,-320),Vector2(672,16),Vector2(0,352),Vector2(-672,16)])
	for i in range(4):
		var edge := StaticBody2D.new()
		var collision := CollisionShape2D.new()
		var segment := SegmentShape2D.new()
		segment.a = corners[i]
		segment.b = corners[(i + 1) % 4]
		collision.shape = segment
		edge.add_child(collision)
		$Boundary.add_child(edge)

	sunrise_modulate = CanvasModulate.new()
	sunrise_modulate.name = "SunriseModulate"
	sunrise_modulate.color = Color(1.0, 1.0, 1.0, 1.0)
	add_child(sunrise_modulate)

	quest_manager = QuestManagerScript.new()
	quest_manager.name = "QuestManager"
	add_child(quest_manager)
	quest_manager.objective_completed.connect(_on_objective_completed)

	if not QuestManagerScript.pending_chapter5_snapshot.is_empty():
		var snap: Dictionary = QuestManagerScript.pending_chapter5_snapshot
		QuestManagerScript.pending_chapter5_snapshot = {}
		quest_manager.apply_state(snap)
	if QuestManagerScript.carry_storm_resolved:
		quest_manager.storm_resolved = true
		QuestManagerScript.carry_storm_resolved = false

	$HUD.player = $Actors/Player
	$HUD.terminal = $Actors/Terminal
	$HUD.bind_quest_manager(quest_manager)
	$HUD/Subtitle.text = "BELLHAVEN VILLAGE"
	$Actors/Player/Camera2D.framing = Vector2(0, -96)
	$Actors/Player/Camera2D.snap_to_target()
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
	# Non-blocking, foot-sorted GFX-1 dressing. No quest actors are moved.
	for spec: Array in [[0,Vector2(-160,60)],[1,Vector2(156,-30)],[2,Vector2(-145,18)],[2,Vector2(93,-79)],[3,Vector2(-225,135)],[3,Vector2(223,181)]]:
		var detail := Node2D.new()
		detail.set_script(preload("res://scripts/world/bellhaven_decor.gd"))
		detail.set("style",spec[0])
		detail.position = spec[1]
		$Actors.add_child(detail)
	var air := Node2D.new()
	air.name = "BellhavenAir"
	air.set_script(preload("res://scripts/world/bellhaven_air.gd"))
	air.z_index = 2
	add_child(air)
	var is_dawn: bool = (quest_manager.storm_resolved or quest_manager.chapter5_completed)
	AudioManagerScript.play_global_region(get_tree(), "epilogue_dawn" if is_dawn else "bellhaven")
	if is_dawn:
		$HUD.play_region_transition("BELLHAVEN AT SUNRISE", "EPILOGUE - ASHVALE REMEMBERED")
	else:
		$HUD.play_region_transition("BELLHAVEN VILLAGE", "PROLOGUE - THE THIRTEENTH TOLL")

func _on_objective_completed(objective_id: String) -> void:
	match objective_id:
		"speak_npcs":
			mothers_letter.letter_highlighted = true
			mothers_letter.refresh_prompt("[E] READ MOTHER'S LETTER")
			mothers_letter.queue_redraw()
		"find_mothers_letter":
			mothers_letter.letter_highlighted = false
			mothers_letter.queue_redraw()
			$Actors/Terminal.refresh_prompt("[E] ALIGN RUNE PEDESTAL")
		"solve_rune_puzzle":
			$Actors/Terminal.puzzle_solved = true
			$Actors/Terminal.refresh_prompt("[E] EXAMINE GLOWING PEDESTAL")
			$Actors/Terminal.queue_redraw()
			briarwood_gate.gate_unlocked = true
			briarwood_gate.refresh_prompt("[E] APPROACH BRIARWOOD WAYSTONE")
			briarwood_gate.queue_redraw()
			$Landscape.pedestal_awakened = true
			$Landscape.queue_redraw()
		"trigger_prologue_completion":
			briarwood_gate.refresh_prompt("[E] INSPECT BRIARWOOD WAYSTONE")

func _sync_world_from_quest() -> void:
	if quest_manager == null:
		return
	if mothers_letter != null:
		mothers_letter.letter_highlighted = (quest_manager.get_current_objective_id() == "find_mothers_letter")
		mothers_letter.refresh_prompt("[E] READ MOTHER'S LETTER" if quest_manager.can_open_mothers_letter() else "[E] INSPECT SEALED CHEST")
		mothers_letter.queue_redraw()
	var term := get_node_or_null("Actors/Terminal") as StaticBody2D
	if term != null:
		term.puzzle_solved = quest_manager.puzzle_solved
		if quest_manager.puzzle_solved:
			term.refresh_prompt("[E] EXAMINE GLOWING PEDESTAL")
		elif quest_manager.can_open_rune_puzzle():
			term.refresh_prompt("[E] ALIGN RUNE PEDESTAL")
		else:
			term.refresh_prompt("[E] INSPECT RUNE PEDESTAL")
		term.queue_redraw()
	var rune_ui := get_node_or_null("HUD/RunePuzzle")
	if rune_ui != null:
		rune_ui.set("solved", quest_manager.puzzle_solved)
	if briarwood_gate != null:
		briarwood_gate.gate_unlocked = quest_manager.puzzle_solved
		briarwood_gate.ready_to_travel = false
		if quest_manager.prologue_completed:
			briarwood_gate.refresh_prompt("[E] INSPECT BRIARWOOD WAYSTONE")
		elif quest_manager.puzzle_solved:
			briarwood_gate.refresh_prompt("[E] APPROACH BRIARWOOD WAYSTONE")
		else:
			briarwood_gate.refresh_prompt("[E] INSPECT BRIARWOOD WAYSTONE")
		briarwood_gate.queue_redraw()
	$Landscape.pedestal_awakened = quest_manager.puzzle_solved
	var sunrise_active: bool = (quest_manager.storm_resolved or quest_manager.chapter5_completed)
	$Landscape.sunrise_epilogue = sunrise_active
	if sunrise_modulate != null:
		sunrise_modulate.color = Color(1.03, 0.98, 0.90, 1.0) if sunrise_active else Color(1.0, 1.0, 1.0, 1.0)
	if sunrise_active:
		$HUD/Subtitle.text = "BELLHAVEN AT SUNRISE"
		$HUD/Clock.text = "DAWN EPILOGUE"
		if village_memorial == null:
			village_memorial = InteractableScene.instantiate() as StaticBody2D
			village_memorial.name = "VillageMemorial"
			village_memorial.role = 4
			village_memorial.interaction_priority = 11
			village_memorial.prompt_text = "[E] READ MEMORIAL OF REMEMBERED NAMES"
			village_memorial.position = Vector2(-36, 86)
			$Actors.add_child(village_memorial)
		if dawn_terrace_arch == null:
			dawn_terrace_arch = InteractableScene.instantiate() as StaticBody2D
			dawn_terrace_arch.name = "DawnTerraceArch"
			dawn_terrace_arch.role = 5
			dawn_terrace_arch.interaction_priority = 8
			dawn_terrace_arch.prompt_text = "[E] ASCEND TO DAWN TERRACE"
			dawn_terrace_arch.position = Vector2(178, 124)
			$Actors.add_child(dawn_terrace_arch)
		if lyra_bellhaven == null:
			lyra_bellhaven = NpcScene.instantiate() as StaticBody2D
			lyra_bellhaven.name = "LyraBellhaven"
			lyra_bellhaven.npc_id = "lyra_bellhaven"
			lyra_bellhaven.speaker_name = "HISTORIAN LYRA"
			lyra_bellhaven.prompt_text = "[E] SPEAK WITH LYRA"
			lyra_bellhaven.interaction_priority = 9
			lyra_bellhaven.position = Vector2(16, 76)
			lyra_bellhaven.facing = 4
			$Actors.add_child(lyra_bellhaven)
	else:
		$HUD/Subtitle.text = "BELLHAVEN VILLAGE"
		if village_memorial != null and is_instance_valid(village_memorial):
			village_memorial.queue_free()
			village_memorial = null
		if dawn_terrace_arch != null and is_instance_valid(dawn_terrace_arch):
			dawn_terrace_arch.queue_free()
			dawn_terrace_arch = null
		if lyra_bellhaven != null and is_instance_valid(lyra_bellhaven):
			lyra_bellhaven.queue_free()
			lyra_bellhaven = null
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

func reset_new_game() -> void:
	if quest_manager != null:
		quest_manager.reload_quest("res://data/prologue_quest.json")
	$Actors/Player.position = Vector2(10, 44)
	$Actors/Player.facing = 2
	$Actors/Player.movement_locked = false
	$Actors/Player/Camera2D.snap_to_target()
	_sync_world_from_quest()
	AudioManagerScript.play_global_region(get_tree(), "bellhaven")

func travel_to_briarwood() -> void:
	if quest_manager != null and quest_manager.briarwood_unlocked and is_inside_tree():
		QuestManagerScript.carry_prologue_completed = true
		QuestManagerScript.pending_entry_pose = false
		get_tree().change_scene_to_file("res://scenes/briarwood_forest.tscn")

func travel_to_great_bell_terrace() -> void:
	if quest_manager != null and (quest_manager.storm_resolved or quest_manager.chapter5_completed) and is_inside_tree():
		QuestManagerScript.carry_chapter4_completed = true
		QuestManagerScript.pending_chapter5_snapshot = quest_manager.capture_state()
		QuestManagerScript.pending_entry_pose = true
		QuestManagerScript.pending_entry_position = Vector2(270, -84)
		QuestManagerScript.pending_entry_facing = 0
		get_tree().change_scene_to_file("res://scenes/great_bell_sanctum.tscn")
