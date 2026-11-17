extends Camera2D
## Smooth in floating point, then present an integer-pixel camera transform.
## Enforces zoom- and viewport-aware map limits so empty outside-map terrain is never exposed.

@export var follow_rate: float = 9.0
@export var framing: Vector2 = Vector2(0, -64)

var focus: Vector2
var cinematic_active: bool = false
var cinematic_target_pos: Vector2 = Vector2.ZERO
var target_zoom: Vector2 = Vector2.ONE
var bounds_enabled: bool = false
var min_bounds: Vector2 = Vector2(-640.0, -360.0)
var max_bounds: Vector2 = Vector2(640.0, 360.0)

@onready var target: Node2D = get_parent() as Node2D


func _ready() -> void:
	top_level = true
	process_physics_priority = 10 # After the player's move_and_slide.
	position_smoothing_enabled = false
	snap_to_target()


func set_camera_limits(left: float, top: float, right: float, bottom: float) -> void:
	bounds_enabled = true
	min_bounds = Vector2(left, top)
	max_bounds = Vector2(right, bottom)
	limit_left = int(floor(left))
	limit_top = int(floor(top))
	limit_right = int(ceil(right))
	limit_bottom = int(ceil(bottom))
	snap_to_target()


func clear_camera_limits() -> void:
	bounds_enabled = false
	limit_left = -10000000
	limit_top = -10000000
	limit_right = 10000000
	limit_bottom = 10000000


func _clamp_focus_to_bounds(pos: Vector2, cur_zoom: Vector2) -> Vector2:
	if not bounds_enabled:
		return pos
	var vp_size := Vector2(640.0, 360.0)
	if is_inside_tree() and get_viewport() != null:
		var r := get_viewport_rect().size
		if r.x >= 10.0 and r.y >= 10.0:
			vp_size = r
	var z := Vector2(maxf(0.25, cur_zoom.x), maxf(0.25, cur_zoom.y))
	var half_view := (vp_size * 0.5) / z
	var out := pos
	var min_cx: float = min_bounds.x + half_view.x
	var max_cx: float = max_bounds.x - half_view.x
	if min_cx >= max_cx:
		out.x = (min_bounds.x + max_bounds.x) * 0.5
	else:
		out.x = clampf(out.x, min_cx, max_cx)

	var min_cy: float = min_bounds.y + half_view.y
	var max_cy: float = max_bounds.y - half_view.y
	if min_cy >= max_cy:
		out.y = (min_bounds.y + max_bounds.y) * 0.5
	else:
		out.y = clampf(out.y, min_cy, max_cy)
	return out


func set_cinematic_focus(world_pos: Vector2, zoom_val: Vector2 = Vector2(1.12, 1.12)) -> void:
	cinematic_active = true
	cinematic_target_pos = world_pos
	target_zoom = zoom_val


func clear_cinematic_focus(snap_immediately: bool = false) -> void:
	cinematic_active = false
	target_zoom = Vector2.ONE
	if snap_immediately:
		zoom = Vector2.ONE
		snap_to_target()


func snap_to_target() -> void:
	if target == null:
		return
	focus = _clamp_focus_to_bounds(target.global_position + framing, zoom)
	global_position = focus.round()
	force_update_scroll()


func _physics_process(delta: float) -> void:
	if target == null and not cinematic_active:
		return
	if not cinematic_active and zoom.distance_to(Vector2.ONE) < 0.01:
		zoom = Vector2.ONE
	else:
		zoom = zoom.lerp(target_zoom, 1.0 - exp(-7.0 * delta))

	var raw_goal: Vector2 = cinematic_target_pos if cinematic_active else (target.global_position + framing)
	var clamped_goal: Vector2 = raw_goal if cinematic_active else _clamp_focus_to_bounds(raw_goal, zoom)
	focus = focus.lerp(clamped_goal, 1.0 - exp(-follow_rate * delta))
	if not cinematic_active:
		focus = _clamp_focus_to_bounds(focus, zoom)
	global_position = focus.round()
	force_update_scroll()
