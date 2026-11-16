extends Panel
## Aren's Field Satchel showing collected quest items, repair materials, clues, and relics.

signal inventory_closed_signal()

var row_labels: Array[Label] = []
var footer_label: Label
var opened_frame: int = -1

func _ready() -> void:
	visible = false
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.5
	anchor_bottom = 0.5
	offset_left = -228
	offset_right = 228
	offset_top = -134
	offset_bottom = 134

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.05, 0.08, 0.98)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.78, 0.62, 0.36, 1)
	add_theme_stylebox_override("panel", style)

	var title := Label.new()
	title.name = "HeaderTitle"
	title.text = "AREN'S FIELD SATCHEL - ITEMS AND CLUES"
	title.position = Vector2(16, 14)
	title.add_theme_font_size_override("font_size", 8)
	title.add_theme_color_override("font_color", Color("f2deaa"))
	add_child(title)

	for i in range(10):
		var lbl := Label.new()
		lbl.name = "ItemRow%d" % i
		lbl.position = Vector2(18, 34 + i * 16)
		lbl.size = Vector2(420, 15)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.add_theme_font_size_override("font_size", 8)
		lbl.add_theme_color_override("font_color", Color("d6c7ad"))
		add_child(lbl)
		row_labels.append(lbl)

	footer_label = Label.new()
	footer_label.name = "SummaryFooter"
	footer_label.position = Vector2(18, 204)
	footer_label.size = Vector2(300, 16)
	footer_label.add_theme_font_size_override("font_size", 8)
	footer_label.add_theme_color_override("font_color", Color("7dd8e8"))
	add_child(footer_label)

	var close_btn := Button.new()
	close_btn.name = "CloseButton"
	close_btn.text = "[ CLOSE SATCHEL ]"
	close_btn.position = Vector2(316, 226)
	close_btn.size = Vector2(122, 24)
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.add_theme_font_size_override("font_size", 8)
	close_btn.add_theme_color_override("font_color", Color("f2deaa"))
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.11, 0.12, 0.17, 1)
	btn_style.border_width_left = 1
	btn_style.border_width_top = 1
	btn_style.border_width_right = 1
	btn_style.border_width_bottom = 1
	btn_style.border_color = Color(0.55, 0.45, 0.30, 1)
	close_btn.add_theme_stylebox_override("normal", btn_style)
	close_btn.pressed.connect(close_inventory)
	add_child(close_btn)

