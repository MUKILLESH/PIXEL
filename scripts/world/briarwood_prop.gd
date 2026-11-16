extends StaticBody2D
## Original medieval woodland pixel-art props and ruins for Briarwood Forest.

@export_enum("LargeOakTree", "PineSapling", "MossyBoulder", "FallenLog", "RuinedPillar", "CampfireTent", "MirrorStand", "MushroomCluster", "WildflowerPatch") var kind: int = 0

func _ready() -> void:
	collision_layer = 1
	collision_mask = 2
	if kind in [7, 8]:
		# Decorative mushrooms and wildflowers do not block movement
		z_index = -1
		return
	var shape_node := CollisionShape2D.new()
	match kind:
		0: # LargeOakTree
			var c := CircleShape2D.new()
			c.radius = 9.0
			shape_node.shape = c
			shape_node.position = Vector2(0, -4)
		1, 4, 6: # PineSapling, RuinedPillar, MirrorStand
			var c := CircleShape2D.new()
			c.radius = 6.0
			shape_node.shape = c
			shape_node.position = Vector2(0, -3)
		2: # MossyBoulder
			var r := RectangleShape2D.new()
			r.size = Vector2(20, 10)
			shape_node.shape = r
			shape_node.position = Vector2(0, -3)
		3: # FallenLog
			var r := RectangleShape2D.new()
			r.size = Vector2(28, 8)
			shape_node.shape = r
			shape_node.position = Vector2(0, -3)
		5: # CampfireTent
			var r := RectangleShape2D.new()
			r.size = Vector2(24, 14)
			shape_node.shape = r
			shape_node.position = Vector2(0, -5)
	add_child(shape_node)

const Art = preload("res://scripts/world/briarwood_art.gd")

func _draw() -> void:
	if not "--bake-art" in OS.get_cmdline_user_args():
		preload("res://scripts/world/briarwood_sprites.gd").paint(self,kind)
		return
	_draw_source()

func _draw_source() -> void:
	match kind:
		0, 1:
			Art.tree(self,kind == 1)
		2:
			Art.block(self,Vector2.ZERO,13,6,9)
			Art.fern(self,Vector2(-5,-8),"608353")
			draw_line(Vector2(4,-9),Vector2(2,-3),Color("273c36"),1)
		3:
			Art.poly(self,[Vector2(-19,-2),Vector2(-16,-10),Vector2(17,-7),Vector2(20,0),Vector2(15,4)],"3e3829")
			draw_rect(Rect2(-16,-8,31,6),Color("725739"))
			draw_line(Vector2(-13,-7),Vector2(12,-5),Color("a18755"),1)
			draw_rect(Rect2(14,-5,5,6),Color("bd9c62"))
			draw_rect(Rect2(16,-3,2,2),Color("59472d"))
			draw_rect(Rect2(-10,-10,12,3),Color("597d49"))
			Art.fern(self,Vector2(-15,0))
		4:
			Art.pillar(self)
		5:
			Art.poly(self,[Vector2(-23,3),Vector2(-7,-24),Vector2(12,-22),Vector2(26,1),Vector2(8,9)],"35382c")
			Art.poly(self,[Vector2(-23,1),Vector2(-7,-24),Vector2(7,2)],"8a7950")
			Art.poly(self,[Vector2(-7,-24),Vector2(12,-22),Vector2(26,1),Vector2(7,2)],"5b6044")
			Art.poly(self,[Vector2(-17,1),Vector2(-7,-17),Vector2(0,2)],"242e27")
			draw_line(Vector2(-7,-24),Vector2(7,2),Color("b5a778"),1)
			for i in range(4):
				draw_line(Vector2(6+i*3,-17+i*3),Vector2(9+i*3,-16+i*3),Color("aaa077"),1)
			draw_line(Vector2(-7,-24),Vector2(-30,7),Color("a99c71"),1)
			draw_rect(Rect2(12,-11,6,5),Color("7d7953"))
			draw_rect(Rect2(-31,4,2,6),Color("574a31"))
		6:
			Art.mirror(self)
		7:
			for p: Vector2 in [Vector2(-5,0),Vector2(4,3),Vector2(1,-4)]:
				draw_rect(Rect2(p+Vector2(-1,-5),Vector2(2,5)),Color("b4bea1"))
				draw_rect(Rect2(p+Vector2(-4,-7),Vector2(8,3)),Color("4eaaaf") if p.y < 0 else Color("b1784b"))
				draw_rect(Rect2(p+Vector2(-2,-8),Vector2(4,1)),Color("bdd7ae"))
		8:
			Art.fern(self,Vector2.ZERO)
			for p: Vector2 in [Vector2(-4,-5),Vector2(6,-3)]:
				draw_rect(Rect2(p,Vector2(3,2)),Color("cbb77a"))

func _process(_delta: float) -> void:
	if kind > 1: return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		var local: Vector2 = player.global_position-global_position
		modulate.a = 0.38 if Rect2(-44,-115,88,105).has_point(local) else 1.0
