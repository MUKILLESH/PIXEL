extends Node2D
## Non-blocking architecture dressing, sorted by original wall feet.
const Art = preload("res://scripts/world/ironwatch_art.gd")
var kind: String = "curtain"
func _draw() -> void:
	if not "--bake-ironwatch" in OS.get_cmdline_user_args():
		draw_texture(Art.texture("res://assets/ironwatch/decor_"+kind+".png"),Vector2(-128,-224))
		return
	match kind:
		"curtain", "retaining", "low_wall":
			var h: int = 46 if kind == "curtain" else (25 if kind == "retaining" else 10)
			Art.masonry(self,Rect2(-30,-h,60,h),kind != "curtain")
			Art.poly(self,[Vector2(-30,-h),Vector2(-22,-h-4),Vector2(38,-h-4),Vector2(30,-h)],"757889")
			for x in [-24,-4,16]:
				Art.block(self,Vector2(x,-h),6,3,6 if kind != "low_wall" else 3)
			if kind == "curtain":
				Art.arch(self,Vector2(0,-5),5,23)
		"tower":
			Art.masonry(self,Rect2(-18,-86,36,86))
			Art.poly(self,[Vector2(18,0),Vector2(31,-6),Vector2(31,-92),Vector2(18,-86)],"293147")
			for y in [-30,-60,-86]:
				draw_line(Vector2(-20,y),Vector2(18,y),Color("8c8b99"),3)
				draw_line(Vector2(18,y),Vector2(31,y-6),Color("626b7d"),3)
			for x in [-15,0,15]: Art.block(self,Vector2(x,-88),6,3,8)
			Art.arch(self,Vector2(0,-38),7,30,true)
			Art.banner(self,Vector2(0,-28),23)
		"throne":
			Art.block(self,Vector2(0,3),28,14,5)
			Art.block(self,Vector2(0,-3),22,11,5)
			Art.masonry(self,Rect2(-15,-53,30,46))
			Art.arch(self,Vector2(0,-17),12,34)
			Art.banner(self,Vector2(0,-48),26)
			Art.block(self,Vector2(0,-6),15,7,10)
			for x in [-19,19]: Art.pillar(self,Vector2(x,-2),52)
			Art.crest(self,Vector2(0,-61),0)
		"armor":
			Art.block(self,Vector2.ZERO,12,6,4)
			draw_line(Vector2(0,-4),Vector2(0,-31),Color("776750"),3)
			Art.poly(self,[Vector2(-9,-28),Vector2(-6,-34),Vector2(6,-34),Vector2(9,-28),Vector2(5,-15),Vector2(-5,-15)],"717e90")
			draw_line(Vector2(-6,-28),Vector2(5,-19),Color("a8acb0"),1)
			draw_line(Vector2(0,-31),Vector2(0,-15),Color("343b51"),2)
			Art.poly(self,[Vector2(-5,-37),Vector2(-3,-44),Vector2(3,-44),Vector2(6,-38),Vector2(4,-34),Vector2(-4,-34)],"8b91a0")
			draw_line(Vector2(-3,-38),Vector2(3,-38),Color("232b3c"),2)
