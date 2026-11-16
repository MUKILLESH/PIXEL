extends "res://scripts/world/prop.gd"
## Bellhaven-only skin; inherits the exact original trunk collider.
func _draw() -> void:
	if kind != 0:
		super._draw()
		return
	var variation: int = posmod(int(position.x)*13+int(position.y)*7,3)
	var lift: int = variation*5
	draw_colored_polygon(PackedVector2Array([Vector2(-8,0),Vector2(-4,-9),Vector2(-5,-35-lift),Vector2(2,-45-lift),Vector2(6,-29),Vector2(3,-8),Vector2(8,1)]),Color("302c27"))
	draw_line(Vector2(-2,-3),Vector2(-1,-38),Color("967047"),2)
	draw_line(Vector2(0,-24),Vector2(-15,-39-lift),Color("5a4632"),3)
	draw_line(Vector2(0,-19),Vector2(17,-32-lift),Color("5a4632"),3)
	# Stepped, asymmetric leaf masses instead of circles or regular polygons.
	var centers: Array[Vector2] = [Vector2(-18,-38),Vector2(17,-35),Vector2(-7,-57),Vector2(11,-54),Vector2(-5,-31)]
	for i in range(centers.size()):
		var c: Vector2 = centers[i]-Vector2(0,lift)
		var r: int = 16 + posmod(i+variation,3)*2
		var outline := PackedVector2Array([Vector2(-r,-5),Vector2(-r,-12),Vector2(-r+6,-12),Vector2(-r+6,-17),Vector2(-3,-17),Vector2(-3,-21),Vector2(7,-21),Vector2(7,-16),Vector2(r-2,-16),Vector2(r-2,-7),Vector2(r+3,-7),Vector2(r+3,4),Vector2(r-2,4),Vector2(r-2,10),Vector2(5,10),Vector2(5,14),Vector2(-7,14),Vector2(-7,10),Vector2(-r+2,10),Vector2(-r+2,3),Vector2(-r-3,3),Vector2(-r-3,-5)])
		for k in range(outline.size()): outline[k] += c
		draw_colored_polygon(outline,Color("20362f"))
		var inner := outline.duplicate()
		for k in range(inner.size()): inner[k] = c+((inner[k]-c)*Vector2(0.9,0.84)).round()-Vector2(0,2)
		draw_colored_polygon(inner,Color("365740") if i%2 else Color("3e6144"))
		var crown := PackedVector2Array([Vector2(-r+5,-9),Vector2(-r+5,-13),Vector2(-5,-13),Vector2(-5,-17),Vector2(5,-17),Vector2(5,-12),Vector2(12,-12),Vector2(12,-7),Vector2(2,-7),Vector2(2,-3),Vector2(-9,-3),Vector2(-9,-7)])
		for k in range(crown.size()): crown[k] += c
		draw_colored_polygon(crown,Color("628151") if i < 4 else Color("4a704a"))
		for j in range(4):
			var x: int = -r+4+posmod(j*11+i*3,r*2-8)
			var y: int = -16+posmod(j*7+i*5,23)
			var color: Color = Color("456b49") if y < -5 else Color("304f3b")
			if j%4 == 0 and i < 4: color = Color("83945d")
			draw_rect(Rect2(c+Vector2(x,y),Vector2(5+posmod(j,3),2)),color)
			draw_rect(Rect2(c+Vector2(x+2,y-1),Vector2(3,4)),color)
	# Exposed roots and a fern at the base are still part of this foot-sorted actor.
	draw_line(Vector2(-1,-6),Vector2(-9,0),Color("705139"),2)
	for x in [-11,9]:
		draw_line(Vector2(x,1),Vector2(x-3,-5),Color("68784d"),1)

func ground_shadow() -> PackedVector2Array:
	return PackedVector2Array([Vector2(-22,-5),Vector2(-9,-13),Vector2(13,-10),Vector2(46,9),Vector2(37,17),Vector2(12,15)])
