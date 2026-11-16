extends StaticBody2D
## Original medieval wetland pixel-art props and ruins for Floodmill: The Drowned Village.

@export_enum("MarshWillow", "MossyRuin", "BrokenFence", "SunkenBarrels", "CanalLantern", "CattailReeds", "SubmergedDebris") var kind: int = 0

func _ready() -> void:
	collision_layer = 1
	collision_mask = 2
	if kind in [5, 6]:
		# Decorative cattails, lily pads, and puddle debris do not block movement
		z_index = -1
		return
	var shape_node := CollisionShape2D.new()
	match kind:
		0: # MarshWillow
			var c := CircleShape2D.new()
			c.radius = 9.0
			shape_node.shape = c
			shape_node.position = Vector2(0, -4)
		1: # MossyRuin
			var r := RectangleShape2D.new()
			r.size = Vector2(18, 10)
			shape_node.shape = r
			shape_node.position = Vector2(0, -4)
		2: # BrokenFence
			var r := RectangleShape2D.new()
			r.size = Vector2(22, 7)
			shape_node.shape = r
			shape_node.position = Vector2(0, -3)
		3: # SunkenBarrels
			var r := RectangleShape2D.new()
			r.size = Vector2(18, 10)
			shape_node.shape = r
			shape_node.position = Vector2(0, -3)
		4: # CanalLantern
			var c := CircleShape2D.new()
			c.radius = 5.0
			shape_node.shape = c
			shape_node.position = Vector2(0, -3)
	add_child(shape_node)

func _draw() -> void:
	if not "--bake-floodmill" in OS.get_cmdline_user_args():
		var texture: Texture2D = preload("res://scripts/world/floodmill_art.gd").texture("res://assets/floodmill/prop_%d.png" % kind)
		draw_texture(texture,Vector2(-64,-112))
		return
	_draw_source()

func _draw_source() -> void:
	match kind:
		0:
			preload("res://scripts/world/floodmill_art.gd").willow(self)
		1: # MossyRuin
			draw_colored_polygon(PackedVector2Array([Vector2(-12, -1), Vector2(0, -6), Vector2(12, -1), Vector2(0, 4)]), Color(0.02, 0.04, 0.04, 0.34))
			draw_rect(Rect2(-9, -20, 18, 20), Color("535c59"))
			draw_rect(Rect2(3, -20, 6, 20), Color("39403e"))
			draw_rect(Rect2(-10, -23, 12, 4), Color("6e7874"))
			draw_rect(Rect2(-8, -11, 7, 6), Color("3c6943"))
		2: # BrokenFence
			draw_rect(Rect2(-11, -13, 3, 13), Color("4f3622"))
			draw_rect(Rect2(8, -10, 3, 10), Color("422c1b"))
			draw_line(Vector2(-12, -9), Vector2(10, -6), Color("6e4a2d"), 2.5)
			draw_line(Vector2(-10, -5), Vector2(-1, -3), Color("5c3d24"), 2.0)
			draw_rect(Rect2(-4, -3, 6, 3), Color("396340"))
		3: # SunkenBarrels
			draw_colored_polygon(PackedVector2Array([Vector2(-12, 0), Vector2(0, -5), Vector2(12, 0), Vector2(0, 5)]), Color(0.14, 0.32, 0.38, 0.45))
			draw_rect(Rect2(-9, -12, 9, 11), Color("6b4728"))
			draw_rect(Rect2(-9, -9, 9, 2), Color("373d45"))
			draw_rect(Rect2(2, -10, 8, 9), Color("7a5330"))
			draw_rect(Rect2(2, -6, 8, 2), Color("4f3621"))
		4: # CanalLantern
			draw_circle(Vector2(0, -20), 14.0, Color(1.0, 0.72, 0.28, 0.14))
			draw_rect(Rect2(-3, -22, 6, 22), Color("4a5250"))
			draw_rect(Rect2(-4, -27, 8, 6), Color("282e36"))
			draw_rect(Rect2(-2, -26, 4, 4), Color("ffca57"))
		5: # CattailReeds
			for rx in [-5, -1, 4]:
				draw_line(Vector2(rx, 0), Vector2(rx + (rx / 3.0), -11), Color("2d5e37"), 1.5)
				draw_rect(Rect2(rx - 1, -11, 2, 4), Color("5e3a1f"))
			draw_circle(Vector2(5, 2), 3.0, Color("2e663b"))
		6: # SubmergedDebris
			draw_circle(Vector2(0, 0), 8.0, Color(0.15, 0.36, 0.42, 0.48))
			draw_circle(Vector2(-1, -1), 5.5, Color("593c23"), false, 2.0)
			draw_line(Vector2(-5, -1), Vector2(4, -1), Color("4a311c"), 1.0)
			draw_line(Vector2(-1, -5), Vector2(-1, 4), Color("4a311c"), 1.0)

func _process(_delta: float) -> void:
	if kind != 0: return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		var local := player.global_position-global_position
		var opacity: float = 0.4 if Rect2(-37,-83,74,78).has_point(local) else 1
		if modulate.a != opacity: modulate.a = opacity
