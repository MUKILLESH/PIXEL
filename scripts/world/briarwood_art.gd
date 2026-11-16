extends RefCounted
## Briarwood-only drawing vocabulary. Integer clusters, feet-origin, no collision changes.
static func poly(c: CanvasItem, points: Array, color: String) -> void:
	c.draw_colored_polygon(PackedVector2Array(points),Color(color))

static func block(c: CanvasItem, p: Vector2, w: float, d: float, h: float) -> void:
	poly(c,[p+Vector2(-w,0),p+Vector2(0,d),p+Vector2(0,d-h),p+Vector2(-w,-h)],"52655e")
	poly(c,[p+Vector2(0,d),p+Vector2(w,0),p+Vector2(w,-h),p+Vector2(0,d-h)],"303e3e")
	poly(c,[p+Vector2(-w,-h),p+Vector2(0,-d-h),p+Vector2(w,-h),p+Vector2(0,d-h)],"768378")
	c.draw_line(p+Vector2(-w,-h),p+Vector2(0,d-h),Color("a0a68a"),1)

static func fern(c: CanvasItem, p: Vector2, tint: String = "638258") -> void:
	for side in [-1,1]:
		c.draw_line(p,p+Vector2(side*7,-10),Color("345c45"),1)
		for j in range(1,5):
			c.draw_line(p+Vector2(side*j,-j*2),p+Vector2(side*(j+4),-j*2),Color(tint),1)
			c.draw_line(p+Vector2(side*j,-j*2),p+Vector2(side*j,-j*2-3),Color(tint),1)

static func tree(c: Node2D, pine: bool = false) -> void:
	var seed_value: int = absi(int(c.position.x)*13+int(c.position.y)*7)
	var lift: int = seed_value%3*7
	# Ground-contact roots, not a floating sphere with a cylindrical stem.
	poly(c,[Vector2(-17,2),Vector2(-5,-10),Vector2(-7,-46-lift),Vector2(2,-61-lift),Vector2(7,-29),Vector2(5,-8),Vector2(16,3),Vector2(2,0)],"26302b")
	poly(c,[Vector2(-11,0),Vector2(-3,-13),Vector2(-4,-47-lift),Vector2(1,-53-lift),Vector2(2,-13),Vector2(8,0)],"65563b")
	c.draw_line(Vector2(-2,-5),Vector2(-1,-40-lift),Color("96805a"),1)
	for i in range(5):
		c.draw_line(Vector2(2,-9-i*6),Vector2(4,-13-i*6),Color("353b2e"),2)
	c.draw_line(Vector2(0,-29),Vector2(-20,-50-lift),Color("584a34"),4)
	c.draw_line(Vector2(1,-35),Vector2(20,-54-lift),Color("584a34"),3)
	if pine:
		for tier in range(4):
			var y: int = -20-tier*15-lift
			var w: int = 26-tier*5
			poly(c,[Vector2(-w,y),Vector2(-w+6,y-5),Vector2(-w+3,y-5),Vector2(0,y-28),Vector2(w-4,y-5),Vector2(w-8,y-5),Vector2(w,y),Vector2(9,y+4),Vector2(4,y+1),Vector2(-8,y+5)],"183d35")
			poly(c,[Vector2(-w+5,y-2),Vector2(0,y-25),Vector2(5,y-9),Vector2(-2,y-10),Vector2(-5,y-4)],"46795a")
			c.draw_line(Vector2(-w+7,y-3),Vector2(-5,y-5),Color("709364"),2)
	else:
		var centers := [Vector2(-24,-48),Vector2(23,-48),Vector2(-15,-68),Vector2(13,-73),Vector2(0,-48)]
		for i in range(centers.size()):
			var p: Vector2 = centers[i]-Vector2(0,lift)
			var rng := RandomNumberGenerator.new()
			rng.seed = seed_value+i*199
			var outline := PackedVector2Array()
			for k in range(16):
				var a: float = TAU*k/16.0
				var radius: float = rng.randf_range(17,24)
				outline.append(p+Vector2(round(cos(a)*radius/3)*3,round(sin(a)*radius*0.7/3)*3))
			c.draw_colored_polygon(outline,Color("172f2c"))
			for k in range(outline.size()): outline[k] = p+((outline[k]-p)*0.86).round()-Vector2(0,3)
			c.draw_colored_polygon(outline,Color("315941") if seed_value%2 else Color("315b50"))
			for j in range(14):
				var q := p+Vector2(rng.randi_range(-15,13),rng.randi_range(-13,8))
				var col := Color("527b50") if q.y < p.y else Color("24493c")
				if j%5 == 0: col = Color("849c60") if i < 4 else Color("496f4d")
				c.draw_rect(Rect2(q,Vector2(6,3)),col)
				c.draw_rect(Rect2(q+Vector2(2,-2),Vector2(3,6)),col)
		# Hanging moss reads as thin broken strands, leaving the trunk visible.
		for x in [-24,16]:
			c.draw_line(Vector2(x,-39-lift),Vector2(x,-23-lift),Color("557747"),1)
			c.draw_rect(Rect2(x-1,-30-lift,3,4),Color("789253"))
	fern(c,Vector2(-9,2),"567549")

