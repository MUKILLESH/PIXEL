extends Node2D
const Prop = preload("res://scripts/world/prop.gd")
@onready var ground: TileMapLayer = $Ground

func _ready() -> void:
	# Scenery apron covers every camera corner even at the playable diamond tips.
	for x in range(-24,25):
		for y in range(-24,25):
			var path: bool = absi(x) <= 1 or absi(y) <= 1 or (absi(x) <= 3 and absi(y) <= 3)
			var variant: int = posmod(x * 17 + y * 31, 3)
			ground.set_cell(Vector2i(x,y),0,Vector2i(3 + variant if path else variant,0))
	add_prop(Vector2(-190,-30),1,"CARTOGRAPHER'S HALL")
	add_prop(Vector2(210,-30),1,"BLACKSMITH FORGE")
	for point: Vector2 in [Vector2(-300,35),Vector2(-195,100),Vector2(-100,-170),Vector2(100,-180),Vector2(295,40),Vector2(190,140),Vector2(-70,230),Vector2(90,245)]:
		add_prop(point,0,"")
	# A closed diamond boundary follows the outer tile edges.
	var corners := PackedVector2Array([Vector2(0,-320),Vector2(672,16),Vector2(0,352),Vector2(-672,16)])
	for i in range(4):
		var edge := StaticBody2D.new()
		var collision := CollisionShape2D.new()
		var segment := SegmentShape2D.new()
		segment.a = corners[i]
		segment.b = corners[(i+1)%4]
		collision.shape = segment
		edge.add_child(collision)
		$Boundary.add_child(edge)
	$HUD.player = $Actors/Player
	$HUD.terminal = $Actors/Terminal
	$Shadows.queue_redraw()

func add_prop(point: Vector2, kind: int, label_text: String) -> void:
	var prop := StaticBody2D.new()
	prop.set_script(Prop)
	prop.set("kind",kind)
	prop.set("building_label",label_text)
	prop.position = point
	prop.name = "Building" if kind == 1 else "Tree"
	$Actors.add_child(prop)
