extends RefCounted
## Original Ironwatch art source. Integer clusters; cold stone, bronze, crimson and violet.
static var textures: Dictionary = {}
static func texture(path: String) -> Texture2D:
	if not textures.has(path): textures[path] = load(path)
	return textures[path]
static func poly(c: CanvasItem, pts: Array, hex: String) -> void:
	c.draw_colored_polygon(PackedVector2Array(pts),Color(hex))
static func block(c: CanvasItem, p: Vector2, w: float, d: float, h: float) -> void:
	poly(c,[p+Vector2(-w,0),p+Vector2(0,d),p+Vector2(0,d-h),p+Vector2(-w,-h)],"51576b")
	poly(c,[p+Vector2(0,d),p+Vector2(w,0),p+Vector2(w,-h),p+Vector2(0,d-h)],"292f43")
	poly(c,[p+Vector2(-w,-h),p+Vector2(0,-d-h),p+Vector2(w,-h),p+Vector2(0,d-h)],"72768a")
	c.draw_line(p+Vector2(-w,-h),p+Vector2(0,d-h),Color("9e9ba0"),1)
static func masonry(c: CanvasItem, box: Rect2, dark: bool = false) -> void:
	c.draw_rect(box,Color("232a3b") if dark else Color("343d50"))
	for y in range(int(box.position.y)+1,int(box.end.y)-3,7):
		var offset: int = 5 if posmod(y,14) < 7 else 0
		for x in range(int(box.position.x)+1,int(box.end.x)-3,13):
			var left: int = mini(x+offset,int(box.end.x)-4)
			var width: int = mini(11,int(box.end.x)-left-1)
			var tint := Color("3e485b") if posmod(x*3+y,5) else Color("505c6b")
			if dark: tint = tint.darkened(0.25)
			c.draw_rect(Rect2(left,y,width,5),tint)
			c.draw_line(Vector2(left,y),Vector2(left+width-1,y),tint.lightened(0.09),1)
			if posmod(x+y*7,31) == 0:
				c.draw_line(Vector2(left+2,y),Vector2(left+4,y+4),Color("20283a"),1)
static func arch(c: CanvasItem, p: Vector2, w: int, h: int, lit: bool = false) -> void:
	var pts := [p+Vector2(-w,0),p+Vector2(-w,-h+9),p+Vector2(-w+5,-h+2),p+Vector2(0,-h-6),p+Vector2(w-5,-h+2),p+Vector2(w,-h+9),p+Vector2(w,0)]
	poly(c,pts,"77778b")
	var inner: Array = []
	for point: Vector2 in pts: inner.append(p+(point-p)*Vector2(0.76,0.92))
	poly(c,inner,"192031")
	var glass: Array = []
	for point: Vector2 in pts: glass.append(p+(point-p)*Vector2(0.55,0.81))
	poly(c,glass,"b4864e" if lit else "283e52")
	c.draw_line(p+Vector2(0,-h+4),p,Color("282d3f"),2)
	for y in range(-h+14,-3,7):
		c.draw_line(p+Vector2(-w+5,y),p+Vector2(w-5,y),Color("384254"),1)
static func banner(c: CanvasItem, p: Vector2, height: int = 30) -> void:
	c.draw_line(p+Vector2(-8,-2),p+Vector2(9,-2),Color("baa577"),2)
	poly(c,[p+Vector2(-6,0),p+Vector2(6,0),p+Vector2(6,height-5),p+Vector2(3,height-2),p+Vector2(0,height-5),p+Vector2(-4,height),p+Vector2(-6,height-4)],"693448")
	c.draw_rect(Rect2(p+Vector2(-4,1),Vector2(2,height-8)),Color("934e58"))
	c.draw_line(p+Vector2(-3,8),p+Vector2(3,8),Color("bfa579"),1)
	c.draw_line(p+Vector2(0,5),p+Vector2(0,14),Color("bfa579"),1)
static func crest(c: CanvasItem, p: Vector2, kind: int) -> void:
	match kind:
		0: # Silver Bell
			poly(c,[p+Vector2(-6,3),p+Vector2(-4,0),p+Vector2(-4,-6),p+Vector2(-2,-9),p+Vector2(2,-9),p+Vector2(4,-6),p+Vector2(4,0),p+Vector2(6,3)],"b8c5d1")
			c.draw_rect(Rect2(p+Vector2(-1,4),Vector2(2,2)),Color("e5dbad"))
			c.draw_line(p+Vector2(-2,-7),p+Vector2(-2,0),Color("f2eed4"),1)
		1: # Sundered Shield
			poly(c,[p+Vector2(-6,-8),p+Vector2(6,-8),p+Vector2(5,1),p+Vector2(0,7),p+Vector2(-5,1)],"8e9caa")
			c.draw_polyline(PackedVector2Array([p+Vector2(2,-8),p+Vector2(-2,-2),p+Vector2(2,1),p+Vector2(-1,6)]),Color("252b3e"),2)
		2: # Crowned Flame
			poly(c,[p+Vector2(0,-7),p+Vector2(5,0),p+Vector2(3,6),p+Vector2(-3,6),p+Vector2(-5,1)],"db9551")
			c.draw_rect(Rect2(p+Vector2(-1,0),Vector2(2,5)),Color("ffdda0"))
			c.draw_line(p+Vector2(-6,-10),p+Vector2(6,-10),Color("d7bd7e"),2)
			for x in [-5,0,5]: c.draw_rect(Rect2(p+Vector2(x,-14),Vector2(2,4)),Color("e2c78a"))
