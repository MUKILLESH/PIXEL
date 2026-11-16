extends Node2D
## Lightweight 10 Hz effects; all ground and vegetation stay cached separately.
const Art = preload("res://scripts/world/briarwood_art.gd")
var bridge_repaired: bool = false
var mirror_solved: bool = false
var beacon_activated: bool = false
var _anim_time: float = 0.0
var _redraw_accum: float = 0.0
func _ready() -> void:
	var ground: Node2D
	if "--bake-art" in OS.get_cmdline_user_args():
		ground = Node2D.new()
		ground.set_script(preload("res://scripts/world/briarwood_ground.gd"))
	else:
		var sprite := Sprite2D.new()
		sprite.texture = load("res://assets/forest/ground.png")
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		ground = sprite
	ground.show_behind_parent = true
	add_child(ground)
	var air := Node2D.new()
	air.set_script(preload("res://scripts/world/briarwood_air.gd"))
	air.z_index = 2
	add_child(air)
func _process(delta: float) -> void:
	_anim_time += delta
	_redraw_accum += delta
	if _redraw_accum >= 0.1:
		_redraw_accum = 0
		queue_redraw()

func _draw() -> void:
	for x in range(-650,650,31):
		var flow: int = int(_anim_time*8)%28
		draw_rect(Rect2(x+flow,-25+posmod(x,11),9,1),Color("568e8e"))
		draw_rect(Rect2(x+flow+4,-23+posmod(x,11),4,1),Color("79b8a6"))
	# Timber abutments and span, with an unmistakable missing center until repaired.
	for y in [-43,-1]:
		Art.block(self,Vector2(-90,y),31,4,4)
	for x in [-113,-69]:
		draw_rect(Rect2(x,-41,4,39),Color("3f382a"))
	for y in range(-39,0,6):
		if not bridge_repaired and y > -33 and y < -9: continue
		draw_rect(Rect2(-111,y,42,5),Color("9c8050"))
		draw_line(Vector2(-109,y+1),Vector2(-73,y+1),Color("cab37a"),1)
		draw_line(Vector2(-103,y+3),Vector2(-82,y+3),Color("6d5a3c"),1)
		for x in [-108,-73]: draw_rect(Rect2(x,y+2,1,1),Color("3b3b2e"))
	for x in [-116,-65]:
		for y in [-39,0]:
			draw_rect(Rect2(x,y-9,3,12),Color("6f6040"))
			draw_rect(Rect2(x-1,y-7,5,3),Color("bdac79"))
		if bridge_repaired:
			draw_line(Vector2(x+1,-46),Vector2(x+1,-7),Color("b6a677"),1)
		else:
			draw_line(Vector2(x+1,-46),Vector2(x+5,-31),Color("b6a677"),1)
	if mirror_solved:
		for p: Vector2 in [Vector2(-168,-158),Vector2(-132,-172),Vector2(-96,-158)]:
			draw_line(p,Vector2(-32,-216),Color(0.3,0.8,0.8,0.18),6)
			draw_line(p,Vector2(-32,-216),Color("8cdad2"),1)
	else:
		draw_polyline(PackedVector2Array([Vector2(-69,-214),Vector2(-32,-233),Vector2(5,-214),Vector2(-32,-195),Vector2(-69,-214)]),Color("5c9b98"),1)
	if beacon_activated:
		for size in [52,39,25]:
			draw_colored_polygon(PackedVector2Array([Vector2(-32-size,-214),Vector2(-32,-214-size/2.0),Vector2(-32+size,-214),Vector2(-32,-214+size/2.0)]),Color(0.4,0.9,0.8,0.08))
	var flicker: int = int(_anim_time*5)%3
	for p: Vector2 in [Vector2(54,180)]:
		draw_colored_polygon(PackedVector2Array([p+Vector2(-23,0),p+Vector2(0,-12),p+Vector2(23,0),p+Vector2(0,12)]),Color(1,0.65,0.2,0.12))
		Art.block(self,p+Vector2(0,2),7,3,2)
		Art.poly(self,[p+Vector2(-4,0),p+Vector2(-3,-7),p+Vector2(0,-12-flicker),p+Vector2(2,-5),p+Vector2(5,-1)],"d88d3f")
		draw_rect(Rect2(p+Vector2(-1,-6),Vector2(2,5)),Color("f9d889"))
	for i in range(16):
		var p := Vector2(-240+posmod(i*83,480),-220+posmod(i*67,420))
		p += Vector2(sin(_anim_time+i)*5,cos(_anim_time*0.8+i)*4)
		draw_rect(Rect2(p.round(),Vector2(1,2)),Color(0.7,0.9,0.6,0.35+0.2*sin(_anim_time+i)))
