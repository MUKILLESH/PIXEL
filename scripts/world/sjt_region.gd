extends Node2D
const Prop = preload("res://scripts/world/prop.gd")
const Landmark = preload("res://scripts/world/sjt_landmark.gd")
const Furniture = preload("res://scripts/world/campus_furniture.gd")

func _ready() -> void:
	var ground: TileMapLayer = $Ground
	for x in range(-28,29):
		for y in range(-28,29):
			ground.set_cell(Vector2i(x,y),0,Vector2i(posmod(x*17+y*31,3),0))
	for point: Vector2 in [Vector2(-240,-30),Vector2(-230,100),Vector2(-140,125),Vector2(220,-50),Vector2(245,80),Vector2(175,215),Vector2(-170,235),Vector2(-310,35),Vector2(280,5),Vector2(-160,-170),Vector2(85,-190),Vector2(300,170)]:
		var tree := StaticBody2D.new()
		tree.set_script(Prop)
		tree.position = point
		$Actors.add_child(tree)
	var furnishings: Array = [
		[0,Vector2(-80,155)],[0,Vector2(205,180)],[0,Vector2(-235,55)],
		[1,Vector2(-190,100)],[1,Vector2(105,110)],[1,Vector2(230,100)],[1,Vector2(-260,10)],
		[2,Vector2(85,125)],[2,Vector2(-90,90)],[2,Vector2(195,160)],
		[3,Vector2(230,190)],[3,Vector2(-105,155)]
	]
	for entry: Array in furnishings:
		var furnishing := StaticBody2D.new()
		furnishing.set_script(Furniture)
		furnishing.set("kind",entry[0])
		furnishing.position = entry[1]
		furnishing.name = "Furniture%d" % $Actors.get_child_count()
		$Actors.add_child(furnishing)
	for index in range(2):
		var landmark := StaticBody2D.new()
		landmark.set_script(Landmark)
		landmark.set("kind",index)
		landmark.position = Vector2(30,150) if index == 0 else Vector2(30,103)
		landmark.name = "Basin" if index == 0 else "Monument"
		$Actors.add_child(landmark)
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
	$HUD/Subtitle.text = "SJT / COMPRESSED EXTERIOR STUDY"
	$HUD/Objective.text = "EXPLORE SJT / INVESTIGATE THE TERMINAL"
	$Actors/Player/Camera2D.framing = Vector2(0,-96)
	$Actors/Player/Camera2D.snap_to_target()
	$Landscape.queue_redraw()