static func pillar(c: CanvasItem, p: Vector2, h: int = 55) -> void:
	block(c,p,9,5,5)
	masonry(c,Rect2(p+Vector2(-6,-h),Vector2(12,h-4)))
	c.draw_rect(Rect2(p+Vector2(2,-h),Vector2(4,h-4)),Color("293147"))
	c.draw_line(p+Vector2(-4,-h+4),p+Vector2(-4,-8),Color("9c9aa5"),1)
	block(c,p+Vector2(0,-h),10,5,5)
static func building(c: CanvasItem, kind: String, lit: bool) -> void:
	match kind:
		"gatehouse_bastion":
			masonry(c,Rect2(-48,-87,96,90))
			poly(c,[Vector2(48,-87),Vector2(61,-94),Vector2(61,-4),Vector2(48,3)],"242c3e")
			for x in range(-48,47,13):
				block(c,Vector2(x+5,-87),6,3,7)
			for x in [-42,42]:
				masonry(c,Rect2(x-11,-103,22,103))
				c.draw_rect(Rect2(x+4,-103,7,103),Color("2d3447"))
				poly(c,[Vector2(x-16,-103),Vector2(x,-146),Vector2(x+16,-103)],"564664")
				poly(c,[Vector2(x,-146),Vector2(x+16,-103),Vector2(x+4,-103)],"312c46")
				for row in range(1,7):
					var y: int = -144+row*6
					var w: int = row*2
					c.draw_line(Vector2(x-w,y),Vector2(x+w,y),Color("88778b"),1)
				c.draw_rect(Rect2(x-1,-151,2,6),Color("d7ba77"))
				arch(c,Vector2(x,-37),6,26,true)
				block(c,Vector2(x,0),14,6,5)
			arch(c,Vector2(0,0),17,39)
			for x in range(-10,11,4):
				c.draw_line(Vector2(x,-24),Vector2(x,0),Color("85745d"),2)
			for y in [-7,-18]:
				c.draw_line(Vector2(-11,y),Vector2(11,y),Color("171e2c"),3)
				for x in [-9,9]: c.draw_rect(Rect2(x,y,1,1),Color("b9b4a5"))
			for x in [-19,19]: banner(c,Vector2(x,-74),24)
			crest(c,Vector2(0,-63),0)
		"ruined_barracks":
			masonry(c,Rect2(-50,-56,100,56))
			poly(c,[Vector2(50,-56),Vector2(60,-61),Vector2(60,-5),Vector2(50,0)],"242d40")
			poly(c,[Vector2(-56,-56),Vector2(-32,-88),Vector2(36,-88),Vector2(56,-56)],"312b43")
			for y in range(-85,-57,5):
				var inset: int = int((-y-56)*0.72)
				for x in range(-53+inset,53-inset,7):
					if x > 24 and y < -69: continue
					c.draw_rect(Rect2(x,y,6,4),Color("665773") if posmod(x+y,5) else Color("85748b"))
					c.draw_line(Vector2(x,y+3),Vector2(x+5,y+3),Color("302b40"),1)
			for x in [22,32,42]:
				c.draw_line(Vector2(x,-58),Vector2(x-10,-86),Color("84725d"),2)
			for x in [-31,28]: arch(c,Vector2(x,-22),8,23,true)
			arch(c,Vector2(0,0),14,32)
			for y in [-5,-17]: c.draw_line(Vector2(-10,y),Vector2(10,y),Color("8c7e69"),2)
			crest(c,Vector2(0,-45),1)
		"cutaway_archives":
			block(c,Vector2(0,14),68,34,5)
		"hall_of_crests":
			masonry(c,Rect2(-48,-78,96,56))
			for x in [-48,-16,16,48]: pillar(c,Vector2(x,-20),58)
			for i in range(3):
				var x: int = -32+i*32
				arch(c,Vector2(x,-26),13,39)
				crest(c,Vector2(x,-41),i)
			block(c,Vector2(0,-80),58,7,5)
			for x in [-56,50]: banner(c,Vector2(x,-65),31)
		"shadow_colonnade":
			# Width stays inside the west wall; no tall additions reach the patrol lane.
			masonry(c,Rect2(-14,-91,28,167),true)
			for y in range(-64,73,36):
				block(c,Vector2(0,y+10),13,5,3)
				arch(c,Vector2(0,y+3),8,24)
				c.draw_rect(Rect2(-2,y-12,4,7),Color("826895"))
			c.draw_line(Vector2(-12,-91),Vector2(-12,72),Color("657188"),2)
		"beacon_vault_sanctum":
			masonry(c,Rect2(-84,-88,168,62),true)
			for x in [-74,-36,32,74]: pillar(c,Vector2(x,-22),75)
			arch(c,Vector2(0,-25),27,72,lit)
			for x in [-55,47]: banner(c,Vector2(x,-78),38)
			for x in [-74,-36,32,74]:
				c.draw_rect(Rect2(x-2,-62,4,11),Color("8cdde1") if lit else Color("7c6c9b"))
			block(c,Vector2(0,-100),95,7,6)
			for x in [-80,-42,0,42,80]:
				poly(c,[Vector2(x-6,-110),Vector2(x,-122),Vector2(x+6,-110)],"6c6e88")
