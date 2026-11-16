extends RefCounted
## Floodmill's original pixel-art helpers. No gameplay state or physical geometry.
static func poly(c: CanvasItem, points: Array, color: String) -> void:
	c.draw_colored_polygon(PackedVector2Array(points),Color(color))
static func block(c: CanvasItem, p: Vector2, w: float, d: float, h: float) -> void:
	poly(c,[p+Vector2(-w,0),p+Vector2(0,d),p+Vector2(0,d-h),p+Vector2(-w,-h)],"667875")
	poly(c,[p+Vector2(0,d),p+Vector2(w,0),p+Vector2(w,-h),p+Vector2(0,d-h)],"394a4c")
	poly(c,[p+Vector2(-w,-h),p+Vector2(0,-d-h),p+Vector2(w,-h),p+Vector2(0,d-h)],"8e9a89")
	c.draw_line(p+Vector2(-w,-h),p+Vector2(0,d-h),Color("b0b49b"),1)
static func reeds(c: CanvasItem, p: Vector2, seed_value: int = 0) -> void:
	for i in range(5):
		var q := p+Vector2(i*3-6,absi(i-2))
		var h: int = 5+posmod(i*7+seed_value,8)
		c.draw_line(q,q+Vector2(i-2,-h),Color("637454"),1)
		if i%2 == 0: c.draw_rect(Rect2(q+Vector2(i-3,-h),Vector2(2,3)),Color("9b8155"))
static func willow(c: CanvasItem, variant: int = 0) -> void:
	poly(c,[Vector2(-16,2),Vector2(-5,-9),Vector2(-8,-36),Vector2(1,-57),Vector2(5,-34),Vector2(2,-9),Vector2(13,2)],"303c36")
	c.draw_line(Vector2(-9,0),Vector2(-2,-29),Color("8f8260"),2)
	c.draw_line(Vector2(-2,-28),Vector2(-23,-45),Color("6d6247"),3)
	c.draw_line(Vector2(-1,-36),Vector2(22,-53),Color("6d6247"),3)
	var centers := [Vector2(-22,-43),Vector2(22,-47),Vector2(-12,-59),Vector2(8,-64),Vector2(1,-43)]
	for i in range(centers.size()):
		var p: Vector2 = centers[i]-Vector2(0,variant*3)
		var outline := [p+Vector2(-17,-2),p+Vector2(-17,-10),p+Vector2(-12,-10),p+Vector2(-12,-16),p+Vector2(-3,-16),p+Vector2(-3,-19),p+Vector2(7,-19),p+Vector2(7,-14),p+Vector2(14,-14),p+Vector2(14,-5),p+Vector2(18,-5),p+Vector2(18,2),p+Vector2(9,2),p+Vector2(9,9),p+Vector2(-4,9),p+Vector2(-4,5),p+Vector2(-13,5),p+Vector2(-13,-2)]
		poly(c,outline,"2c4a40")
		for j in range(12):
			var q := p+Vector2(-12+posmod(j*11+i*7,25),-15+posmod(j*7+i*3,20))
			var color := Color("667f5c") if j%4 == 0 else Color("4e6b51")
			c.draw_rect(Rect2(q,Vector2(5,3)),color)
			c.draw_rect(Rect2(q+Vector2(2,-2),Vector2(3,5)),color)
		for j in range(4):
			var q := p+Vector2(-12+j*7,0)
			var length: int = 13+posmod(i*11+j*13,23)
			c.draw_line(q,q+Vector2(-2,length),Color("385c48"),1)
			for k in range(2,length,4):
				var leaf := q+Vector2(-k/12,k)
				c.draw_rect(Rect2(leaf,Vector2(2,3)),Color("6e8759") if k < 12 else Color("51744f"))
	reeds(c,Vector2(-8,1),3)
static func beacon(c: CanvasItem, active: bool) -> void:
	block(c,Vector2(0,2),24,12,5)
	block(c,Vector2(0,-4),19,9,5)
	block(c,Vector2(0,-9),11,5,26)
	block(c,Vector2(0,-34),15,7,4)
	for x in [-7,5]:
		c.draw_line(Vector2(x,-14),Vector2(x,-31),Color("bac0a4"),1)
	var glow := Color("87e8e4") if active else Color("5b8288")
	c.draw_rect(Rect2(-2,-28,3,10),glow)
	for x in [-16,16]:
		c.draw_line(Vector2(x,-28),Vector2(x,-52),Color("a6a279"),3)
		c.draw_line(Vector2(x,-52),Vector2(x*0.5,-60),Color("d0bd7e"),2)
	poly(c,[Vector2(0,-65),Vector2(9,-48),Vector2(0,-36),Vector2(-9,-48)],"6ac4cc" if active else "486676")
	poly(c,[Vector2(0,-65),Vector2(0,-36),Vector2(-9,-48)],"d0f7dc" if active else "849e9e")
	c.draw_rect(Rect2(-2,-51,3,7),Color("fff2b7") if active else Color("adc6b4"))
	reeds(c,Vector2(-18,2))

static var texture_cache: Dictionary = {}
static func texture(path: String) -> Texture2D:
	# Keep the Resource alive for cached CanvasItem draw commands.
	if not texture_cache.has(path): texture_cache[path] = load(path)
	return texture_cache[path]
