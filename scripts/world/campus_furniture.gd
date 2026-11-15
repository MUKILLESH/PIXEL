extends StaticBody2D
## Decorative campus furnishings; their exact forms and positions are not surveyed.
@export_enum("Bench", "Streetlight", "Planter", "Bin") var kind: int = 0

func _ready() -> void:
	var collider := CollisionPolygon2D.new()
	var width: float = 21 if kind == 0 else (16 if kind == 2 else 5)
	collider.polygon = PackedVector2Array([Vector2(-width,-4),Vector2(-width+8,-8),Vector2(width,-1),Vector2(width-8,3)]) if kind in [0,2] else PackedVector2Array([Vector2(-4,-3),Vector2(4,-3),Vector2(4,2),Vector2(-4,2)])
	add_child(collider)

func _draw() -> void:
	match kind:
		0:
			for x in [-14,12]:
				draw_rect(Rect2(x,-10,3,12),Color("283e48"))
			for i in range(3):
				draw_line(Vector2(-21,-9+i*2),Vector2(16,9+i*2-9),Color("b5986c"),2)
			for i in range(3):
				draw_line(Vector2(-19,-22+i*3),Vector2(18,-4+i*3),Color("9c805c"),2)
			for x in [-19,17]:
				draw_line(Vector2(x,-20+(x+19)*0.5),Vector2(x,-3+(x+19)*0.2),Color("3b5158"),2)
		1:
			draw_rect(Rect2(-4,-3,8,4),Color("6b7e7e"))
			draw_rect(Rect2(-2,-62,3,60),Color("344e5a"))
			draw_line(Vector2(0,-62),Vector2(12,-68),Color("75908e"),2)
			draw_colored_polygon(PackedVector2Array([Vector2(7,-67),Vector2(17,-72),Vector2(23,-69),Vector2(13,-64)]),Color("d5cba3"))
			draw_line(Vector2(12,-64),Vector2(22,-69),Color("ffe4a2"),2)
		2:
			draw_colored_polygon(PackedVector2Array([Vector2(-19,-6),Vector2(-9,-11),Vector2(19,3),Vector2(9,8)]),Color("7d8271"))
			for i in range(5):
				var p := Vector2(-14+i*6,-8+i*3)
				draw_rect(Rect2(p-Vector2(0,5),Vector2(9,7)),Color("49684e"))
				draw_rect(Rect2(p-Vector2(-2,7),Vector2(5,4)),Color("739067"))
				draw_rect(Rect2(p-Vector2(-3,6),Vector2(2,2)),Color("d6c19b"))
		3:
			draw_rect(Rect2(-5,-15,10,15),Color("41665d"))
			draw_rect(Rect2(-6,-17,12,4),Color("789082"))
			draw_rect(Rect2(-3,-14,6,3),Color("253e46"))

func ground_shadow() -> PackedVector2Array:
	var width: int = 20 if kind in [0,2] else 5
	var length: int = 35 if kind == 1 else 14
	return PackedVector2Array([Vector2(-width,-3),Vector2(width,-3),Vector2(width+length,length/2),Vector2(-width+length,length/2)])
