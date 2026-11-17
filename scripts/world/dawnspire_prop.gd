extends StaticBody2D
## Alpine environmental props for Dawnspire Mountain (Chapter 4).

@export var kind: String = "mountain_pine"

func _ready() -> void:
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	match kind:
		"mountain_pine":
			rect.size = Vector2(18, 12)
			col.position = Vector2(0, -4)
		"crimson_frost_tree":
			rect.size = Vector2(20, 12)
			col.position = Vector2(0, -4)
		"stone_lantern":
			rect.size = Vector2(14, 10)
			col.position = Vector2(0, -4)
		"pilgrim_pack":
			rect.size = Vector2(14, 10)
			col.position = Vector2(0, -3)
		"star_obelisk":
			rect.size = Vector2(16, 12)
			col.position = Vector2(0, -4)
		"wind_brazier":
			rect.size = Vector2(14, 10)
			col.position = Vector2(0, -4)
	col.shape = rect
	add_child(col)

func _draw() -> void:
	match kind:
		"mountain_pine":
			preload("res://scripts/world/dawnspire_art.gd").pine(self,Vector2.ZERO)
		"crimson_frost_tree":
			draw_rect(Rect2(-3, -12, 6, 12), Color("473126"))
			draw_circle(Vector2(-7, -24), 10.0, Color("992f3e"))
			draw_circle(Vector2(7, -24), 10.0, Color("b03b49"))
			draw_circle(Vector2(0, -32), 11.0, Color("c44b55"))
			draw_rect(Rect2(-9, -40, 18, 4), Color("e6eff7"))
		"stone_lantern":
			draw_rect(Rect2(-6, -16, 12, 16), Color("3c4557"))
			draw_rect(Rect2(-8, -22, 16, 6), Color("5b6780"))
			draw_rect(Rect2(-3, -19, 6, 5), Color("ffcf70"))
			draw_rect(Rect2(-8, -24, 16, 3), Color("dce8f5"))
		"pilgrim_pack":
			draw_rect(Rect2(-7, -10, 14, 10), Color("59412d"))
			draw_rect(Rect2(-5, -13, 10, 4), Color("7a5b40"))
			draw_rect(Rect2(4, -14, 4, 8), Color("9eb0c9"))
		"star_obelisk":
			draw_rect(Rect2(-7, -28, 14, 28), Color("333d52"))
			draw_colored_polygon(PackedVector2Array([Vector2(-7, -28), Vector2(0, -38), Vector2(7, -28)]), Color("526180"))
			draw_rect(Rect2(-2, -22, 4, 10), Color("8be6f0"))
		"wind_brazier":
			draw_rect(Rect2(-6, -15, 12, 15), Color("363e4f"))
			draw_circle(Vector2(0, -19), 5.0, Color("ff9e42"))
			draw_circle(Vector2(0, -19), 2.5, Color("fff1b8"))
