extends Node2D
## Small non-blocking story vignettes; no prompts or quest hooks.
const Art = preload("res://scripts/world/floodmill_art.gd")
var kind: int = 0
func _draw() -> void:
	match kind:
		0: # Market stall whose cloth and contents were left in the rain.
			for x in [-16,16]:
				draw_rect(Rect2(x,-29,2,29),Color("4c4938"))
			Art.poly(self,[Vector2(-19,-28),Vector2(-3,-36),Vector2(23,-26),Vector2(8,-18)],"526c66")
			for i in range(4):
				draw_line(Vector2(-15+i*7,-28+i*2),Vector2(-2+i*6,-34+i*3),Color("8c9675"),2)
			Art.poly(self,[Vector2(-17,-13),Vector2(3,-23),Vector2(20,-14),Vector2(0,-4)],"74664b")
			draw_line(Vector2(-17,-12),Vector2(0,-3),Color("a29672"),1)
			draw_rect(Rect2(-9,-16,6,3),Color("b3ac85"))
			draw_rect(Rect2(4,-14,4,3),Color("8d7857"))
			Art.reeds(self,Vector2(-17,1))
		1: # Overturned cart, two readable octagonal wheels.
			Art.poly(self,[Vector2(-14,-4),Vector2(-9,-18),Vector2(15,-10),Vector2(10,5)],"514c3b")
			for i in range(5):
				draw_line(Vector2(-11+i*5,-3+i),Vector2(-7+i*5,-16+i*2),Color("978361"),2)
			for p: Vector2 in [Vector2(-13,-3),Vector2(12,4)]:
				var rim := PackedVector2Array()
				for i in range(9): rim.append(p+Vector2(cos(i*TAU/8)*6,sin(i*TAU/8)*6).round())
				draw_polyline(rim,Color("a68f65"),2)
				draw_line(p+Vector2(-5,0),p+Vector2(5,0),Color("8b7a58"),1)
				draw_line(p+Vector2(0,-5),p+Vector2(0,5),Color("8b7a58"),1)
			draw_line(Vector2(13,-10),Vector2(29,-1),Color("6d644a"),2)
		2: # Family memorial; no glow or item sparkle.
			Art.block(self,Vector2.ZERO,12,6,4)
			Art.block(self,Vector2(0,-4),7,3,22)
			for y in [-22,-18,-14]:
				draw_line(Vector2(-5,y),Vector2(-1,y+2),Color("afb4a0"),1)
			draw_rect(Rect2(-1,-25,2,2),Color("afb4a0"))
			Art.reeds(self,Vector2(-10,1))
		3: # Paired sanctuary pillar, shorter than the beacon.
			Art.block(self,Vector2.ZERO,9,4,4)
			Art.block(self,Vector2(0,-4),5,3,29)
			Art.block(self,Vector2(0,-33),8,4,4)
			for y in [-12,-20,-28]:
				draw_line(Vector2(-5,y),Vector2(0,y+3),Color("354a4b"),1)
			draw_line(Vector2(-3,-11),Vector2(-3,-26),Color("a6b59b"),1)
			Art.reeds(self,Vector2(6,2))
		4: # Archive side reading bench, rolled parchment and three candles.
			Art.block(self,Vector2.ZERO,12,6,8)
			Art.poly(self,[Vector2(-8,-8),Vector2(-2,-11),Vector2(5,-8),Vector2(-1,-5)],"d2c7a2")
			draw_line(Vector2(-5,-8),Vector2(0,-6),Color("82775a"),1)
			for x in [4,7,10]:
				draw_rect(Rect2(x,-17,1,7),Color("c4b887"))
				draw_rect(Rect2(x,-19,1,2),Color("ffe1a0"))
		5: # Half-submerged sign, lettering weathered away.
			draw_line(Vector2(0,0),Vector2(-4,-21),Color("6b6148"),3)
			Art.poly(self,[Vector2(-14,-23),Vector2(6,-21),Vector2(10,-16),Vector2(-13,-17)],"8d8565")
			draw_line(Vector2(-10,-20),Vector2(3,-19),Color("494f40"),1)
			draw_rect(Rect2(-8,0,18,1),Color("688b86"))
