extends SceneTree
## Comprehensive headless validation of Ashvale Phase 1 Story Prologue.

var checks: int = 0
var failed: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS: ", description)
	else:
		failed += 1
		push_error("FAIL: " + description)

func frames(count: int) -> void:
	for i in range(count):
		await physics_frame
	await process_frame

func press(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = InputEventAction.new()
	event.action = action
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame

func read_through_dialogue(hud: CanvasLayer) -> void:
	var safety: int = 10
	while hud.get_node("Message").visible and safety > 0:
		safety -= 1
		await press("interact")
		await frames(1)

func prompt_count(world: Node) -> int:
	var count: int = 0
	for object: Node in get_nodes_in_group("interactables"):
		if world.is_ancestor_of(object) and object.get_node("Indicator").visible:
			count += 1
	return count

func run() -> void:
	var ok: Variant = await exercise()
	check(ok == true, "Phase 1 suite completed")
	print("PHASE 1 RESULT: %d checks, %d failures" % [checks, failed])
	quit(1 if failed else 0)

func exercise() -> bool:
	var packed := load("res://scenes/sjt_exterior.tscn") as PackedScene
	check(packed != null, "Bellhaven scene loads")
	var world := packed.instantiate() as Node2D
	root.add_child(world)
	await frames(4)

	var qm: Node = world.get_node("QuestManager")
	var hud: CanvasLayer = world.get_node("HUD")
	var player: CharacterBody2D = world.get_node("Actors/Player")
	var terminal: StaticBody2D = world.get_node("Actors/Terminal")
	var caelen: StaticBody2D = world.get_node("Actors/MasterCaelen")
	var mira: StaticBody2D = world.get_node("Actors/Mira")
	var elara: StaticBody2D = world.get_node("Actors/SisterElara")
	var letter: StaticBody2D = world.get_node("Actors/MothersLetter")
	var gate: StaticBody2D = world.get_node("Actors/BriarwoodGate")
	var puzzle: Panel = hud.get_node("RunePuzzle")
	var banner: Panel = hud.get_node("PrologueComplete")
	var landscape: Node2D = world.get_node("Landscape")

	check(qm != null and caelen != null and mira != null and elara != null, "All Bellhaven quest actors exist")
	check(letter != null and gate != null and puzzle != null and banner != null, "All prologue story objects and UI exist")
	check(qm.get_current_objective_id() == "investigate_bell", "Starts at Objective 1: investigate_bell")
	check(hud.get_node("Objective").text == "Investigate the thirteenth bell.", "HUD shows Objective 1")
	var spots := [
		terminal.position + Vector2(0, 24),
		caelen.position + Vector2(0, 20),
		mira.position + Vector2(0, 20),
		elara.position + Vector2(0, 20),
		letter.position + Vector2(0, 18),
		gate.position + Vector2(18, 12),
	]
	for idx in range(spots.size()):
		var xf := player.global_transform
		xf.origin = spots[idx]
		check(not player.test_move(xf, Vector2(0, 0.1)), "Interaction spot %d is free of solids" % idx)

	# Anti-skip tests before Objective 1
	check(not qm.complete_objective("solve_rune_puzzle"), "QuestManager blocks out-of-order completion")
	player.position = letter.position + Vector2(0, 18)
	await frames(3)
	await press("interact")
	check(hud.get_node("Message").visible and hud.get_node("Message/Source").text == "SEALED SURVEY CHEST", "Locked chest rejects early pickup")
	await read_through_dialogue(hud)
	check(qm.get_current_objective_id() == "investigate_bell", "Locked chest does not advance objective")

	player.position = gate.position + Vector2(18, 12)
	await frames(3)
	await press("interact")
	check(hud.get_node("Message").visible and hud.get_node("Message/Source").text == "BRIARWOOD WAYSTONE", "Dormant Briarwood gate blocks early departure")
	await read_through_dialogue(hud)
	check(qm.get_current_objective_id() == "investigate_bell", "Dormant gate does not advance objective")

	player.position = caelen.position + Vector2(0, 20)
	await frames(3)
	await press("interact")
	check(hud.get_node("Message/Source").text == "MASTER CAELEN", "Caelen shows pre-pedestal dialogue")
	await read_through_dialogue(hud)
	check(qm.get_current_objective_id() == "investigate_bell", "Talking before pedestal does not complete speak_npcs")

	# Objective 1: Investigate the Thirteenth Bell
	player.position = terminal.position + Vector2(0, 24)
	await frames(3)
	check(terminal.selected and prompt_count(world) == 1, "Single prompt shown at Rune Pedestal")
	await press("interact")
	check(hud.get_node("Message").visible and hud.get_node("Message/Source").text == "STONE RUNE PEDESTAL", "Pedestal opens initial omen message")
	await press("interact")
	check(qm.is_objective_completed("investigate_bell"), "Objective 1 completed")
	check(qm.get_current_objective_id() == "speak_npcs", "Objective 2 unlocked in order")
	check(hud.get_node("Objective").text == "Speak with the three villagers (0/3).", "HUD tracks 0/3 villagers")

	# Objective 2: Speak with three unique NPCs (Master Caelen, Mira, Sister Elara)
	player.position = caelen.position + Vector2(0, 20)
	await frames(3)
	check(caelen.selected and prompt_count(world) == 1, "Single prompt shown for Master Caelen")
	await press("interact")
	check(hud.get_node("Message").visible and hud.get_node("Message/Source").text == "MASTER CAELEN", "Master Caelen dialogue opens")
	check("thirteen chimes" in hud.get_node("Message/Text").text.to_lower(), "Caelen line 1 authentic")
	await press("interact")
	check(hud.get_node("Message").visible, "Multi-line dialogue advances to line 2 without closing")
	await read_through_dialogue(hud)
	check(hud.get_node("Objective").text == "Speak with the three villagers (1/3).", "Caelen increments NPC counter to 1/3")

	# Repeat conversation exploit guard
	await press("interact")
	await read_through_dialogue(hud)
	check(hud.get_node("Objective").text == "Speak with the three villagers (1/3).", "Re-talking to Caelen cannot farm NPC progress")

	# Mother's letter still locked until 3/3 villagers spoken to
	player.position = letter.position + Vector2(0, 18)
	await frames(3)
	await press("interact")
	await read_through_dialogue(hud)
	check(not qm.is_objective_completed("find_mothers_letter"), "Mother's letter remains gated until all 3 NPCs visited")

	# Speak with Mira (plus mid-dialogue ESC recovery check)
	player.position = mira.position + Vector2(0, 20)
	await frames(3)
	await press("interact")
	check(hud.get_node("Message/Source").text == "MIRA THE BLACKSMITH", "Mira dialogue opens")
	await press("dismiss")
	await frames(2)
	check(not hud.get_node("Message").visible and not player.movement_locked, "Dismissing Mira mid-dialogue restores movement cleanly")
	check(not qm.talked_npcs.has("mira") and mira.selected and prompt_count(world) == 1, "Dismissing early does not credit Mira and restores prompt")
	await press("interact")
	await read_through_dialogue(hud)
	check(hud.get_node("Objective").text == "Speak with the three villagers (2/3).", "Mira increments NPC counter to 2/3")

	# Verify explicit cipher clues appear across villager dialogue and Mother's letter (no guessing)
	var caelen_clue: String = " ".join(qm.get_npc_dialogue("caelen")).to_lower()
	var mira_clue: String = " ".join(qm.get_npc_dialogue("mira")).to_lower()
	var elara_clue: String = " ".join(qm.get_npc_dialogue("elara")).to_lower()
	check("outer ring" in caelen_clue and "moon" in caelen_clue, "Caelen reveals Outer Ring MOON clue")
	check("middle ring" in mira_clue and "sun" in mira_clue, "Mira reveals Middle Ring SUN clue")
	check("inner ring" in elara_clue and "star" in elara_clue, "Elara reveals Inner Ring STAR clue")
	var letter_clue: String = " ".join(qm.get_story_lines("mothers_letter")).to_lower()
	check("moon" in letter_clue and "sun" in letter_clue and "star" in letter_clue, "Mother's letter explicitly confirms MOON, SUN, STAR")

	# Speak with Sister Elara
	player.position = elara.position + Vector2(0, 20)
	await frames(3)
	await press("interact")
	check(hud.get_node("Message/Source").text == "SISTER ELARA", "Sister Elara dialogue opens")
	await read_through_dialogue(hud)
	check(qm.is_objective_completed("speak_npcs"), "Objective 2 completed after 3 unique NPCs")
	check(qm.get_current_objective_id() == "find_mothers_letter", "Objective 3 unlocked in order")
	check(hud.get_node("Objective").text == "Find Mother's letter by the cottage.", "HUD updates to Objective 3")
	check(letter.letter_highlighted, "Mother's chest highlights on Objective 3")

	# Rune pedestal cannot be solved before reading Mother's letter
	player.position = terminal.position + Vector2(0, 24)
	await frames(3)
	await press("interact")
	check(not puzzle.visible and hud.get_node("Message").visible, "Rune puzzle cannot be skipped before finding Mother's letter")
	await read_through_dialogue(hud)

	# Objective 3: Find Mother's Letter
	player.position = letter.position + Vector2(0, 18)
	await frames(3)
	await press("interact")
	check(hud.get_node("Message/Source").text == "MOTHER'S LETTER", "Mother's letter opens after Caelen gives key")
	await read_through_dialogue(hud)
	check(qm.is_objective_completed("find_mothers_letter") and qm.letter_found, "Objective 3 completed")
	check(qm.get_current_objective_id() == "solve_rune_puzzle", "Objective 4 unlocked in order")
	check(hud.get_node("Objective").text == "Align the three discs on the Rune Pedestal.", "HUD updates to Objective 4")

	# Objective 4: Rune-Alignment Minigame
	player.position = terminal.position + Vector2(0, 24)
	await frames(3)
	await press("interact")
	check(puzzle.visible and player.movement_locked, "Rune puzzle modal opens and locks movement")
	check("Outer MOON, Middle SUN, Inner STAR" in puzzle.feedback_label.text, "Rune puzzle displays transcribed cipher clue note")
	check(prompt_count(world) == 0, "World prompts hidden while Rune Puzzle is open")
	await press("dismiss")
	await frames(2)
	check(not puzzle.visible and not player.movement_locked and qm.get_current_objective_id() == "solve_rune_puzzle", "ESC closes Rune Puzzle without softlock")
	check(terminal.selected and prompt_count(world) == 1, "Closing Rune Puzzle restores pedestal prompt")
	await press("interact")
	await frames(2)
	check(puzzle.visible and player.movement_locked, "Rune puzzle reopens cleanly after ESC")

	# Wrong combination test
	puzzle.set_disc_symbol(0, "SUN")
	puzzle.set_disc_symbol(1, "MOON")
	puzzle.set_disc_symbol(2, "WAVE")
	check(not puzzle.verify_alignment(), "Incorrect rune combination rejected")
	check(puzzle.visible and qm.get_current_objective_id() == "solve_rune_puzzle", "Incorrect attempt does not complete quest")

	# Keyboard navigation + solving to MOON, SUN, STAR
	puzzle.select_disc(0)
	puzzle.set_disc_symbol(0, "SUN")
	await press("move_right") # SUN -> MOON
	await press("move_down")  # select ring 1
	puzzle.set_disc_symbol(1, "WAVE")
	await press("move_right") # WAVE -> SUN
	await press("move_down")  # select ring 2
	puzzle.set_disc_symbol(2, "MOON")
	await press("move_right") # MOON -> STAR
	await press("interact")   # confirm via keyboard E
	await frames(2)

	check(not puzzle.visible and puzzle.solved, "Correct rune cipher (MOON, SUN, STAR) solves puzzle via keyboard")
	check(qm.is_objective_completed("solve_rune_puzzle") and qm.puzzle_solved, "Objective 4 completed cleanly")
	check(terminal.puzzle_solved and gate.gate_unlocked and landscape.pedestal_awakened, "Pedestal glows and unlocks Briarwood Waystone")
	check(hud.get_node("Message").visible and hud.get_node("Message/Source").text == "STONE RUNE PEDESTAL", "Beacon revelation dialogue opens immediately after solve")
	await read_through_dialogue(hud)
	check(qm.get_current_objective_id() == "discover_briarwood_path", "Objective 5 unlocked after revelation")

	# Verify puzzle cannot be re-completed repeatedly for rewards
	await press("interact")
	check(not puzzle.visible and hud.get_node("Message").visible, "Solved pedestal shows post-solve lore instead of reopening puzzle")
	await read_through_dialogue(hud)

	# Objective 5 & 6: Discover Briarwood Path & Trigger Prologue Completion (with ESC recovery)
	player.position = gate.position + Vector2(18, 12)
	await frames(3)
	await press("interact")
	check(qm.is_objective_completed("discover_briarwood_path") and qm.briarwood_discovered, "Objective 5 completed at awakened Briarwood Waystone")
	check(qm.get_current_objective_id() == "trigger_prologue_completion", "Objective 6 active during final revelation dialogue")
	check(hud.get_node("Message/Source").text == "BRIARWOOD WAYSTONE", "Final Briarwood & mother connection dialogue opens")
	await press("dismiss")
	await frames(2)
	check(not banner.visible and not player.movement_locked and qm.get_current_objective_id() == "trigger_prologue_completion", "Cancelling waystone dialogue leaves Objective 6 recoverable")
	check(gate.selected and prompt_count(world) == 1, "Cancelling waystone dialogue restores prompt")
	await press("interact")
	await read_through_dialogue(hud)
	await frames(2)

	check(qm.is_objective_completed("trigger_prologue_completion") and qm.prologue_completed and qm.briarwood_unlocked, "Objective 6 completed and Briarwood unlocked")
	check(banner.visible, "Prologue Complete screen visible")
	check(banner.get_node("BannerTitle").text == "PROLOGUE COMPLETE — THE THIRTEENTH TOLL", "Exact prologue completion banner displayed")
	await press("interact")
	check(not banner.visible and not player.movement_locked, "Dismissing Prologue Complete restores free exploration")
	check(hud.get_node("Objective").text == "Prologue Complete - Briarwood Unlocked.", "HUD reflects completed prologue")
	await frames(2)
	await press("interact")
	check(not banner.visible and hud.get_node("Message").visible and "awaiting chapter 1" in hud.get_node("Message/Text").text.to_lower(), "Post-prologue waystone shows Chapter 1 transition note without re-triggering banner")
	await read_through_dialogue(hud)

	# Verify NPC collision & idle animation
	player.position = caelen.position + Vector2(0, 22)
	check(player.test_move(player.global_transform, Vector2(0, -24)), "NPC solid collider blocks walking")
	var initial_frame: int = caelen.idle_frame
	for step in range(45):
		await frames(1)
	check(caelen.idle_time > 0.5, "NPC idle animation clock advances")

	# Post-prologue NPC dialogue updates dynamically
	await press("interact")
	check("briarwood" in hud.get_node("Message/Text").text.to_lower(), "NPC dialogue reflects completed quest state")
	await read_through_dialogue(hud)

	world.queue_free()
	await process_frame
	return true