func _build_items(qm: Node) -> Array[String]:
	var items: Array[String] = []
	if qm == null:
		return items
	if qm.quest_id == "chapter4_road_to_dawnspire":
		if qm.chapter3_completed or qm.third_beacon_activated:
			items.append("- THREE RESTORED BEACONS: BRIARWOOD, FLOODMILL, IRONWATCH")
		if qm.skybridge_parts_collected.size() > 0 or qm.skybridge_diagram_read:
			items.append("- SKYBRIDGE PARTS (%d/3)%s" % [qm.skybridge_parts_collected.size(), " [BALANCED]" if qm.skybridge_repaired else (" [DIAGRAM READY]" if qm.skybridge_diagram_read else "")])
		if qm.pilgrim_refuge_discovered:
			items.append("- PILGRIM'S REFUGE MURALS: RECORD OF FORGOTTEN CLIMBERS")
		if qm.elena_journal_read:
			items.append("- ELENA'S JOURNAL: COURAGE IS CHOOSING WHAT IS RIGHT")
		if qm.celestial_clues_found.size() > 0:
			items.append("- CELESTIAL PILLARS (%d/3): SUN DAWN, MOON TIDE, STARS CROWN" % qm.celestial_clues_found.size())
		if qm.observatory_solved:
			items.append("- OBSERVATORY ASTROLABE: CELESTIAL RINGS ALIGNED TO SANCTUARY")
		if qm.beacons_synchronized:
			items.append("- DAWNSPIRE NEXUS: ALL THREE ANCIENT BEACONS SYNCHRONIZED")
		if qm.great_bell_gate_unlocked:
			items.append("- GREAT BELL GATE SEAL: OPENED FOR THE LAST BELL")
		var opt_tags: Array[String] = []
		if qm.optional_discoveries.has("dawnspire_campsite"):
			opt_tags.append("CAMPSITE")
		if qm.optional_discoveries.has("dawnspire_pilgrim_letter"):
			opt_tags.append("LETTER")
		if qm.optional_discoveries.has("dawnspire_memorial"):
			opt_tags.append("MEMORIAL")
		if qm.optional_discoveries.has("dawnspire_hidden_overlook"):
			opt_tags.append("OVERLOOK")
		if not opt_tags.is_empty():
			items.append("- MOUNTAIN REMEMBRANCES: " + ", ".join(opt_tags))
		return items
	if qm.quest_id == "chapter3_keepers_lie":
		if qm.prologue_completed or qm.chapter1_completed or qm.chapter2_completed:
			items.append("- BRIARWOOD AND FLOODMILL: TWO ANCIENT BEACONS RESTORED")
		if qm.optional_discoveries.has("ruined_camp_relic"):
			items.append("- ELENA'S BRASS SURVEY COMPASS [BRIARWOOD RELIC]")
		if qm.optional_discoveries.has("homestead_locket"):
			items.append("- WEAVER'S TARNISHED SILVER LOCKET [FLOODMILL RELIC]")
		if qm.warden_records_found:
			items.append("- FIRST CATASTROPHE LEDGER: 36 VOLUNTEERS SAVED TEN THOUSAND")
		if qm.barracks_explored:
			items.append("- BARRACKS DUTY ROSTER: LATER KEEPERS CONCEALED BEACON CURE")
		if qm.optional_discoveries.has("wardens_locket"):
			items.append("- WARDEN'S TARNISHED LOCKET [BARRACKS KEEPSAKE]")
		if qm.crest_clues_found.size() > 0:
			var cc: Array[String] = []
			if qm.crest_clues_found.has("clue_1"):
				cc.append("I: SILVER BELL")
			if qm.crest_clues_found.has("clue_2"):
				cc.append("II: SUNDERED SHIELD")
			if qm.crest_clues_found.has("clue_3"):
				cc.append("III: CROWNED FLAME")
			items.append("- WATCH CREST TABLETS (%d/3): %s" % [qm.crest_clues_found.size(), ", ".join(cc)])
		if qm.crest_puzzle_solved:
			items.append("- HALL OF CRESTS SEAL: SILVER BELL, SUNDERED SHIELD, CROWNED FLAME")
		if qm.shadow_passage_cleared:
			items.append("- NORTH WARD LANTERN: SHADOW SENTINELS HARMONIZED")
		if qm.warden_confronted:
			items.append("- LAST WARDEN'S TESTIMONY: THIRTY-SIX LIVES FOR TEN THOUSAND")
		if qm.elena_research_found:
			items.append("- ELENA'S HARMONIC FOLIO: THREE BEACONS END THE BELL'S CURSE")
		if qm.third_beacon_activated:
			items.append("- THIRD ANCIENT BEACON: TRIAD LATTICE CONNECTED ACROSS ASHVALE")
		return items
	if qm.quest_id == "chapter2_drowned_village":
		if qm.prologue_completed or qm.chapter1_completed:
			items.append("- BELLHAVEN TO BRIARWOOD: RUNE KEY, CIPHER AND FIRST BEACON RECORDED")
		if qm.optional_discoveries.has("ruined_camp_relic"):
			items.append("- ELENA'S BRASS SURVEY COMPASS [BRIARWOOD RELIC]")
		if qm.mill_parts_collected.has("iron_drive_gear"):
			items.append("- IRON DRIVE GEAR " + ("[FITTED IN MILL]" if qm.watermill_repaired else "[IN SATCHEL]"))
		if qm.mill_parts_collected.has("bronze_pinion"):
			items.append("- BRONZE PINION " + ("[FITTED IN MILL]" if qm.watermill_repaired else "[IN SATCHEL]"))
		if qm.mill_parts_collected.has("oak_coupling_belt"):
			items.append("- OAK COUPLING BELT " + ("[FITTED IN MILL]" if qm.watermill_repaired else "[IN SATCHEL]"))
		if qm.sluice_solved:
			items.append("- CANAL SLUICE PROTOCOL: WEST DIVERT, CENTER DRAIN, EAST OPEN")
		if qm.archive_clues_found.size() > 0:
			var cl: Array[String] = []
			if qm.archive_clues_found.has("record_census"):
				cl.append("I: THIRTY-SIX HEARTHS")
			if qm.archive_clues_found.has("record_tribute"):
				cl.append("II: MEMORY OFFERING")
			if qm.archive_clues_found.has("record_transfer"):
				cl.append("III: IRONWATCH SEAL")
			items.append("- ARCHIVE RECORDS (%d/3): %s" % [qm.archive_clues_found.size(), ", ".join(cl)])
		if qm.villagers_truth_discovered:
			items.append("- BOUND FLOODMILL LEDGER: NAMES SEALED BY IRONWATCH EDICT")
		if qm.optional_discoveries.has("homestead_locket"):
			items.append("- WEAVER'S TARNISHED SILVER LOCKET [OPTIONAL RELIC]")
		if qm.chapter2_elena_echo_heard:
			items.append("- SECOND BEACON ECHO: SEEK TRUTH AT IRONWATCH KEEP")
		return items

	if qm.is_objective_completed("speak_npcs") or qm.prologue_completed or qm.quest_id == "chapter1_whispers_of_briarwood":
		items.append("- MASTER CAELEN'S BRASS KEY [SURVEY CHEST KEY]")
	if qm.letter_found or qm.prologue_completed or qm.quest_id == "chapter1_whispers_of_briarwood":
		items.append("- MOTHER'S LETTER: CIPHER OUTER MOON, MID SUN, INNER STAR")
	if qm.materials_collected.has("plank_1"):
		items.append("- SEASONED OAK BEAM (LEFT BEAM) " + ("[USED IN BRIDGE]" if qm.bridge_repaired else "[IN SATCHEL]"))
	if qm.materials_collected.has("plank_2"):
		items.append("- WALKWAY OAK PLANK (RIGHT PLANK) " + ("[USED IN BRIDGE]" if qm.bridge_repaired else "[IN SATCHEL]"))
	if qm.materials_collected.has("rope_coil"):
		items.append("- TARRED HEMP ROPE (ROPE LASHING) " + ("[USED IN BRIDGE]" if qm.bridge_repaired else "[IN SATCHEL]"))
	if qm.inscriptions_read.size() > 0:
		var parts: Array[String] = []
		if qm.inscriptions_read.has("west"):
			parts.append("WEST: DAWN")
		if qm.inscriptions_read.has("center"):
			parts.append("CENTER: ZENITH")
		if qm.inscriptions_read.has("east"):
			parts.append("EAST: DUSK")
		items.append("- OAKHAVEN INSCRIPTIONS (%d/3): %s" % [qm.inscriptions_read.size(), ", ".join(parts)])
	if qm.optional_discoveries.has("ruined_camp_relic"):
		items.append("- ELENA'S BRASS SURVEY COMPASS [OPTIONAL RELIC]")
	if qm.elena_echo_heard:
		items.append("- FIRST BEACON ECHO NOTE: SOUTHEAST TO FLOODMILL")
	return items

