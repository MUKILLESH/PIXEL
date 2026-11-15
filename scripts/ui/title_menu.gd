extends Panel
## Lightweight system & title menu providing New Game, Continue, Manual Save, and Satchel access.

signal new_game_requested()
signal continue_requested()
signal save_requested()
signal inventory_requested()
signal menu_closed_signal()

const OPTIONS := [
	"NEW GAME",
	"CONTINUE SAVED GAME",
	"SAVE PROGRESS",
	"OPEN FIELD SATCHEL",
	"RESUME EXPLORATION",
]

var selected_index: int = 0
var has_save: bool = false
var opened_frame: int = -1
var buttons: Array[Button] = []
var feedback_label: Label

func _ready() -> void:
	visible = false
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.5
	anchor_bottom = 0.5
	offset_left = -220
	offset_right = 220
	offset_top = -132
	offset_bottom = 132

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.05, 0.08, 0.98)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.78, 0.62, 0.36, 1)
	add_theme_stylebox_override("panel", style)

	var title := Label.new()
	title.name = "TitleLabel"
	title.text = "ASHVALE: THE THIRTEENTH BELL"
	title.position = Vector2(20, 14)
	title.add_theme_font_size_override("font_size", 8)
	title.add_theme_color_override("font_color", Color("f2deaa"))
	add_child(title)

	var subtitle := Label.new()
	subtitle.name = "SubtitleLabel"
	subtitle.text = "CHRONICLES OF THE GREAT BELL - SYSTEM MENU"
	subtitle.position = Vector2(20, 28)
	subtitle.add_theme_font_size_override("font_size", 8)
	subtitle.add_theme_color_override("font_color", Color("9c937e"))
	add_child(subtitle)

	for i in range(OPTIONS.size()):
		var btn := Button.new()
		btn.name = "MenuButton%d" % i
		btn.position = Vector2(36, 52 + i * 28)
		btn.size = Vector2(368, 22)
		btn.focus_mode = Control.FOCUS_NONE
		btn.add_theme_font_size_override("font_size", 8)
		btn.pressed.connect(_on_button_pressed.bind(i))
		add_child(btn)
		buttons.append(btn)

	feedback_label = Label.new()
	feedback_label.name = "FeedbackLabel"
	feedback_label.position = Vector2(20, 198)
	feedback_label.size = Vector2(400, 28)
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.add_theme_font_size_override("font_size", 8)
	feedback_label.add_theme_color_override("font_color", Color("d6c7ad"))
	add_child(feedback_label)

	var hint := Label.new()
	hint.name = "HintLabel"
	hint.text = "W/S SELECT   E/ENTER CONFIRM   ESC RESUME   F5 QUICK SAVE"
	hint.position = Vector2(20, 238)
	hint.add_theme_font_size_override("font_size", 8)
	hint.add_theme_color_override("font_color", Color("9c937e"))
	add_child(hint)
	_refresh_buttons()

func open_menu(save_available: bool, status_text: String = "") -> void:
	has_save = save_available
	opened_frame = Engine.get_process_frames()
	selected_index = 1 if save_available else 4
	if status_text != "":
		set_feedback(status_text, false)
	elif save_available:
		set_feedback("Saved chronicle detected. Choose Continue to resume or Save to overwrite.", false)
	else:
		set_feedback("No save file found yet. Select Save Progress or press F5 anytime.", false)
	_refresh_buttons()
	visible = true

func close_menu() -> void:
	if not visible:
		return
	visible = false
	menu_closed_signal.emit()

func set_feedback(text: String, is_error: bool = false) -> void:
	if feedback_label == null:
		return
	feedback_label.text = text
	feedback_label.add_theme_color_override("font_color", Color("ff8080") if is_error else Color("8ce89a"))

func select_option(idx: int) -> void:
	selected_index = posmod(idx, OPTIONS.size())
	_refresh_buttons()

func activate_selected() -> void:
	_on_button_pressed(selected_index)

func _on_button_pressed(idx: int) -> void:
	selected_index = idx
	_refresh_buttons()
	match idx:
		0:
			new_game_requested.emit()
		1:
			continue_requested.emit()
		2:
			save_requested.emit()
		3:
			inventory_requested.emit()
		4:
			close_menu()

func _refresh_buttons() -> void:
	for i in range(buttons.size()):
		var btn: Button = buttons[i]
		var label_text: String = OPTIONS[i]
		if i == 1 and not has_save:
			label_text = "CONTINUE SAVED GAME (NONE FOUND)"
		btn.text = ("> " + label_text) if i == selected_index else ("  " + label_text)
		var st := StyleBoxFlat.new()
		st.bg_color = Color(0.16, 0.14, 0.22, 1) if i == selected_index else Color(0.10, 0.10, 0.14, 1)
		st.border_width_left = 1
		st.border_width_top = 1
		st.border_width_right = 1
		st.border_width_bottom = 1
		st.border_color = Color("f2deaa") if i == selected_index else Color(0.45, 0.38, 0.26, 1)
		btn.add_theme_stylebox_override("normal", st)
		btn.add_theme_stylebox_override("hover", st)
		btn.add_theme_stylebox_override("pressed", st)
		var font_col := Color("6f7685") if (i == 1 and not has_save) else (Color("f2deaa") if i == selected_index else Color("d6c7ad"))
		btn.add_theme_color_override("font_color", font_col)

func _input(event: InputEvent) -> void:
	if not visible or event.is_echo() or Engine.get_process_frames() == opened_frame:
		return
	if event.is_action_pressed("move_up") or event.is_action_pressed("ui_up"):
		select_option(selected_index - 1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_down") or event.is_action_pressed("ui_down"):
		select_option(selected_index + 1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		activate_selected()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("dismiss") or event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and (event.keycode == KEY_M or event.keycode == KEY_F10)):
		close_menu()
		get_viewport().set_input_as_handled()
