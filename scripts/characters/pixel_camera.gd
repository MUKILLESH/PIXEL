extends Camera2D
## Smooth in floating point, then present an integer-pixel camera transform.
## Built-in smoothing retains fractional scroll, so it is disabled for this rig.
@export var follow_rate: float = 9.0
@export var framing: Vector2 = Vector2(0, -64)
var focus: Vector2
@onready var target: Node2D = get_parent() as Node2D

func _ready() -> void:
	top_level = true
	process_physics_priority = 10 # After the player's move_and_slide.
	position_smoothing_enabled = false
	snap_to_target()

func snap_to_target() -> void:
	focus = target.global_position + framing
	global_position = focus.round()
	force_update_scroll()

func _physics_process(delta: float) -> void:
	focus = focus.lerp(target.global_position + framing, 1.0 - exp(-follow_rate * delta))
	global_position = focus.round()
	force_update_scroll()
