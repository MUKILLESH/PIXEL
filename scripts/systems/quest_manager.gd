extends Node
## Data-driven chronological quest tracker for Ashvale's Story Prologue.

signal objective_changed(objective_id: String, objective_text: String)
signal objective_completed(objective_id: String)
signal quest_completed(quest_id: String)

const QUEST_DATA_PATH := "res://data/prologue_quest.json"

var quest_id: String = "prologue_thirteenth_toll"
var quest_title: String = "Prologue: The Thirteenth Toll"
var data: Dictionary = {}
var objectives: Array = []
var current_index: int = 0
var completed_objectives: Dictionary = {}
var talked_npcs: Dictionary = {}
var letter_found: bool = false
var puzzle_solved: bool = false
var briarwood_discovered: bool = false
var prologue_completed: bool = false
var briarwood_unlocked: bool = false

func _ready() -> void:
	load_quest_data()

func load_quest_data() -> void:
	var file := FileAccess.open(QUEST_DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open quest data: " + QUEST_DATA_PATH)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid JSON in quest data: " + QUEST_DATA_PATH)
		return
	data = parsed
	quest_id = String(data.get("quest_id", quest_id))
	quest_title = String(data.get("title", quest_title))
	objectives = data.get("objectives", [])

func get_current_objective_id() -> String:
	if current_index < objectives.size():
		return String(objectives[current_index].get("id", ""))
	return "completed"

func get_current_objective_text() -> String:
	if prologue_completed or current_index >= objectives.size():
		return "Prologue Complete - Briarwood Unlocked."
	var obj_id: String = get_current_objective_id()
	if obj_id == "speak_npcs":
		return "Speak with the three villagers (%d/3)." % talked_npcs.size()
	return String(objectives[current_index].get("text", ""))

func is_objective_completed(id: String) -> bool:
	return bool(completed_objectives.get(id, false))

func is_quest_completed(id: String = "prologue_thirteenth_toll") -> bool:
	return id == quest_id and prologue_completed

func can_open_mothers_letter() -> bool:
	return is_objective_completed("speak_npcs")

func can_open_rune_puzzle() -> bool:
	return get_current_objective_id() == "solve_rune_puzzle" and not puzzle_solved

func complete_objective(id: String) -> bool:
	if prologue_completed or get_current_objective_id() != id or completed_objectives.has(id):
		return false
	completed_objectives[id] = true
	if id == "find_mothers_letter":
		letter_found = true
	elif id == "solve_rune_puzzle":
		puzzle_solved = true
	elif id == "discover_briarwood_path":
		briarwood_discovered = true
	current_index += 1
	objective_completed.emit(id)
	if current_index >= objectives.size():
		prologue_completed = true
		briarwood_unlocked = true
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

func get_npc_dialogue(npc_id: String) -> Array[String]:
	var npcs: Dictionary = data.get("npcs", {})
	var entry: Dictionary = npcs.get(npc_id, {})
	var stage_key := "investigation"
	if current_index == 0:
		stage_key = "before_pedestal"
	elif current_index >= 4:
		stage_key = "after_puzzle"
	var raw_lines: Array = entry.get(stage_key, [])
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
