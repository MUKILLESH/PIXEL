extends Node2D
## A few stepped smoke clusters and motes at 8 Hz; no static scenery regeneration.
var time: float = 0.0
var accumulator: float = 0.0

func _process(delta: float) -> void:
	time += delta
	accumulator += delta
	if accumulator >= 0.125:
		accumulator = 0
		queue_redraw()

func _draw() -> void:
	for i in range(3):
		var p := Vector2(-12+i*9,-104+roundf(sin(time*0.6+i)*3))
		draw_rect(Rect2(p,Vector2(1,2)),Color(0.70,0.85,0.79,0.22+sin(time+i)*0.10))
	for chimney: Vector2 in [Vector2(-132,-79),Vector2(29,-165)]:
		for i in range(4):
			var phase: float = fmod(time*4+i*9,36)
			var p := chimney+Vector2(roundf(phase*0.35+sin(phase*0.2)*2),-roundf(phase))
			var color := Color(0.57,0.57,0.53,(1-phase/36)*0.20)
			draw_rect(Rect2(p,Vector2(7+i,4)),color)
			draw_rect(Rect2(p+Vector2(2,-2),Vector2(4+i,8)),color)
	for i in range(8):
		var p := Vector2(-180+i*53,80+posmod(i*47,130))
		p += Vector2(roundf(sin(time*0.4+i)*4),roundf(cos(time*0.7+i)*3))
		var brightness: float = maxf(0,sin(time*0.9+i))
		draw_rect(Rect2(p,Vector2(1,1)),Color(0.9,0.78,0.4,brightness*0.5))
	for i in range(3):
		var p := Vector2(12+i*12,147+roundf(sin(time+i)*2))
		draw_line(p,p+Vector2(6,0),Color(0.65,0.82,0.80,0.28),1)
