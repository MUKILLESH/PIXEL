extends Camera2D
## Smooth in floating point, then present an integer-pixel camera transform.
## Supports temporary cinematic focus and zoom with exact snap recovery.
@export var follow_rate: float = 9.0
@export var framing: Vector2 = Vector2(0, -64)
var focus: Vector2
var cinematic_active: bool = false
var cinematic_target_pos: Vector2 = Vector2.ZERO
var target_zoom: Vector2 = Vector2.ONE
@onready var target: Node2D = get_parent() as Node2D

func _ready() -> void:
	top_level = true
	process_physics_priority = 10 # After the player's move_and_slide.
	position_smoothing_enabled = false
	snap_to_target()

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
	focus = target.global_position + framing
	global_position = focus.round()
	force_update_scroll()

func _physics_process(delta: float) -> void:
	if target == null and not cinematic_active:
		return
	var goal: Vector2 = cinematic_target_pos if cinematic_active else (target.global_position + framing)
	focus = focus.lerp(goal, 1.0 - exp(-follow_rate * delta))
	if not cinematic_active and zoom.distance_to(Vector2.ONE) < 0.01:
		zoom = Vector2.ONE
	else:
		zoom = zoom.lerp(target_zoom, 1.0 - exp(-7.0 * delta))
	global_position = focus.round()
	force_update_scroll()