static func archive(c: CanvasItem) -> void:
	# Sloped two-wall cutaway, kept on the existing separate interior layer.
	for side in [-1,1]:
		poly(c,[Vector2(0,-114),Vector2(side*64,-82),Vector2(side*64,12),Vector2(0,-20)],"30394c" if side < 0 else "242e40")
		for y in range(-80,-22,8):
			c.draw_line(Vector2(0,y-27),Vector2(side*63,y+4),Color("4c566b"),1)
			for x in range(8,62,14):
				c.draw_line(Vector2(side*x,y+x*0.5-27),Vector2(side*x,y+x*0.5-21),Color("1b2536"),1)
		c.draw_line(Vector2(0,-114),Vector2(side*65,-82),Color("9c9aa5"),4)
		c.draw_line(Vector2(0,-105),Vector2(side*63,-73),Color("3c3043"),3)
	for x in [-43,-17,17,43]:
		var y: float = -51+absf(x)*0.36
		arch(c,Vector2(x,y-3),8,31,true)
		masonry(c,Rect2(x-12,y+4,24,29),true)
		c.draw_rect(Rect2(x-10,y+5,20,27),Color("493d35"))
		for row in range(3):
			c.draw_rect(Rect2(x-9,y+7+row*8,18,6),Color("202837"))
			for j in range(5):
				var palette := ["6c7b8b","986e62","a59a73","5e7b78","766083"]
				c.draw_rect(Rect2(x-8+j*3,y+8+row*8,2,4+posmod(j+row,2)),Color(palette[posmod(j+row,5)]))
				c.draw_rect(Rect2(x-8+j*3,y+10+row*8,2,1),Color("b4a887"))
			c.draw_line(Vector2(x-10,y+14+row*8),Vector2(x+10,y+14+row*8),Color("9b8464"),1)
	for x in [-65,0,65]: pillar(c,Vector2(x,10 if x else -20),91)
	# Bronze chandelier and tiny crisp flames, without a diffuse screen overlay.
	c.draw_line(Vector2(0,-108),Vector2(0,-70),Color("a19678"),1)
	c.draw_polyline(PackedVector2Array([Vector2(-18,-73),Vector2(-12,-65),Vector2(12,-65),Vector2(18,-73)]),Color("a8905c"),2)
	for x in [-16,-6,6,16]:
		c.draw_rect(Rect2(x,-75,2,7),Color("c5b58f"))
		c.draw_rect(Rect2(x,-78,2,3),Color("ffdaa1"))
static func beacon(c: CanvasItem, active: bool) -> void:
	block(c,Vector2(0,2),26,13,5)
	block(c,Vector2(0,-4),21,10,6)
	block(c,Vector2(0,-10),12,6,28)
	block(c,Vector2(0,-37),17,8,5)
	for x in [-8,6]:
		c.draw_line(Vector2(x,-13),Vector2(x,-35),Color("b3a993"),1)
	c.draw_rect(Rect2(-2,-29,3,9),Color("93e5e6") if active else Color("907baa"))
	for x in [-18,18]:
		c.draw_line(Vector2(x,-34),Vector2(x,-57),Color("b0a47c"),2)
		c.draw_line(Vector2(x,-57),Vector2(x*0.45,-66),Color("dac894"),2)
	poly(c,[Vector2(0,-77),Vector2(11,-53),Vector2(0,-40),Vector2(-11,-53)],"81dbe2" if active else "745e9e")
	poly(c,[Vector2(0,-77),Vector2(0,-40),Vector2(-11,-53)],"e1fae0" if active else "b3a3d1")
	c.draw_rect(Rect2(-2,-59,3,8),Color("fff1b2") if active else Color("d0bcdb"))