static func pillar(c: CanvasItem, height: int = 32) -> void:
	block(c,Vector2.ZERO,10,5,5)
	block(c,Vector2(0,-5),6,3,height)
	for y in range(-height,-8,7):
		c.draw_line(Vector2(-6,y),Vector2(0,y+3),Color("303e3e"),1)
	c.draw_line(Vector2(-3,-height+3),Vector2(-2,-13),Color("b0ae88"),1)
	poly(c,[Vector2(-5,-height-6),Vector2(0,-height-10),Vector2(7,-height-5),Vector2(3,-height-1)],"859080")
	c.draw_line(Vector2(5,-height+4),Vector2(2,-9),Color("4a7049"),3)
	fern(c,Vector2(-8,1))

static func mirror(c: CanvasItem, active: bool = false) -> void:
	block(c,Vector2.ZERO,10,5,5)
	block(c,Vector2(0,-4),5,3,13)
	var rim := "8be6f0" if active else "baaa71"
	poly(c,[Vector2(-9,-23),Vector2(-5,-34),Vector2(4,-36),Vector2(10,-27),Vector2(6,-17),Vector2(-4,-15)],"243734")
	poly(c,[Vector2(-7,-23),Vector2(-4,-32),Vector2(3,-34),Vector2(8,-27),Vector2(5,-19),Vector2(-3,-17)],rim)
	poly(c,[Vector2(-5,-23),Vector2(-3,-30),Vector2(2,-32),Vector2(6,-27),Vector2(3,-21),Vector2(-2,-19)],"397a86")
	c.draw_line(Vector2(-3,-25),Vector2(3,-29),Color("dcf2cc"),2)
	c.draw_rect(Rect2(-2,-9,3,3),Color(rim))
	c.draw_line(Vector2(-11,-23),Vector2(-7,-12),Color("8d8059"),2)

static func beacon(c: CanvasItem, active: bool) -> void:
	block(c,Vector2(0,1),22,11,5)
	block(c,Vector2(0,-5),17,8,5)
	block(c,Vector2(0,-10),10,5,25)
	block(c,Vector2(0,-34),14,7,4)
	for x in [-6,4]:
		c.draw_line(Vector2(x,-13),Vector2(x,-29),Color("b7b591"),1)
	c.draw_rect(Rect2(-3,-25,3,6),Color("81e3e4") if active else Color("47646a"))
	for x in [-15,15]:
		c.draw_line(Vector2(x,-31),Vector2(x,-54),Color("9c9768"),2)
		c.draw_line(Vector2(x,-54),Vector2(x*0.6,-59),Color("e2c786"),2)
	poly(c,[Vector2(0,-67),Vector2(9,-48),Vector2(0,-38),Vector2(-8,-48)],"80e7e0" if active else "426775")
	poly(c,[Vector2(0,-67),Vector2(0,-38),Vector2(-8,-48)],"c8fff0" if active else "719da0")
	c.draw_line(Vector2(-4,-49),Vector2(4,-49),Color("fff3b2") if active else Color("a4b8a2"),1)
	fern(c,Vector2(-16,2))
