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
	offset_left = -220
	offset_right = 220
	offset_top = -126
	offset_bottom = 126

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

	for i in range(8):
		var lbl := Label.new()
		lbl.name = "ItemRow%d" % i
		lbl.position = Vector2(18, 38 + i * 20)
		lbl.size = Vector2(404, 18)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.add_theme_font_size_override("font_size", 8)
		lbl.add_theme_color_override("font_color", Color("d6c7ad"))
		add_child(lbl)
		row_labels.append(lbl)

	footer_label = Label.new()
	footer_label.name = "SummaryFooter"
	footer_label.position = Vector2(18, 200)
	footer_label.size = Vector2(280, 16)
	footer_label.add_theme_font_size_override("font_size", 8)
	footer_label.add_theme_color_override("font_color", Color("7dd8e8"))
	add_child(footer_label)

	var close_btn := Button.new()
	close_btn.name = "CloseButton"
	close_btn.text = "[ CLOSE SATCHEL ]"
	close_btn.position = Vector2(302, 214)
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
		footer_label.text = "[I] OR [ESC] CLOSE - STAGE: %s" % qm.get_current_objective_id().to_upper()
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
