extends Node2D
const Prop = preload("res://scripts/world/prop.gd")
const Landmark = preload("res://scripts/world/sjt_landmark.gd")
const Furniture = preload("res://scripts/world/campus_furniture.gd")
const QuestManagerScript = preload("res://scripts/systems/quest_manager.gd")
const NpcScene = preload("res://scenes/characters/npc.tscn")
const InteractableScene = preload("res://scenes/environment/terminal.tscn")

var quest_manager: Node
var mothers_letter: StaticBody2D
var briarwood_gate: StaticBody2D

func _ready() -> void:
	var ground: TileMapLayer = $Ground
	for x in range(-28, 29):
		for y in range(-28, 29):
			ground.set_cell(Vector2i(x, y), 0, Vector2i(posmod(x * 17 + y * 31, 3), 0))
	for point: Vector2 in [Vector2(-240,-30),Vector2(-230,100),Vector2(-140,125),Vector2(220,-50),Vector2(245,80),Vector2(175,215),Vector2(-170,235),Vector2(-310,35),Vector2(280,5),Vector2(-160,-170),Vector2(85,-190),Vector2(300,170)]:
		var tree := StaticBody2D.new()
		tree.set_script(Prop)
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

	quest_manager = QuestManagerScript.new()
	quest_manager.name = "QuestManager"
	add_child(quest_manager)
	quest_manager.objective_completed.connect(_on_objective_completed)

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
		_sync_world_from_quest()
	$Landscape.queue_redraw()

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

func travel_to_briarwood() -> void:
	if quest_manager != null and quest_manager.briarwood_unlocked and is_inside_tree():
		QuestManagerScript.carry_prologue_completed = true
		get_tree().change_scene_to_file("res://scenes/briarwood_forest.tscn")
