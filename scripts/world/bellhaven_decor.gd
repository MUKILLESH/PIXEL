extends Node2D
## Region-only visual dressing: no collision or interaction participation.
@export_enum("Market", "Smithy", "Woodpile", "Garden") var style: int = 0

func _draw() -> void:
	match style:
		0:
			for x in [-22,23]: draw_rect(Rect2(x,-38,3,38),Color("473824"))
			poly([Vector2(-27,-37),Vector2(-7,-47),Vector2(29,-29),Vector2(9,-19)],Color("78464c"))
			for i in range(5):
				var p := Vector2(-25+i*8,-36+i*4)
				poly([p,p+Vector2(19,-10),p+Vector2(24,-7),p+Vector2(5,3)],Color("c6af7e") if i%2 == 0 else Color("9c6560"))
			poly([Vector2(-23,-12),Vector2(-10,-19),Vector2(26,-1),Vector2(13,6)],Color("96754d"))
			for i in range(6): draw_rect(Rect2(-17+i*6,-13+i*3,4,3),Color("c59a4e") if i%2 else Color("72814d"))
			barrel(Vector2(-28,8))
			crate(Vector2(30,15))
		1:
			draw_rect(Rect2(-9,-8,18,10),Color("705334"))
			draw_line(Vector2(-8,-4),Vector2(8,-4),Color("302e2c"),2)
			poly([Vector2(-12,-17),Vector2(13,-17),Vector2(19,-14),Vector2(7,-11),Vector2(4,-5),Vector2(-5,-5),Vector2(-7,-12),Vector2(-16,-14)],Color("4f6371"))
			draw_line(Vector2(-11,-17),Vector2(12,-17),Color("98acaf"),2)
			barrel(Vector2(25,8))
			draw_rect(Rect2(20,-7,10,3),Color("588a92"))
			for i in range(3):
				var p := Vector2(-25+i*6,-9)
				draw_line(p,p+Vector2(2,-14),Color("886b45"),2)
				draw_rect(Rect2(p+Vector2(-1,-17),Vector2(7,4)),Color("7c8d91"))
		2:
			for row in range(3):
				for log_index in range(4-row):
					var p := Vector2(log_index*7+row*3,-row*5)
					draw_rect(Rect2(p+Vector2(0,-5),Vector2(9,5)),Color("4e3d2c"))
					draw_rect(Rect2(p+Vector2(0,-5),Vector2(5,5)),Color("aa8151"))
					draw_rect(Rect2(p+Vector2(1,-4),Vector2(2,2)),Color("5f492e"))
		3:
			poly([Vector2(-22,-4),Vector2(-7,-12),Vector2(26,4),Vector2(11,12)],Color("4b3e30"))
			for i in range(7):
				var p := Vector2(-17+i*5,-5+i*2)
				draw_line(p,p+Vector2(0,-7),Color("63814e"),2)
				draw_rect(Rect2(p+Vector2(-2,-10),Vector2(4,3)),Color("b9ad77") if i%2 else Color("8e6576"))
			for i in range(5): draw_rect(Rect2(-24+i*11,-1+i*5,2,8),Color("967a50"))

func barrel(p: Vector2) -> void:
	draw_rect(Rect2(p+Vector2(-7,-17),Vector2(14,17)),Color("92643d"))
	draw_rect(Rect2(p+Vector2(-5,-19),Vector2(10,3)),Color("b08a57"))
	for x in [-3,2]: draw_line(p+Vector2(x,-16),p+Vector2(x,-1),Color("674c33"),1)
	for y in [-14,-4]: draw_line(p+Vector2(-7,y),p+Vector2(7,y),Color("393e40"),2)

func crate(p: Vector2) -> void:
	draw_rect(Rect2(p+Vector2(-7,-13),Vector2(14,13)),Color("715032"))
	draw_rect(Rect2(p+Vector2(-7,-13),Vector2(14,13)),Color("ac8654"),false,2)
	draw_line(p+Vector2(-5,-11),p+Vector2(5,-2),Color("ac8654"),2)

func poly(points: Array, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points),color)
