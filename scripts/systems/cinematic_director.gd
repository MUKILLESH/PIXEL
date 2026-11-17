extends Control
class_name CinematicDirector
## Reusable lightweight cinematic event director supporting letterbox framing,
## camera focus/zoom, subtle atmospheric flashes, audio cues, and guaranteed skip recovery.

signal cinematic_started(cinematic_id: String)
signal cinematic_finished(cinematic_id: String, was_skipped: bool)

const AudioManagerScript = preload("res://scripts/systems/audio_manager.gd")

var active: bool = false
var active_id: String = ""
var skipped_last: bool = false
var sequence_mode: bool = false
var sequence_timer: float = 0.0
var bound_hud: CanvasLayer
var on_sequence_complete: Callable = Callable()

var flash_rect: ColorRect
var top_bar: ColorRect
var bottom_bar: ColorRect
var top_rule: ColorRect
var bottom_rule: ColorRect
var event_label: Label
var skip_label: Label
var _flash_alpha: float = 0.0

func _ready() -> void:
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 0.0
	anchor_bottom = 0.0
	position = Vector2.ZERO
	size = Vector2(640, 360)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = true

	flash_rect = ColorRect.new()
	flash_rect.name = "FlashRect"
	flash_rect.position = Vector2.ZERO
	flash_rect.size = size
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_rect.color = Color(0.5, 0.85, 1.0, 0.0)
	add_child(flash_rect)

	top_bar = ColorRect.new()
	top_bar.name = "TopLetterbox"
	top_bar.position = Vector2.ZERO
	top_bar.size = Vector2(size.x, 36.0)
	top_bar.color = Color(0.03, 0.025, 0.05, 0.98)
	top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_bar.visible = false
	add_child(top_bar)

	top_rule = ColorRect.new()
	top_rule.position = Vector2(0.0, 35.0)
	top_rule.size = Vector2(size.x, 1.0)
	top_rule.color = Color(0.78, 0.62, 0.36, 0.92)
	top_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_bar.add_child(top_rule)

	bottom_bar = ColorRect.new()
	bottom_bar.name = "BottomLetterbox"
	bottom_bar.position = Vector2(0.0, size.y - 30.0)
	bottom_bar.size = Vector2(size.x, 30.0)
	bottom_bar.color = Color(0.03, 0.025, 0.05, 0.98)
	bottom_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom_bar.visible = false
	add_child(bottom_bar)

	bottom_rule = ColorRect.new()
	bottom_rule.position = Vector2.ZERO
	bottom_rule.size = Vector2(size.x, 1.0)
	bottom_rule.color = Color(0.78, 0.62, 0.36, 0.92)
	bottom_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom_bar.add_child(bottom_rule)

	event_label = Label.new()
	event_label.name = "EventLabel"
	event_label.text = "CHRONICLE EVENT"
	event_label.position = Vector2(14.0, 14.0)
	event_label.add_theme_font_size_override("font_size", 8)
	event_label.add_theme_color_override("font_color", Color("d9b86c"))
	event_label.visible = false
	add_child(event_label)

	skip_label = Label.new()
	skip_label.name = "SkipHint"
	skip_label.text = "[X] SKIP SCENE"
	skip_label.position = Vector2(size.x - 134.0, 14.0)
	skip_label.size = Vector2(120.0, 12.0)
	skip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	skip_label.add_theme_font_size_override("font_size", 8)
	skip_label.add_theme_color_override("font_color", Color("f2deaa"))
	skip_label.visible = false
	add_child(skip_label)

func _sync_layout() -> void:
	var vp_size: Vector2 = get_viewport_rect().size if get_viewport() != null else Vector2(640, 360)
	if vp_size.x < 10.0 or vp_size.y < 10.0:
		vp_size = Vector2(640, 360)
	if size != vp_size:
		size = vp_size
		if flash_rect != null:
			flash_rect.size = vp_size
		if top_bar != null:
			top_bar.size = Vector2(vp_size.x, 36.0)
			top_rule.size = Vector2(vp_size.x, 1.0)
		if bottom_bar != null:
			bottom_bar.position = Vector2(0.0, vp_size.y - 30.0)
			bottom_bar.size = Vector2(vp_size.x, 30.0)
			bottom_rule.size = Vector2(vp_size.x, 1.0)
		if skip_label != null:
			skip_label.position = Vector2(vp_size.x - 134.0, 14.0)

func _process(delta: float) -> void:
	if _flash_alpha > 0.0:
		_flash_alpha = maxf(0.0, _flash_alpha - delta * 0.45)
		flash_rect.color.a = _flash_alpha
	if active and sequence_mode:
		sequence_timer -= delta
		if sequence_timer <= 0.0:
			var cb: Callable = on_sequence_complete
			on_sequence_complete = Callable()
			_unlock_player()
			finish_story_cinematic(false)
			if cb.is_valid():
				cb.call()

