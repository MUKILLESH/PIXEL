extends Node2D
## The mill's only animated geometry; 10 Hz, same axle location as the original.
var angle: float = 0
var active: bool = false
func p(u: float,h: float,v: float = -6) -> Vector2:
	return Vector2(u-v,-(u+v)*0.5-h).round()
func _draw() -> void:
	var hub := p(14,14)
	var rim := PackedVector2Array()
	var back := PackedVector2Array()
	for i in range(17):
		var a: float = angle+i*TAU/16
		rim.append(p(14+cos(a)*19,14+sin(a)*19))
		back.append(p(14+cos(a)*19,14+sin(a)*19,-1))
	draw_polyline(back,Color("293a36"),5)
	draw_polyline(rim,Color("443f2d"),5)
	draw_polyline(rim,Color("af9564"),1)
	for i in range(16):
		if not active and i in [2,3,9]: continue
		var a: float = angle+i*TAU/16
		var tip := p(14+cos(a)*19,14+sin(a)*19)
		draw_line(tip,back[i],Color("9e8657"),4)
		draw_rect(Rect2(tip,Vector2(2,2)),Color("c1b184"))
		if i%2 == 0:
			draw_line(hub,tip,Color("574c34"),3)
			draw_line(hub,tip,Color("a18a5b"),1)
	for u in [3,26]:
		draw_line(p(u,0,-11),p(14,14,-11),Color("4e4b36"),3)
	draw_rect(Rect2(hub-Vector2(3,3),Vector2(6,6)),Color("7bbabb") if active else Color("6a7977"))
	draw_rect(Rect2(hub-Vector2(1,1),Vector2(2,2)),Color("d2c792"))
	if active:
		for i in range(5):
			var q := p(5+i*5,-4)+Vector2(int(angle*5)%4,0)
			draw_rect(Rect2(q,Vector2(3,1)),Color("a5d3c6"))
