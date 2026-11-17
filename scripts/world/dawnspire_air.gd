extends Node2D
## Small region-local atmosphere, refreshed at 8Hz. Clouds stay outside playable ground.
var phase: float = 0
var tick: float = 0
func _process(delta: float) -> void:
	phase += delta
	tick += delta
	if tick >= 0.125:
		tick = 0
		queue_redraw()
func _draw() -> void:
	for side in [-1,1]:
		for i in range(6):
			var x: float = side*(378+i%2*38)+int(sin(phase*0.2+i)*12)
			var y: float = -200+i*98
			for j in range(4):
				var p := Vector2(x+j*16,y-abs(j-2)*3)
				draw_colored_polygon(PackedVector2Array([p,p+Vector2(6,-3),p+Vector2(6,-6),p+Vector2(18,-6),p+Vector2(18,-3),p+Vector2(30,-3),p+Vector2(36,2),p+Vector2(36,6),p+Vector2(0,6)]),Color(0.6,0.73,0.81,0.13))
	for i in range(8):
		var p := Vector2(-256+posmod(i*19,80),-160+fmod(phase*3+i*7,66)).round()
		draw_rect(Rect2(p,Vector2.ONE),Color(0.95,0.78,0.49,0.45))
	if get_parent().beacons_synchronized:
		for i in range(12):
			var p := Vector2(-32+sin(i*2.5)*28,-194-fmod(phase*8+i*9,84)).round()
			draw_rect(Rect2(p,Vector2(1,2)),Color("c6e6dc"))