func start_story_cinematic(cinematic_id: String, focus_pos: Vector2, tint: Color = Color(0.55, 0.88, 1.0), sfx_id: String = "") -> void:
	_sync_layout()
	active = true
	active_id = cinematic_id
	sequence_mode = false
	skipped_last = false
	on_sequence_complete = Callable()
	top_bar.visible = true
	bottom_bar.visible = true
	if event_label != null:
		event_label.text = "CHRONICLE - " + cinematic_id.to_upper().replace("_", " ")
		event_label.visible = true
	skip_label.visible = true
	_trigger_flash(tint, 0.24)
	_apply_camera_focus(focus_pos, Vector2(1.10, 1.10))
	if is_inside_tree():
		var audio_mgr := AudioManagerScript.ensure(get_tree())
		if audio_mgr != null and audio_mgr.has_method("set_cinematic_context"):
			audio_mgr.set_cinematic_context(cinematic_id, true)
		if sfx_id != "":
			AudioManagerScript.play_global_sfx(get_tree(), sfx_id)
	cinematic_started.emit(cinematic_id)

func play_sequence(cinematic_id: String, focus_pos: Vector2, duration: float = 1.2, tint: Color = Color(0.55, 0.88, 1.0), complete_cb: Callable = Callable(), sfx_id: String = "") -> void:
	_sync_layout()
	active = true
	active_id = cinematic_id
	sequence_mode = true
	sequence_timer = maxf(0.05, duration)
	skipped_last = false
	on_sequence_complete = complete_cb
	top_bar.visible = true
	bottom_bar.visible = true
	if event_label != null:
		event_label.text = "CHRONICLE - " + cinematic_id.to_upper().replace("_", " ")
		event_label.visible = true
	skip_label.visible = true
	_lock_player()
	_trigger_flash(tint, 0.26)
	_apply_camera_focus(focus_pos, Vector2(1.12, 1.12))
	if is_inside_tree():
		var audio_mgr := AudioManagerScript.ensure(get_tree())
		if audio_mgr != null and audio_mgr.has_method("set_cinematic_context"):
			audio_mgr.set_cinematic_context(cinematic_id, true)
		if sfx_id != "":
			AudioManagerScript.play_global_sfx(get_tree(), sfx_id)
	cinematic_started.emit(cinematic_id)

func finish_story_cinematic(was_skipped: bool = false) -> void:
	if not active:
		return
	var ended_id: String = active_id
	active = false
	sequence_mode = false
	active_id = ""
	top_bar.visible = false
	bottom_bar.visible = false
	if event_label != null:
		event_label.visible = false
	skip_label.visible = false
	_flash_alpha = 0.0
	flash_rect.color.a = 0.0
	_clear_camera_focus()
	if is_inside_tree():
		var audio_mgr := AudioManagerScript.ensure(get_tree())
		if audio_mgr != null and audio_mgr.has_method("set_cinematic_context"):
			audio_mgr.set_cinematic_context(ended_id, false)
	cinematic_finished.emit(ended_id, was_skipped)

func skip_cinematic() -> void:
	if not active:
		return
	skipped_last = true
	if sequence_mode:
		var cb: Callable = on_sequence_complete
		on_sequence_complete = Callable()
		_unlock_player()
		finish_story_cinematic(true)
		if cb.is_valid():
			cb.call()
	else:
		if bound_hud != null and bound_hud.has_method("_close_dialogue"):
			bound_hud._close_dialogue(true)
		finish_story_cinematic(true)

func _trigger_flash(tint: Color, alpha_start: float) -> void:
	flash_rect.color = Color(tint.r, tint.g, tint.b, alpha_start)
	_flash_alpha = alpha_start

func _apply_camera_focus(world_pos: Vector2, zoom_val: Vector2) -> void:
	if bound_hud == null or bound_hud.get("player") == null:
		return
	var p: Node = bound_hud.get("player")
	var cam: Node = p.get_node_or_null("Camera2D")
	if cam != null and cam.has_method("set_cinematic_focus"):
		cam.set_cinematic_focus(world_pos, zoom_val)

func _clear_camera_focus() -> void:
	if bound_hud == null or bound_hud.get("player") == null:
		return
	var p: Node = bound_hud.get("player")
	var cam: Node = p.get_node_or_null("Camera2D")
	if cam != null and cam.has_method("clear_cinematic_focus"):
		cam.clear_cinematic_focus(true)

func _lock_player() -> void:
	if bound_hud != null and bound_hud.get("player") != null:
		bound_hud.get("player").set("movement_locked", true)

func _unlock_player() -> void:
	if bound_hud != null and bound_hud.get("player") != null:
		bound_hud.get("player").set("movement_locked", false)

func _input(event: InputEvent) -> void:
	if not active or event.is_echo():
		return
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_X:
		var vp: Viewport = get_viewport()
		if vp != null and is_inside_tree():
			vp.set_input_as_handled()
		skip_cinematic()
