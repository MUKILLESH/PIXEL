extends StaticBody2D
## Procedural pixel-art medieval & arcane fortress props for Ironwatch Keep.

@export var kind: String = "supply_wagon"

func _ready() -> void:
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	match kind:
		"supply_wagon":
			shape.radius = 13.0
		"weapon_rack", "barracks_bunk", "archive_desk":
			shape.radius = 10.0
		"arcane_obelisk", "ward_brazier":
			shape.radius = 8.0
		_:
			shape.radius = 8.0
	col.shape = shape
	col.position = Vector2(0, -3)
	add_child(col)

func _draw() -> void:
	match kind:
		"supply_wagon":
			draw_colored_polygon(PackedVector2Array([Vector2(-20, 4), Vector2(0, -4), Vector2(20, 4), Vector2(0, 12)]), Color(0.05, 0.05, 0.08, 0.45))
			# Weathered covered fortress supply cart (inspired by Courtyard reference)
			draw_rect(Rect2(-14, -14, 28, 12), Color("543825"))
			draw_rect(Rect2(-13, -24, 26, 11), Color("968e80"))
			draw_rect(Rect2(-11, -26, 22, 4), Color("b5ad9c"))
			# Spoked wooden wheels
			for wx in [-9, 9]:
				draw_circle(Vector2(wx, 1), 6.0, Color("6e472b"))
				draw_circle(Vector2(wx, 1), 3.0, Color("3b2718"))
				draw_rect(Rect2(wx - 1, 0, 2, 2), Color("b89658"))
		"weapon_rack":
			draw_rect(Rect2(-12, -22, 24, 3), Color("4f3624"))
			draw_rect(Rect2(-11, -22, 2, 22), Color("4f3624"))
			draw_rect(Rect2(9, -22, 2, 22), Color("4f3624"))
			for sx in [-6, 0, 6]:
				draw_line(Vector2(sx, -24), Vector2(sx, 0), Color("7a8599"), 2.0)
				draw_rect(Rect2(sx - 1, -26, 3, 3), Color("bac4d4"))
		"barracks_bunk":
			draw_rect(Rect2(-15, -10, 30, 14), Color("4f3726"))
			draw_rect(Rect2(-13, -12, 26, 9), Color("786f64"))
			draw_rect(Rect2(-13, -12, 8, 6), Color("b5ac9a"))
			draw_rect(Rect2(-3, -12, 15, 9), Color("453752"))
		"archive_desk":
			draw_rect(Rect2(-13, -14, 26, 16), Color("5c3f28"))
			draw_rect(Rect2(-11, -17, 22, 6), Color("755135"))
			draw_rect(Rect2(-6, -18, 6, 4), Color("e6d5ad"))
			draw_rect(Rect2(4, -22, 3, 5), Color("f5b64c"))
		"ward_brazier":
			draw_rect(Rect2(-6, -12, 12, 12), Color("363947"))
			draw_rect(Rect2(-8, -16, 16, 5), Color("4f5466"))
			draw_colored_polygon(PackedVector2Array([Vector2(-4, -16), Vector2(0, -25), Vector2(4, -16)]), Color("a26bfa"))
			draw_rect(Rect2(-1, -21, 2, 4), Color("f0deff"))
		"arcane_obelisk":
			draw_rect(Rect2(-8, -10, 16, 10), Color("2f2b45"))
			draw_colored_polygon(PackedVector2Array([Vector2(-6, -10), Vector2(0, -34), Vector2(6, -10)]), Color("4a6ab5"))
			draw_colored_polygon(PackedVector2Array([Vector2(-2, -14), Vector2(0, -30), Vector2(2, -14)]), Color("82e9ff"))
		_:
			draw_rect(Rect2(-10, -12, 20, 12), Color("3a3f4d"))
