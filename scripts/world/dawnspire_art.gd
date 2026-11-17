extends RefCounted
## Original Dawnspire pixel geometry. All coordinates are native pixels; no external art.
static var textures: Dictionary = {}
static func texture(name: String) -> Texture2D:
	if not textures.has(name): textures[name] = load("res://assets/dawnspire/"+name+".png")
	return textures[name]
static func poly(c: Node2D, points: Array, color: String) -> void:
	c.draw_colored_polygon(PackedVector2Array(points),Color(color))
static func stone(c: Node2D, r: Rect2) -> void:
	c.draw_rect(r,Color("30384c"))
	for y in range(int(r.position.y),int(r.end.y),7):
		for x in range(int(r.position.x),int(r.end.x),13):
			var ox: int = 6 if posmod(y,14)==0 else 0
			var cell := Rect2(x+ox,y,12,6).intersection(r)
			if cell.has_area():
				c.draw_rect(cell,Color("505c70") if posmod(x+y,4)==0 else Color("424e63"))
				c.draw_line(cell.position,cell.position+Vector2(cell.size.x,0),Color("617087"))
static func diamond(c: Node2D, p: Vector2, w: float, color: String) -> void:
	poly(c,[p+Vector2(-w,0),p+Vector2(0,-w/2),p+Vector2(w,0),p+Vector2(0,w/2)],color)
static func platform(c: Node2D,p: Vector2,w: float) -> void:
	for y in range(8,0,-2): diamond(c,p+Vector2(0,y),w+float(y), "33394e" if y%4==0 else "566176")
	diamond(c,p,w,"626e80")
	diamond(c,p,w-3,"414b63")
static func column(c: Node2D,p: Vector2,h: float) -> void:
	diamond(c,p+Vector2(0,3),13,"22283a")
	stone(c,Rect2(p.x-8,p.y-h,16,h))
	c.draw_rect(Rect2(p.x-5,p.y-h+5,2,h-11),Color("8b98a4"))
	poly(c,[p+Vector2(8,-h),p+Vector2(15,-h-4),p+Vector2(15,-4),p+Vector2(8,0)],"30374c")
	for dy: float in [0.0,-h+4]:
		c.draw_rect(Rect2(p.x-10,p.y+dy-4,22,5),Color("8f774d"))
		c.draw_line(p+Vector2(-10,dy-4),p+Vector2(11,dy-4),Color("ceb77b"))
	diamond(c,p+Vector2(0,-h),12,"a4b0b8")
static func arch(c: Node2D,p: Vector2,w: float,h: float,lit: bool) -> void:
	poly(c,[p+Vector2(-w,0),p+Vector2(-w,-h+14),p+Vector2(0,-h),p+Vector2(w,-h+14),p+Vector2(w,0)],"a68c5d")
	poly(c,[p+Vector2(-w+3,0),p+Vector2(-w+3,-h+15),p+Vector2(0,-h+4),p+Vector2(w-3,-h+15),p+Vector2(w-3,0)],"192333")
	if lit:
		poly(c,[p+Vector2(-w+5,-1),p+Vector2(-w+5,-h+17),p+Vector2(0,-h+8),p+Vector2(w-5,-h+17),p+Vector2(w-5,-1)],"a17b43")
		c.draw_line(p+Vector2(0,-h+10),p+Vector2(0,-2),Color("ffe3a0"),2)
	for y in range(10,int(h)-13,8):
		c.draw_line(p+Vector2(-w+3,-y),p+Vector2(w-3,-y),Color("514538"))
static func ring(c: Node2D,p: Vector2,rx: float,ry: float,color: String) -> void:
	var pts := PackedVector2Array()
	for i in range(49):
		var a: float = i*TAU/48
		pts.append((p+Vector2(cos(a)*rx,sin(a)*ry)).round())
	c.draw_polyline(pts,Color(color),1,false)
static func emblem(c: Node2D,p: Vector2,kind: int) -> void:
	match kind:
		0:
			c.draw_circle(p,4,Color("ffe1a0"))
			for i in range(8):
				var v := Vector2.from_angle(i*TAU/8)
				c.draw_line((p+v*6).round(),(p+v*9).round(),Color("e3bc72"))
		1:
			c.draw_circle(p,7,Color("a3dbea"))
			c.draw_circle(p+Vector2(3,-2),6,Color("30384c"))
		2:
			poly(c,[p+Vector2(0,-9),p+Vector2(2,-2),p+Vector2(8,0),p+Vector2(2,2),p+Vector2(0,9),p+Vector2(-2,2),p+Vector2(-8,0),p+Vector2(-2,-2)],"cbb7ed")
