extends Node2D
## Deterministic patrolling Shadow Sentinel for Ironwatch Keep's Shadowed Passage.
## Uses oscillating horizontal patrols and visible danger/caution gaze rings (no combat).

@export var patrol_center_x: float = -160.0
@export var patrol_amplitude: float = 34.0
@export var patrol_speed: float = 1.25
@export var phase_offset: float = 0.0
@export var detection_radius: float = 16.0
@export var caution_radius: float = 32.0

var phase: float = 0.0
var cleared: bool = false
var player_in_caution: bool = false

func _ready() -> void:
	phase = phase_offset
	_update_patrol_position()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not cleared:
		phase = fmod(phase + delta * patrol_speed, TAU)
		_update_patrol_position()
	else:
		phase = fmod(phase + delta * 0.6, TAU)
	queue_redraw()

func set_patrol_phase(new_phase: float) -> void:
	phase = fmod(new_phase, TAU)
	_update_patrol_position()
	queue_redraw()

func _update_patrol_position() -> void:
	position.x = patrol_center_x + sin(phase) * patrol_amplitude

func _draw() -> void:
	if cleared:
		# Dormant calmed wisp floating quietly
		var bob: float = sin(phase * 2.0) * 2.0
		draw_circle(Vector2(0, -14 + bob), 5.0, Color(0.50, 0.88, 0.96, 0.42))
		draw_circle(Vector2(0, -14 + bob), 2.5, Color(0.88, 0.98, 1.0, 0.72))
		return

	# Active Sentinel Detection & Caution Rings on dungeon flagstones
	var gaze_col := Color(0.95, 0.25, 0.42, 0.52) if player_in_caution else Color(0.68, 0.28, 0.78, 0.34)
	draw_circle(Vector2.ZERO, detection_radius, Color(0.55, 0.16, 0.44, 0.20))
	draw_arc(Vector2.ZERO, detection_radius, 0.0, TAU, 24, gaze_col, 1.6)
	if player_in_caution:
		draw_arc(Vector2.ZERO, caution_radius, 0.0, TAU, 28, Color(0.96, 0.76, 0.32, 0.45), 1.2)

	# Spectral Hooded Bell-Sentinel sprite silhouette
	var hover: float = sin(phase * 2.0) * 1.5
	draw_rect(Rect2(-6, -24 + hover, 12, 16), Color("1f1730"))
	draw_rect(Rect2(-4, -22 + hover, 8, 13), Color("4e2b75"))
	draw_rect(Rect2(-5, -32 + hover, 10, 9), Color("2b1d45"))
	# Glowing crimson-violet watcher eyes
	draw_rect(Rect2(-3, -29 + hover, 2, 2), Color("ff5c7c"))
	draw_rect(Rect2(1, -29 + hover, 2, 2), Color("ff5c7c"))
	# Suspended swinging ward-bell core
	draw_circle(Vector2(0, -13 + hover), 2.5, Color("ff9e5e"))
