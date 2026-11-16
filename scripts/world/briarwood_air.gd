extends Node2D
## Sparse elevated magic. Maximum 18 motes and three narrow translucent beam strips.
var time: float = 0.0
var elapsed: float = 0.0
func _process(delta: float) -> void:
	time += delta
	elapsed += delta
	if elapsed >= 0.1:
		elapsed = 0
		queue_redraw()
func _draw() -> void:
	var active: bool = get_parent().beacon_activated
	if active:
		var origin := Vector2(-32,-216)
		for width in [15,8,2]:
			draw_rect(Rect2(origin+Vector2(-width,-126),Vector2(width*2,80)),Color(0.48,0.94,0.84,0.07))
		for i in range(12):
			var p := origin+Vector2(sin(time*0.5+i*2)*24,-16-fmod(time*9+i*9,102)).round()
			draw_rect(Rect2(p,Vector2(1,2)),Color("b4e8bd") if i%3 else Color("f6d681"))
		var y: int = -265-int(sin(time)*2)
		draw_polyline(PackedVector2Array([Vector2(-44,y),Vector2(-32,y-6),Vector2(-20,y),Vector2(-32,y+6),Vector2(-44,y)]),Color("f3d995"),1)
	for i in range(6):
		var p := Vector2(-164+i*14,-186+sin(time+i)*6).round()
		draw_rect(Rect2(p,Vector2(1,1)),Color(0.4,0.85,0.8,0.5))
