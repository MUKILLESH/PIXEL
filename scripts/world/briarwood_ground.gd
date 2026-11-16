extends Node2D
## Static forest floor. Draw commands are cached by CanvasItem until explicitly changed.
const Art = preload("res://scripts/world/briarwood_art.gd")
const FONT = preload("res://assets/fonts/after_hours.tres")
const TRAILS = [
	[Vector2(0,260),Vector2(0,224),Vector2(5,168),Vector2(-3,126),Vector2(0,88)],
	[Vector2(0,88),Vector2(-66,56),Vector2(-90,12),Vector2(-90,-90),Vector2(-132,-144)],
	[Vector2(0,88),Vector2(88,76),Vector2(158,72)],
	[Vector2(-90,-82),Vector2(114,-92),Vector2(166,-124),Vector2(184,-138)],
	[Vector2(-132,-144),Vector2(-84,-186),Vector2(-32,-206)],
	[Vector2(-24,-108),Vector2(-32,-206),Vector2(78,-200),Vector2(166,-196)]]
func trail_distance(p: Vector2) -> float:
	var distance: float = 10000
	for trail: Array in TRAILS:
		for i in range(trail.size()-1):
			distance = minf(distance,p.distance_to(Geometry2D.get_closest_point_to_segment(p,trail[i],trail[i+1])))
	return distance

func _draw() -> void:
	for trail: Array in TRAILS:
		draw_polyline(PackedVector2Array(trail),Color("27352b"),32)
		draw_polyline(PackedVector2Array(trail),Color("494833"),25)
		draw_polyline(PackedVector2Array(trail),Color("766b49"),18)
		draw_polyline(PackedVector2Array(trail),Color("827853"),8)
	for p: Vector2 in [Vector2(44,180),Vector2(156,72)]:
		Art.poly(self,[p+Vector2(-44,-5),p+Vector2(-22,-22),p+Vector2(22,-22),p+Vector2(44,0),p+Vector2(22,24),p+Vector2(-26,18)],"544e36")
	var rng := RandomNumberGenerator.new()
	rng.seed = 24791
	for i in range(1800):
		var p := Vector2(rng.randi_range(-640,640),rng.randi_range(-390,390))
		var d := trail_distance(p)
		if d < 10:
			if i%3 == 0:
				Art.poly(self,[p+Vector2(-4,0),p+Vector2(1,-3),p+Vector2(7,-1),p+Vector2(2,3)],"a39a75")
				draw_line(p+Vector2(-3,1),p+Vector2(2,3),Color("4e4e3e"),1)
			else:
				draw_rect(Rect2(p,Vector2(4,1)),Color("655e40"))
		elif d > 17:
			var tint := "466749" if i%3 else "385940"
			draw_rect(Rect2(p,Vector2(9,3)),Color("20392f"))
			for j in range(3):
				var q := p+Vector2(j*3,-j%2*2)
				draw_line(q,q+Vector2(-2,-4-j%3),Color(tint),1)
				draw_rect(Rect2(q+Vector2(1,-2),Vector2(3,1)),Color("5e754b"))
			if i%9 == 0: Art.fern(self,p,"557a50")
			if i%11 == 0:
				draw_rect(Rect2(p+Vector2(-2,-4),Vector2(2,5)),Color("b2b795"))
				draw_rect(Rect2(p+Vector2(-5,-6),Vector2(7,3)),Color("60998b") if i%2 else Color("a57b4b"))
		if d > 10 and d < 23:
			draw_rect(Rect2(p,Vector2(4,2)),Color("7e6b3e"))
			draw_rect(Rect2(p+Vector2(3,-1),Vector2(2,1)),Color("b09a5a"))
	# Irregular banks stay OUTSIDE the exact existing river collider and crossing.
	draw_rect(Rect2(-900,-38,1800,34),Color("183f4b"))
	draw_rect(Rect2(-900,-29,1800,17),Color("245a62"))
	for x in range(-900,900,9):
		var offset: int = posmod(x*17,7)
		draw_rect(Rect2(x,-45+offset,9,9),Color("3c4635"))
		draw_rect(Rect2(x,-42+offset,9,5),Color("536048"))
		draw_rect(Rect2(x,-8-offset,9,9),Color("3b4b39"))
		draw_rect(Rect2(x,-5-offset,9,4),Color("637452"))
		if posmod(x*17,11) < 3 and (x < -125 or x > -55):
			Art.block(self,Vector2(x,-33+offset),7,3,4)
			Art.fern(self,Vector2(x+2,-39))
	# Ritual floors: 2:1 diamond steps with individually cracked stones.
	for center: Vector2 in [Vector2(-132,-152),Vector2(-32,-214)]:
		Art.block(self,center+Vector2(0,3),47,24,5)
		Art.block(self,center,40,20,3)
		for u in range(-2,3):
			for v in range(-2,3):
				var p := center+Vector2((u-v)*8,(u+v)*4-4)
				Art.poly(self,[p+Vector2(-7,0),p+Vector2(0,-3),p+Vector2(7,0),p+Vector2(0,3)],"687b6c" if (u+v)%3 else "53675d")
				if (u-v)%3 == 0:
					draw_line(p+Vector2(-4,0),p+Vector2(0,1),Color("2b4941"),1)
		for i in range(8):
			var a: float = i*TAU/8
			var p := center+Vector2(cos(a)*34,sin(a)*17).round()
			draw_line(p,p+Vector2(3,-3),Color("879b7e"),1)
			draw_line(p+Vector2(3,-3),p+Vector2(4,1),Color("879b7e"),1)
	# Tree shadows project consistently southeast and remain under every actor.
	for actor: Node2D in get_parent().get_parent().get_node("Actors").get_children():
		if actor.get("kind") is int and actor.kind in [0,1]:
			var p: Vector2 = actor.position
			Art.poly(self,[p+Vector2(-18,-5),p+Vector2(8,-8),p+Vector2(43,15),p+Vector2(30,23),p+Vector2(8,16)],"20372f")
	# Restrained location text, away from interactive silhouettes.
	for item: Array in [[Vector2(-42,247),"FOREST EDGE"],[Vector2(-48,119),"WHISPERING FORK"],[Vector2(-128,35),"OLD BRIDGE"],[Vector2(-153,-113),"MIRROR GROVE"],[Vector2(156,-110),"RUINED CAMP"],[Vector2(-65,-173),"FIRST BEACON"]]:
		draw_string(FONT,item[0],item[1],HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("a6b494"))
