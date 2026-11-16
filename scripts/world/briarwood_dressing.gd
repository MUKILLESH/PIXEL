extends Node2D
## Non-blocking feet-sorted dressing. Region geometry and routes are untouched.
const Art = preload("res://scripts/world/briarwood_art.gd")
var kind: int = 0
var style: int = 0
func _draw() -> void:
	match style:
		0:
			preload("res://scripts/world/briarwood_sprites.gd").paint(self,kind)
		1: # Broken sanctuary arch, front face and deep side planes.
			for x in [-23,23]:
				draw_set_transform(Vector2(x,0))
				Art.pillar(self,47 if x < 0 else 39)
			draw_set_transform(Vector2.ZERO)
			Art.block(self,Vector2(-17,-48),12,5,7)
			Art.block(self,Vector2(18,-40),9,5,6)
			Art.poly(self,[Vector2(-26,-55),Vector2(-16,-64),Vector2(-3,-64),Vector2(-8,-56)],"798c7a")
			draw_line(Vector2(-24,-44),Vector2(-17,-10),Color("4a7149"),3)
			Art.fern(self,Vector2(-24,-3))
		2: # Abandoned survey supplies: broken wheel, urn shards, bedroll and lost cup.
			Art.block(self,Vector2(-9,0),8,4,7)
			draw_rect(Rect2(5,-4,13,5),Color("526b5d"))
			draw_rect(Rect2(6,-4,2,5),Color("aaa27b"))
			for p: Vector2 in [Vector2(-22,4),Vector2(21,6),Vector2(17,-8)]:
				Art.poly(self,[p,p+Vector2(4,-4),p+Vector2(7,0),p+Vector2(5,3)],"95795a")
				draw_line(p,p+Vector2(4,-4),Color("c1a57a"),1)
			draw_rect(Rect2(2,7,4,3),Color("8faaa3"))
		3: # Small, partially buried memorial with decorative roots.
			Art.pillar(self,17)
			draw_line(Vector2(-3,-16),Vector2(2,-14),Color("bcc0a0"),1)
			draw_line(Vector2(-3,-12),Vector2(1,-10),Color("869780"),1)
			draw_line(Vector2(9,2),Vector2(-7,-5),Color("6b6240"),2)

func _process(_delta: float) -> void:
	if style != 0: return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null: return
	var local: Vector2 = player.global_position-global_position
	# Only visual opacity changes; a player exploring behind decorative foliage stays legible.
	modulate.a = 0.38 if Rect2(-46,-115,92,112).has_point(local) else 1.0