static func pine(c: Node2D,p: Vector2,h: int = 54) -> void:
	diamond(c,p+Vector2(9,4),18,"242d3e")
	c.draw_rect(Rect2(p.x-2,p.y-22,5,23),Color("665247"))
	for i in range(4):
		var y: float = p.y-8-i*10
		var w: float = 21-i*4
		poly(c,[Vector2(p.x-w,y),Vector2(p.x-w+5,y-8),Vector2(p.x-4,y-h/2.8),Vector2(p.x+w-3,y-6),Vector2(p.x+w,y+1)],"1d393c")
		poly(c,[Vector2(p.x-w+3,y-3),Vector2(p.x-4,y-h/2.8),Vector2(p.x+2,y-8),Vector2(p.x-4,y-5)],"3f6460")
		c.draw_line(Vector2(p.x-w+4,y-5),Vector2(p.x-4,y-10),Color("77938d"))
static func building(c: Node2D,kind: String,active: bool) -> void:
	poly(c,[Vector2(-40,0),Vector2(22,-12),Vector2(70,12),Vector2(8,24)],"10172a55")
	match kind:
		"foothills_arch":
			for x in [-34,34]: column(c,Vector2(x,0),76)
			stone(c,Rect2(-47,-87,94,14))
			arch(c,Vector2(0,-28),22,46,false)
			for x in [-28,0,28]: emblem(c,Vector2(x,-80),0)
			c.draw_line(Vector2(-47,-88),Vector2(47,-88),Color("d2dce0"),2)
		"cliff_shelter":
			stone(c,Rect2(-22,-42,44,42))
			poly(c,[Vector2(-28,-42),Vector2(-5,-62),Vector2(29,-45),Vector2(7,-34)],"7b8998")
			poly(c,[Vector2(-28,-42),Vector2(-5,-62),Vector2(9,-52),Vector2(-14,-42)],"b5c5ce")
			arch(c,Vector2(0,0),12,33,true)
			c.draw_rect(Rect2(-25,-4,50,4),Color("788295"))
		"skybridge_anchors":
			for x in [-46,46]:
				column(c,Vector2(x,0),46)
				stone(c,Rect2(x-9,-28,18,19))
				c.draw_circle(Vector2(x,-22),10,Color("302b31"))
				for i in range(12):
					var v := Vector2.from_angle(i*TAU/12)
					c.draw_line(Vector2(x,-22)+v*5,Vector2(x,-22)+v*10,Color("b3935b"),2)
				c.draw_circle(Vector2(x,-22),3,Color("ecd095"))
				for y in range(-42,-6,6): c.draw_rect(Rect2(x-3,y,6,4),Color("6e5843"),false)
		"pilgrim_chapel":
			stone(c,Rect2(-58,-68,116,68))
			for x in [-53,53]: column(c,Vector2(x,0),78)
			poly(c,[Vector2(-65,-76),Vector2(-8,-110),Vector2(65,-76),Vector2(6,-47)],"493446")
			poly(c,[Vector2(-65,-76),Vector2(-8,-110),Vector2(6,-98),Vector2(-46,-72)],"b3c3ce")
			for x in range(-45,46,15):
				c.draw_line(Vector2(x,-73),Vector2(x+20,-63),Color("87606b"))
			c.draw_line(Vector2(-57,-67),Vector2(57,-67),Color("ac845a"),3)
			for x in [-32,0,32]:
				arch(c,Vector2(x,-14),11,46,true)
				emblem(c,Vector2(x,-34),posmod(x/32+1,3))
			for x in [-45,45]:
				c.draw_rect(Rect2(x-2,-14,4,10),Color("d9c28d"))
				c.draw_rect(Rect2(x-1,-18,2,4),Color("fff0b0"))
		"observatory_dome":
			for x in [-34,34]: column(c,Vector2(x,0),66)
			arch(c,Vector2(0,-2),25,65,false)
			for i in range(4):
				ring(c,Vector2(0,-79),float(42-i*7),float(15+i*2),"bd9e64")
			for i in range(16):
				var v := Vector2(cos(i*TAU/16)*42,sin(i*TAU/16)*15)
				c.draw_line((Vector2(0,-79)+v).round(),(Vector2(0,-79)+v*0.9).round(),Color("e2cb94"))
			c.draw_line(Vector2(-38,-97),Vector2(38,-63),Color("ead69d"),2)
			c.draw_line(Vector2(0,-110),Vector2(0,-51),Color("8abacb"),2)
			c.draw_circle(Vector2(0,-79),6,Color("8be6f0"))
			for x in [-22,0,22]: emblem(c,Vector2(x,-39),x/22+1)
		"dawnspire_sanctum":
			for x in [-48,48]: column(c,Vector2(x,0),111)
			arch(c,Vector2(0,-10),32,103,active)
			stone(c,Rect2(-58,-122,116,14))
			for x in [-42,-21,0,21,42]:
				diamond(c,Vector2(x,-115),4,"d3b574")
			for x in [-48,48]:
				poly(c,[Vector2(x-8,-125),Vector2(x,-148),Vector2(x+8,-125),Vector2(x,-114)],"a5e5ec" if active else "658699")
			c.draw_line(Vector2(-58,-124),Vector2(58,-124),Color("c5d6dc"),2)
		"great_bell_portal":
			stone(c,Rect2(-40,-102,80,100))
			for x in [-40,40]: column(c,Vector2(x,0),121)
			arch(c,Vector2(0,0),25,91,active)
			poly(c,[Vector2(-52,-120),Vector2(0,-150),Vector2(52,-120),Vector2(0,-112)],"7d8c9f")
			poly(c,[Vector2(-43,-121),Vector2(0,-144),Vector2(40,-121),Vector2(0,-116)],"343e54")
			emblem(c,Vector2(0,-128),2)
			for x in [-28,28]:
				for y in range(-102,-10,6): c.draw_rect(Rect2(x-2,y,5,5),Color("ac915e"),false)
			for y in range(-96,-85,4): c.draw_line(Vector2(-13,y),Vector2(13,y),Color("cfb57e"))
