extends Node2D
## Original 2:1 projected pixel geometry. Measurements are gameplay units, not metres.
@export_enum("Roof and flank", "Facade bay", "Canopy", "Column", "Name band") var part: int = 0
var bay: int = 0
var anchor := Vector2.ZERO
const CREAM := Color("c6c5ad")
const LIGHT := Color("e0d9bb")
const GREY := Color("87959a")
const DARK := Color("364955")

static func project(u: float, v: float, height: float = 0) -> Vector2:
	return Vector2(-112 + u - v, -u * 0.5 - v * 0.5 - height).round()

func p(u: float, v: float, height: float = 0) -> Vector2:
	return project(u,v,height) - anchor

func plane(u0: float, u1: float, v: float, bottom: float, top: float, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([p(u0,v,bottom),p(u1,v,bottom),p(u1,v,top),p(u0,v,top)]),color)

func slab(u0: float, u1: float, v0: float, v1: float, height: float, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([p(u0,v0,height),p(u1,v0,height),p(u1,v1,height),p(u0,v1,height)]),color)

func _draw() -> void:
	match part:
		0: draw_shell()
		1: draw_bay()
		2: draw_canopy()
		3:
			draw_rect(Rect2(-3,-27,6,27),GREY)
			draw_rect(Rect2(-3,-27,2,27),LIGHT)
		4:
			var transform := Transform2D(Vector2(1,-0.5),Vector2(0,1),p(58,-6,104))
			draw_set_transform_matrix(transform)
			draw_string(preload("res://assets/fonts/after_hours.tres"),Vector2.ZERO,"SILVER JUBILEE TOWER",HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("425763"))

func draw_shell() -> void:
	# The photographed left flank; unseen rear details intentionally omitted.
	draw_colored_polygon(PackedVector2Array([p(0,0),p(0,64),p(0,64,112),p(0,0,112)]),Color("9ba89f"))
	for floor_index in range(7):
		for depth in [12,34,54]:
			var h: int = 10 + floor_index * 13
			draw_colored_polygon(PackedVector2Array([p(0,depth,h),p(0,depth+7,h),p(0,depth+7,h+7),p(0,depth,h+7)]),DARK)
	# Dark external stair motif visible in the oblique reference; simplified bracing.
	for d in [25,42]:
		draw_line(p(-2,d,0),p(-2,d,108),DARK,2)
	for h in range(4,105,13):
		draw_line(p(-3,25,h),p(-3,42,h+10),Color("59717a"),2)
		draw_line(p(-3,25,h),p(-3,42,h),DARK,2)
	slab(0,224,0,64,112,Color("b1b6a8"))
	plane(0,224,0,110,114,LIGHT)
	# Low plain rooftop enclosures only; service equipment is not evidenced.
	for u in [30,164]:
		plane(u,u+24,38,112,122,CREAM)
		slab(u,u+24,38,55,122,LIGHT)
	# Corner and central open slatted structures are the principal roof signature.
	for span: Vector2 in [Vector2(0,44),Vector2(66,158),Vector2(180,224)]:
		var height: int = 128 if span.x == 66 else 121
		for u in range(int(span.x),int(span.y)+1,8):
			draw_line(p(u,-9,height),p(u,28,height),LIGHT,2)
		for v in [-9,28]:
			draw_line(p(span.x,v,height),p(span.y,v,height),LIGHT,3)
		for u: float in [span.x+4,span.y-4]:
			draw_line(p(u,0,112),p(u,0,height),CREAM,3)

func draw_bay() -> void:
	var u: int = bay * 16
	plane(u,u+16,0,0,112,CREAM if bay % 3 else Color("ceccb4"))
	plane(u,u+16,0,0,4,Color("6e8285"))
	# Central silver cladding and dark inner inverted-U portal.
	if bay >= 4 and bay <= 9:
		plane(u,u+16,-1,0,77,GREY)
	if bay >= 5 and bay <= 8:
		plane(u,u+16,-2,0,64,DARK)
		plane(u+4 if bay == 5 else u,u+12 if bay == 8 else u+16,-3,0,55,CREAM)
	for floor_index in range(7):
		var h: int = 10 + floor_index * 13
		if bay in [5,8] and h < 64:
			continue # Preserve uninterrupted dark uprights of the central frame.
		plane(u+3,u+13,-4,h,h+7,Color("344b57"))
		for mullion in [6,10]:
			draw_line(p(u+mullion,-5,h),p(u+mullion,-5,h+7),Color("c3c8b8"),1)
		draw_line(p(u+2,-5,h-1),p(u+14,-5,h-1),LIGHT,1)
	# Shaded entrance opening; exact doors are unknown, so no invented door ornament.
	if bay in [6,7]:
		plane(u,u+16,-5,0,18,Color("1b303e"))
	plane(u,u+16,-1,105,112,LIGHT)

func draw_canopy() -> void:
	slab(72,152,-48,0,26,Color("9ba6a4"))
	for v in range(-44,-2,8):
		draw_line(p(74,v,27),p(150,v,27),Color("c3b9a4"),2)
	plane(72,152,-48,21,27,Color("829295"))
	draw_colored_polygon(PackedVector2Array([p(72,-48,21),p(72,0,21),p(72,0,27),p(72,-48,27)]),Color("596f79"))
	draw_line(p(72,-48,27),p(152,-48,27),LIGHT,2)
