extends StaticBody2D
## Environmental props for Chapter 5 (The Great Bell Sanctum).

const Art = preload("res://scripts/world/great_bell_art.gd")

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
	Art.ellipse(self, Vector2(0, 1), 10.0, 4.5, Color(0, 0, 0, 0.35))
	match kind:
		"sanctum_brazier":
			# Obsidian tripod pedestal + bronze fire basin + crisp layered ember flame
			Art.px(self, -7, -5, 14, 6, Color(Art.STONE[2]))
			Art.px(self, -5, -16, 10, 12, Color(Art.STONE[4]))
			Art.px(self, -5, -16, 3, 12, Color(Art.STONE[6]))
			Art.px(self, -8, -19, 16, 4, Color(Art.BRONZE[4]))
			Art.px(self, -8, -19, 16, 1, Color(Art.BRONZE[7]))
			Art.px(self, -5, -21, 10, 2, Color("b84418"))
			draw_colored_polygon(PackedVector2Array([
				Vector2(-4, -20), Vector2(-2, -28), Vector2(0, -25), Vector2(2, -29), Vector2(4, -20)
			]), Color("ff9e36"))
			Art.px(self, -2, -25, 4, 5, Color("ffe278"))
			Art.px(self, -1, -23, 2, 3, Color("ffffff"))
		"chain_pylon":
			# Carved basalt mooring obelisk with bronze collar, top shackle & binding runes
			Art.px(self, -8, -6, 16, 7, Color(Art.STONE[2]))
			Art.px(self, -6, -30, 12, 24, Color(Art.STONE[4]))
			Art.px(self, -6, -30, 4, 24, Color(Art.STONE[6]))
			Art.px(self, 3, -30, 3, 24, Color(Art.STONE[2]))
			draw_colored_polygon(PackedVector2Array([
				Vector2(-7, -30), Vector2(0, -35), Vector2(7, -30)
			]), Color(Art.STONE[5]))
			Art.px(self, -7, -14, 14, 3, Color(Art.BRONZE[4]))
			Art.px(self, -7, -14, 14, 1, Color(Art.BRONZE[7]))
			Art.px(self, -3, -24, 6, 4, Color(Art.AMETHYST[2]))
			Art.px(self, -2, -23, 4, 2, Color(Art.AMETHYST[4]))
			Art.glyph(self, -1.0, -20.0, 4, Color(Art.CYAN[2]))
		"crystal_column":
			# Fluted memory-reliquary pillar cradling a multi-faceted sapphire spire
			Art.px(self, -8, -6, 16, 7, Color(Art.STONE[2]))
			Art.px(self, -6, -24, 12, 18, Color(Art.STONE[4]))
			Art.px(self, -6, -24, 3, 18, Color(Art.STONE[6]))
			Art.px(self, -7, -25, 14, 3, Color(Art.BRONZE[3]))
			Art.px(self, -7, -25, 14, 1, Color(Art.GOLD[2]))
			draw_colored_polygon(PackedVector2Array([
				Vector2(-5, -25), Vector2(0, -40), Vector2(5, -25)
			]), Color(Art.CYAN[2]))
			draw_colored_polygon(PackedVector2Array([
				Vector2(-4, -25), Vector2(-1, -38), Vector2(1, -25)
			]), Color(Art.CYAN[3]))
			Art.px(self, -1, -35, 2, 7, Color(Art.CYAN[4]))
			Art.px(self, -2, -19, 4, 7, Color(Art.CYAN[3]))
