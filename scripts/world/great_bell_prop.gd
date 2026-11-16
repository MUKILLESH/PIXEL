extends StaticBody2D
## Environmental props for Chapter 5 (The Great Bell Sanctum).

@export var kind: String = "sanctum_brazier"

func _ready() -> void:
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	match kind:
		"sanctum_brazier":
			rect.size = Vector2(14, 10)
			col.position = Vector2(0, -4)
		"chain_pylon":
			rect.size = Vector2(14, 10)
			col.position = Vector2(0, -4)
		"crystal_column":
			rect.size = Vector2(14, 12)
			col.position = Vector2(0, -5)
	col.shape = rect
	add_child(col)

func _draw() -> void:
	match kind:
		"sanctum_brazier":
			draw_rect(Rect2(-6, -15, 12, 15), Color("363e4f"))
			draw_circle(Vector2(0, -19), 5.0, Color("ffb554"))
			draw_circle(Vector2(0, -19), 2.5, Color("fff3c4"))
		"chain_pylon":
			draw_rect(Rect2(-6, -24, 12, 24), Color("2f3647"))
			draw_rect(Rect2(-7, -27, 14, 4), Color("4f5b75"))
			draw_rect(Rect2(-2, -18, 4, 8), Color("90a0bd"))
		"crystal_column":
			draw_rect(Rect2(-6, -26, 12, 26), Color("2a3347"))
			draw_colored_polygon(PackedVector2Array([
				Vector2(-4, -26), Vector2(0, -37), Vector2(4, -26)
			]), Color("75c8e8"))
			draw_rect(Rect2(-2, -21, 4, 8), Color("96ecff"))
