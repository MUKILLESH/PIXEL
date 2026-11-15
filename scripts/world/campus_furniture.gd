extends StaticBody2D
## Medieval village furnishings: oak bench, wrought-iron lantern, stone herb trough, iron-bound barrel.
@export_enum("Bench", "Lantern", "Planter", "Barrel") var kind: int = 0

func _ready() -> void:
	var collider := CollisionPolygon2D.new()
	var width: float = 21 if kind == 0 else (16 if kind == 2 else 5)
	collider.polygon = PackedVector2Array([Vector2(-width,-4),Vector2(-width+8,-8),Vector2(width,-1),Vector2(width-8,3)]) if kind in [0,2] else PackedVector2Array([Vector2(-4,-3),Vector2(4,-3),Vector2(4,2),Vector2(-4,2)])
	add_child(collider)

func _draw() -> void:
	match kind:
		0:
			# Rustic oak village bench with dark iron straps
			for x in [-14,12]:
				draw_rect(Rect2(x,-10,3,12),Color("282b30"))
			for i in range(3):
				draw_line(Vector2(-21,-9+i*2),Vector2(16,9+i*2-9),Color("6e492d"),2)
			for i in range(3):
				draw_line(Vector2(-19,-22+i*3),Vector2(18,-4+i*3),Color("593a23"),2)
			for x in [-19,17]:
				draw_line(Vector2(x,-20+(x+19)*0.5),Vector2(x,-3+(x+19)*0.2),Color("3d291a"),2)
		1:
			# Wrought-iron medieval hanging lantern post with warm golden flame
			draw_rect(Rect2(-4,-3,8,4),Color("59534c"))
			draw_rect(Rect2(-2,-64,3,62),Color("24272e"))
			draw_line(Vector2(0,-63),Vector2(13,-63),Color("3b404a"),2)
			draw_line(Vector2(1,-56),Vector2(8,-63),Color("2d3138"),1)
			draw_rect(Rect2(12,-63,1,3),Color("4c525e"))
			draw_colored_polygon(PackedVector2Array([Vector2(8,-57),Vector2(12,-61),Vector2(17,-57)]),Color("1f2229"))
			draw_rect(Rect2(10,-57,5,6),Color("ffbe4f"))
			draw_rect(Rect2(11,-56,3,4),Color("fff0b8"))
			draw_rect(Rect2(10,-51,5,1),Color("1f2229"))
			draw_rect(Rect2(12,-50,1,2),Color("2d3138"))
		2:
			# Stone herb trough with night-green herbs and marigold blooms
			draw_colored_polygon(PackedVector2Array([Vector2(-19,-6),Vector2(-9,-11),Vector2(19,3),Vector2(9,8)]),Color("666057"))
			for i in range(5):
				var p := Vector2(-14+i*6,-8+i*3)
				draw_rect(Rect2(p-Vector2(0,5),Vector2(9,7)),Color("2d4a36"))
				draw_rect(Rect2(p-Vector2(-2,7),Vector2(5,4)),Color("466b4c"))
				draw_rect(Rect2(p-Vector2(-3,6),Vector2(2,2)),Color("e6a94e"))
		3:
			# Iron-bound oak barrel
			draw_rect(Rect2(-5,-15,10,15),Color("6b4429"))
			draw_rect(Rect2(-6,-13,12,2),Color("2d3138"))
			draw_rect(Rect2(-6,-6,12,2),Color("2d3138"))
			draw_rect(Rect2(-4,-16,8,2),Color("4f311c"))

func ground_shadow() -> PackedVector2Array:
	var width: int = 20 if kind in [0,2] else 5
	var length: int = 35 if kind == 1 else 14
	return PackedVector2Array([Vector2(-width,-3),Vector2(width,-3),Vector2(width+length,length/2),Vector2(-width+length,length/2)])
