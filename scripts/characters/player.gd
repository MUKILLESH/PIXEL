extends CharacterBody2D
## Aren, apprentice mapmaker of Bellhaven Village. Native-pixel art; feet are physics/sorting origin.
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
	# Ground shadow remains stationary at the feet while the stride bobs.
	draw_rect(Rect2(-8,-2,16,4),Color(0.02,0.03,0.05,0.38))
	draw_rect(Rect2(-6,-3,12,6),Color(0.02,0.03,0.05,0.28))
	var step: int = [0,2,0,-2][walk_frame]
	var bob: int = 1 if walk_frame == 1 or walk_frame == 3 else 0
	var side: int = 1 if facing in [0,1,7] else (-1 if facing in [3,4,5] else 0)
	var back: bool = facing in [5,6,7]
	var profile: bool = facing in [0,4]
	var half: int = 4 if profile else 6

	# Dark medieval ink silhouette outline
	patch(-half-1,-28+bob,half*2+2,17,"161924")
	patch(-6+side,-40+bob,12,12,"161924")
	patch(-5+side,-39+bob,4,1,"7a4f34")

	# Wool breeches & cuffed leather boots
	patch(-half+1,-13,4,10+step,"2a303d")
	patch(half-4,-13,4,10-step,"363d4d")
	patch(-half,-5+step,5,2,"4a3020")
	patch(half-4,-5-step,5,2,"4a3020")
	patch(-half,-3+step,5,3,"2d1c12")
	patch(half-4,-3-step,5,3,"2d1c12")

	# Russet cloak sleeves & gloved wrists
	patch(-half-2,-25+bob-step,3,12,"8c5233")
	patch(half-1,-25+bob+step,3,12,"a86540")
	patch(-half-2,-15+bob-step,3,4,"5c3a21")
	patch(half-1,-15+bob+step,3,4,"6e472b")
	patch(-half-2,-12+bob-step,3,2,"ce9674")
	patch(half-1,-12+bob+step,3,2,"edb58d")

	# Forest-green adventurer tunic, skirt flare, leather belt & brass buckle
	patch(-half,-27+bob,half*2,16,"3b6348")
	patch(-half+1,-26+bob,half*2-3,5,"527d5c")
	patch(-half,-15+bob,half*2,2,"472d1e")
	if not back:
		patch(-1,-15+bob,2,2,"e6b85c")
	# Traveler's shoulder mantle / cloak collar
	patch(-half,-28+bob,half*2,3,"4d3326")

	# Neck, face, and chestnut hair
	patch(-2+side,-30+bob,4,3,"bb805f")
	patch(-5+side,-38+bob,10,9,"e0a783")
	patch(-5+side,-39+bob,10,4,"593825")
	patch(-6+side,-37+bob,2,6,"593825")

	if back:
		# Draped hood & back hair
		patch(-5+side,-35+bob,10,5,"4d3326")
		patch(-5+side,-30+bob,10,4,"5e3e2e")
		# Leather mapmaker's scroll satchel with rolled parchment & brass clasp
		patch(-4-side,-25+bob,8,10,"6e472b")
		patch(-4-side,-27+bob,6,2,"d9c498") # Rolled map scroll peeking out
		patch(-3-side,-24+bob,6,2,"8c5c38")
		patch(-1-side,-21+bob,2,2,"e6b85c") # Brass clasp
		patch(-3-side,-17+bob,6,2,"472d1e")
	else:
		patch(3*side-1,-34+bob,2,2,"263142")
		if side == 0:
			patch(-3,-34+bob,1,1,"263142")
			patch(3,-34+bob,1,1,"263142")
		else:
			patch(side*5,-33+bob,2,3,"edb58d")
		# Cross-body leather strap & brass compass pouch
		patch(-3,-26+bob,2,3,"5c3a21")
		patch(-1,-23+bob,2,3,"5c3a21")
		patch(1,-20+bob,2,4,"5c3a21")
		patch(1,-18+bob,3,3,"d4a94e")

func patch(x: int, y: int, w: int, h: int, color: String) -> void:
	draw_rect(Rect2(x,y,w,h),Color(color))
