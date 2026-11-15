extends StaticBody2D
const Art = preload("res://scripts/world/sjt_art.gd")
const FOOTPRINT := [Vector2(-112,0),Vector2(112,-112),Vector2(48,-144),Vector2(-176,-32)]

func _ready() -> void:
	collision_layer = 1
	collision_mask = 2
	y_sort_enabled = true
	var collision := CollisionPolygon2D.new()
	collision.name = "Footprint"
	collision.polygon = PackedVector2Array(FOOTPRINT)
	add_child(collision)
	add_art(0,Vector2(-100,-32))
	var sign_piece := add_art(4,Vector2.ZERO)
	sign_piece.z_index = 1
	# Each bay sorts at its own ground line, rather than hiding a player in front
	# of the far end of this long diagonal facade behind the entire building.
	for i in range(14):
		var piece := add_art(1,Art.project(i*16,0))
		piece.bay = i
	var canopy := add_art(2,Art.project(72,-48))
	canopy.name = "CanopyRoof"
	for u in [76,148]:
		var point: Vector2 = Art.project(u,-44)
		var column := StaticBody2D.new()
		column.name = "CanopyColumn%d" % u
		column.position = point
		column.y_sort_enabled = true
		var shape := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 3
		shape.shape = circle
		column.add_child(shape)
		var visual := Node2D.new()
		visual.set_script(Art)
		visual.set("part",3)
		column.add_child(visual)
		add_child(column)

func add_art(part: int, anchor: Vector2) -> Node2D:
	var visual := Node2D.new()
	visual.set_script(Art)
	visual.set("part",part)
	visual.set("anchor",anchor)
	visual.position = anchor
	add_child(visual)
	return visual
