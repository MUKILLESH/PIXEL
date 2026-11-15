extends CharacterBody2D
## All poses use native pixels; feet remain the physics and sorting origin.
@export var speed: float = 100.0
var facing: int = 2
var movement_locked: bool = false
var stride: float = 0.0
var walk_frame: int = 0

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if movement_locked:
		direction = Vector2.ZERO
	if direction != Vector2.ZERO:
		facing = posmod(roundi(direction.angle() / (PI / 4.0)), 8)
	velocity = direction * speed
	move_and_slide()
	if get_real_velocity().length() > 3.0:
		stride += delta * 9.0
		walk_frame = int(stride) % 4
	else:
		stride = 0.0
		walk_frame = 0
	queue_redraw()

func _draw() -> void:
	# Pixel-stepped ground ellipse stays still while the body bobs.
	draw_rect(Rect2(-8,-2,16,4),Color(0.02,0.04,0.07,0.35))
	draw_rect(Rect2(-6,-3,12,6),Color(0.02,0.04,0.07,0.25))
	var step: int = [0,2,0,-2][walk_frame]
	var bob: int = 1 if walk_frame == 1 or walk_frame == 3 else 0
	var side: int = 1 if facing in [0,1,7] else (-1 if facing in [3,4,5] else 0)
	var back: bool = facing in [5,6,7]
	var profile: bool = facing in [0,4]
	var half: int = 4 if profile else 6
	# One-pixel silhouette edging improves contrast without scaling the body or collider.
	patch(-half-1,-28+bob,half*2+2,17,"172b39")
	patch(-6+side,-40+bob,12,12,"172b39")
	patch(-5+side,-39+bob,4,1,"f1d8a5")
	# Long trousers, independent feet, and counter-swinging arms.
	patch(-half+1,-13,4,11+step,"253c52")
	patch(half-4,-13,4,11-step,"344f62")
	patch(-half,-3+step,5,3,"111e31")
	patch(half-4,-3-step,5,3,"111e31")
	patch(-half-2,-25+bob-step,3,13,"a96640")
	patch(half-1,-25+bob+step,3,13,"e0a363")
	patch(-half-2,-14+bob-step,3,4,"ce9674")
	patch(half-1,-14+bob+step,3,4,"edb58d")
	patch(-half,-27+bob,half*2,15,"df994c")
	patch(-half+1,-26+bob,half*2-3,4,"ffd184")
	patch(-half,-14+bob,half*2,2,"704a38")
	# Neck and smaller head give a recognizable student silhouette.
	patch(-2+side,-30+bob,4,4,"bb805f")
	patch(-5+side,-38+bob,10,9,"e0a783")
	patch(-5+side,-39+bob,10,4,"172638")
	patch(-6+side,-37+bob,2,6,"172638")
	if back:
		patch(-5+side,-35+bob,10,5,"243348")
		patch(-4-side,-25+bob,8,10,"344d61")
		patch(-3-side,-24+bob,6,2,"6c8791")
		patch(-3-side,-20+bob,6,2,"e6ca8d")
		patch(-3-side,-17+bob,6,2,"233849")
	else:
		patch(3*side-1,-34+bob,2,2,"263142")
		if side == 0:
			patch(-3,-34+bob,1,1,"263142")
			patch(3,-34+bob,1,1,"263142")
		else:
			patch(side*5,-33+bob,2,3,"edb58d")
		patch(-2,-25+bob,1,7,"e7d4ab")
		patch(-2,-19+bob,4,4,"d6e5d8")

func patch(x: int, y: int, w: int, h: int, color: String) -> void:
	draw_rect(Rect2(x,y,w,h),Color(color))