static func chapel(c: Node2D) -> void:
	diamond(c,Vector2(0,22),55,"3e3946")
	for x in [-36,32]:
		c.draw_rect(Rect2(x-9,14,17,5),Color("795b49"))
		c.draw_rect(Rect2(x-8,19,2,6),Color("3b3034"))
		c.draw_rect(Rect2(x+5,19,2,6),Color("3b3034"))
	# A quiet amber floor pool frames the existing journal; never paints over it.
	poly(c,[Vector2(-20,6),Vector2(-3,8),Vector2(22,36),Vector2(-31,35)],"514b46")
	for x in [-47,44]:
		stone(c,Rect2(x-4,0,8,13))
		c.draw_rect(Rect2(x-1,-3,2,5),Color("fff0b0"))
static func bridge(c: Node2D,repaired: bool) -> void:
	c.draw_rect(Rect2(-25,-48,50,50),Color("171d2a"))
	for y in range(-48,2,6):
		if not repaired and y > -37 and y < -10: continue
		var tilt: float = 0 if repaired else (y+24)*0.12
		poly(c,[Vector2(-22,y+tilt),Vector2(22,y),Vector2(22,y+5),Vector2(-22,y+5+tilt)],"806950")
		c.draw_line(Vector2(-20,y+1+tilt),Vector2(20,y+1),Color("b49a70"))
		c.draw_line(Vector2(-12,y+3),Vector2(13,y+3),Color("514336"))
	for x in [-24,24]:
		for y in range(-48,2,5):
			var sag: float = 0 if repaired else sin((y+48)*PI/50)*7
			c.draw_rect(Rect2(x+sag,-2+y,3,6),Color("b8a579"),false)
		for y in [-48,-2]:
			c.draw_rect(Rect2(x-2,y-14,5,16),Color("576377"))
			c.draw_rect(Rect2(x-3,y-16,7,4),Color("c4ac74"))
	if not repaired:
		c.draw_line(Vector2(-19,-37),Vector2(-9,-20),Color("87715d"),3)
		c.draw_line(Vector2(17,-9),Vector2(10,-24),Color("87715d"),3)
	# Counterweight positions visibly balance when the original repair flag is true.
	for side in [-1,1]:
		var x: float = side*62
		var y: float = -24 if repaired else (-38 if side < 0 else -8)
		c.draw_line(Vector2(x,-48),Vector2(x,y+8),Color("9d8c70"))
		c.draw_rect(Rect2(x-4,y,8,11),Color("687488"))
		c.draw_rect(Rect2(x-4,y,8,2),Color("bdc9ce"))
		c.draw_rect(Rect2(x-4,y+7,8,2),Color("ae9162"))
