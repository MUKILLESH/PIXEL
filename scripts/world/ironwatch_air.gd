extends Node2D
## No overlay effects enter the active stealth corridor.
var phase: float = 0
var tick: float = 0
func _process(delta: float) -> void:
	phase += delta
	tick += delta
	if tick >= 0.12:
		tick = 0
		queue_redraw()
func _draw() -> void:
	for i in range(7):
		var p := Vector2(166+i*13,8+sin(phase*0.4+i)*14).round()
		draw_rect(Rect2(p,Vector2(1,1)),Color(0.85,0.77,0.59,0.25))
	if get_parent().third_beacon_activated:
		for width in [15,7,2]:
			draw_rect(Rect2(70-width,-280,width*2,80),Color(0.52,0.86,0.94,0.065))
		for i in range(12):
			var p := Vector2(70+sin(phase*0.6+i*2)*26,-159-fmod(phase*9+i*11,102)).round()
			draw_rect(Rect2(p,Vector2(1,2)),Color("afdfe5") if i%3 else Color("e9d198"))