func get_rendered_items_text() -> String:
	var joined: Array[String] = []
	for lbl in row_labels:
		if lbl.visible and lbl.text != "":
			joined.append(lbl.text)
	return "\n".join(joined)

func open_inventory(qm: Node) -> void:
	opened_frame = Engine.get_process_frames()
	var items: Array[String] = _build_items(qm)
	if items.is_empty():
		items.append("NO QUEST ITEMS COLLECTED YET. EXPLORE BELLHAVEN SQUARE.")
	for i in range(row_labels.size()):
		if i < items.size():
			row_labels[i].text = items[i]
			row_labels[i].show()
		else:
			row_labels[i].text = ""
			row_labels[i].hide()
	if qm != null:
		footer_label.text = "[I] OR [ESC] CLOSE - STAGE: %s" % qm.get_current_objective_id().to_upper().replace("_", "-")
	else:
		footer_label.text = "[I] OR [ESC] CLOSE"
	visible = true

func close_inventory() -> void:
	if not visible:
		return
	visible = false
	inventory_closed_signal.emit()

func _input(event: InputEvent) -> void:
	if not visible or event.is_echo() or Engine.get_process_frames() == opened_frame:
		return
	var is_key_close: bool = (event is InputEventKey and event.pressed and (event.keycode == KEY_I or event.keycode == KEY_TAB))
	if is_key_close or event.is_action_pressed("interact") or event.is_action_pressed("dismiss") or event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		close_inventory()
		get_viewport().set_input_as_handled()
