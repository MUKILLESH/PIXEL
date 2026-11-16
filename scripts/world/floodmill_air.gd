extends Node2D
## Bounded moisture, dust, candle shimmer and beacon energy. No static geometry rebuild.
var phase: float = 0
var tick: float = 0
func _process(delta: float) -> void:
	phase += delta
	tick += delta
	if tick >= 0.12:
		tick = 0
		queue_redraw()
func _draw() -> void:
	for p: Vector2 in [Vector2(-180,-48),Vector2(108,-14),Vector2(198,-14),Vector2(260,108)]:
		var sway: int = int(round(sin(phase*1.3+p.x)))
		draw_line(p,p+Vector2(-2+sway,-9),Color("607a56"),1)
		draw_line(p+Vector2(3,0),p+Vector2(4+sway,-7),Color("829269"),1)
	for i in range(5):
		var p := Vector2(-230+i*111+sin(phase*0.25+i)*9,150-(i%3)*96).round()
		draw_rect(Rect2(p,Vector2(29,2)),Color(0.65,0.8,0.77,0.045))
		draw_rect(Rect2(p+Vector2(8,-2),Vector2(16,2)),Color(0.65,0.8,0.77,0.035))
	for i in range(7):
		var p := Vector2(-184+i*15,-155+sin(phase*0.4+i)*12).round()
		draw_rect(Rect2(p,Vector2(1,1)),Color(0.9,0.8,0.55,0.3))
	if get_parent().second_beacon_activated:
		for width in [13,6,2]:
			draw_rect(Rect2(64-width,-325,width*2,80),Color(0.4,0.85,0.87,0.07))
		for i in range(10):
			var p := Vector2(64+sin(phase*0.6+i*2)*23,-220-fmod(phase*8+i*11,96)).round()
			draw_rect(Rect2(p,Vector2(1,2)),Color("a9e4d4") if i%3 else Color("e7cf8a"))
		var p := Vector2(64,-257)
		draw_polyline(PackedVector2Array([p+Vector2(-13,0),p+Vector2(0,-7),p+Vector2(13,0),p+Vector2(0,7),p+Vector2(-13,0)]),Color("cbbd82"),1)
