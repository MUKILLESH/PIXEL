extends StaticBody2D
@export_enum("Village Well", "Anvil Plinth") var kind: int = 0

func _ready() -> void:
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(64,22) if kind == 0 else Vector2(16,10)
	collision.shape = shape
	collision.position.y = -5
	add_child(collision)

func _draw() -> void:
	if kind == 0:
		# Raised mossy cobblestone village well / cistern
		var outer := PackedVector2Array([Vector2(-32,-7),Vector2(-24,-15),Vector2(0,-19),Vector2(24,-15),Vector2(32,-7),Vector2(32,1),Vector2(22,5),Vector2(0,7),Vector2(-22,5),Vector2(-32,1)])
		draw_colored_polygon(outer,Color("4a453f"))
		var wall := PackedVector2Array([Vector2(-30,-4),Vector2(0,2),Vector2(30,-4),Vector2(30,1),Vector2(21,5),Vector2(0,6),Vector2(-21,5),Vector2(-30,1)])
		draw_colored_polygon(wall,Color("3c3834"))
		var coping := PackedVector2Array([Vector2(-31,-8),Vector2(-22,-15),Vector2(0,-18),Vector2(22,-15),Vector2(31,-8),Vector2(22,-2),Vector2(0,1),Vector2(-22,-2)])
		draw_colored_polygon(coping,Color("7a7268"))
		draw_polyline(coping,Color("948b80"),1)
		var water := PackedVector2Array([Vector2(-22,-8),Vector2(-15,-13),Vector2(0,-15),Vector2(15,-13),Vector2(22,-8),Vector2(15,-4),Vector2(0,-2),Vector2(-15,-4)])
		draw_colored_polygon(water,Color("264452"))
		draw_line(Vector2(-14,-9),Vector2(-4,-11),Color("638a94"),1)
		draw_line(Vector2(6,-6),Vector2(15,-7),Color("638a94"),1)
		draw_rect(Rect2(-24,-2,6,3),Color("375740"))
		draw_rect(Rect2(16,0,5,3),Color("375740"))
	else:
		# Stone pedestal & Blacksmith's iron anvil
		draw_colored_polygon(PackedVector2Array([Vector2(-11,-4),Vector2(0,-10),Vector2(12,-4),Vector2(0,2)]),Color("6e6862"))
		draw_rect(Rect2(-6,-15,12,11),Color("524c46"))
		draw_rect(Rect2(-5,-14,5,9),Color("6b655e"))
		# Forged iron anvil top & horn
		draw_colored_polygon(PackedVector2Array([Vector2(-10,-22),Vector2(6,-22),Vector2(9,-19),Vector2(4,-17),Vector2(4,-14),Vector2(-6,-14),Vector2(-6,-19)]),Color("2e323b"))
		draw_line(Vector2(-9,-22),Vector2(6,-22),Color("646b78"),2)
		draw_rect(Rect2(-2,-20,4,2),Color("e07a38"))
