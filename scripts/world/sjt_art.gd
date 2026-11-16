extends Node2D
## Original 2:1 projected pixel geometry for Bellhaven Village (Cottage, Bell Tower, Blacksmith).
@export_enum("Roof and flank", "Facade bay", "Canopy", "Column", "Name band") var part: int = 0
var bay: int = 0
var anchor := Vector2.ZERO

const STONE_LIGHT := Color("8c857b")
const STONE_MID := Color("736c63")
const STONE_DARK := Color("524c46")
const TIMBER := Color("3d291a")
const TIMBER_LIGHT := Color("5e4029")
const PLASTER := Color("cbbba0")
const PLASTER_SHADE := Color("b0a087")
const SHINGLE := Color("69422b")
const SHINGLE_DARK := Color("4f311f")
const SLATE := Color("3b4452")
const SLATE_LIGHT := Color("4f5b6b")
const GOLD := Color("e6b85c")

static func project(u: float, v: float, height: float = 0) -> Vector2:
	return Vector2(-112 + u - v, -u * 0.5 - v * 0.5 - height).round()

func p(u: float, v: float, height: float = 0) -> Vector2:
	return project(u,v,height) - anchor

func plane(u0: float, u1: float, v: float, bottom: float, top: float, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([p(u0,v,bottom),p(u1,v,bottom),p(u1,v,top),p(u0,v,top)]),color)

func slab(u0: float, u1: float, v0: float, v1: float, height: float, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([p(u0,v0,height),p(u1,v0,height),p(u1,v1,height),p(u0,v1,height)]),color)

func _draw() -> void:
	match part:
		0: draw_shell()
		1: draw_bay()
		2: draw_canopy()
		3:
			# Carved oak porch post with stone plinth base
			draw_rect(Rect2(-4,-4,8,5),STONE_DARK)
			draw_rect(Rect2(-3,-27,6,24),TIMBER)
			draw_rect(Rect2(-2,-27,2,24),TIMBER_LIGHT)
		4:
			var transform := Transform2D(Vector2(1,-0.5),Vector2(0,1),p(84,-3,106))
			draw_set_transform_matrix(transform)
			draw_string(preload("res://assets/fonts/after_hours.tres"),Vector2.ZERO,"BELLHAVEN BELFRY",HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("e6d2a2"))

func draw_shell() -> void:
	# Left flank of the Cottage (u=0, v=0..64) with stone plinth and timber gable
	draw_colored_polygon(PackedVector2Array([p(0,0),p(0,64),p(0,64,46),p(0,0,46)]),PLASTER_SHADE)
	draw_colored_polygon(PackedVector2Array([p(0,0),p(0,64),p(0,64,8),p(0,0,8)]),STONE_DARK)
	for v in range(0,64,10):
		for h in range(0,8,4):
			draw_colored_polygon(PackedVector2Array([p(0,v,h),p(0,v+9,h),p(0,v+9,h+3),p(0,v,h+3)]),STONE_MID)
	# Gable triangle on cottage side
	draw_colored_polygon(PackedVector2Array([p(0,0,46),p(0,64,46),p(0,32,74)]),PLASTER_SHADE)
	for v in [0,16,48,64]:
		draw_line(p(0,v,8),p(0,v,46),TIMBER,3)
	for v in [2,43]:
		draw_line(p(-1,v,10),p(-1,v+18,41),TIMBER_LIGHT,2)
	draw_line(p(-1,0,24),p(-1,64,24),TIMBER,2)
	# Side timber framing & shuttered candlelit window
	draw_line(p(0,0,46),p(0,32,74),TIMBER,3)
	draw_line(p(0,64,46),p(0,32,74),TIMBER,3)
	draw_line(p(0,32,8),p(0,32,74),TIMBER,2)
	draw_colored_polygon(PackedVector2Array([p(0,22,22),p(0,40,22),p(0,40,36),p(0,22,36)]),TIMBER)
	draw_colored_polygon(PackedVector2Array([p(0,25,24),p(0,37,24),p(0,37,34),p(0,25,34)]),Color("d99843"))

	# Cottage pitched shingle roof (u=0..80, v=0..64, peak v=32 at h=74)
	draw_colored_polygon(PackedVector2Array([p(-3,-3,44),p(80,-3,44),p(80,32,74),p(-3,32,74)]),SHINGLE)
	draw_colored_polygon(PackedVector2Array([p(-3,32,74),p(80,32,74),p(80,66,44),p(-3,66,44)]),SHINGLE_DARK)
	draw_line(p(-3,32,74),p(80,32,74),Color("85573a"),3)
	shingles(-3,80,-3,32,44,74,false)
	shingles(-3,80,32,66,74,44,true)
	for u in range(0,80,8):
		draw_line(p(u,32,75),p(u+6,32,75),Color("b18054"),3)
	draw_line(p(-3,-3,43),p(80,-3,43),Color("281f20"),3)
	# Cottage stone chimney
	draw_colored_polygon(PackedVector2Array([p(16,36,56),p(28,36,56),p(28,36,86),p(16,36,86)]),STONE_MID)
	draw_colored_polygon(PackedVector2Array([p(16,36,56),p(16,48,56),p(16,48,86),p(16,36,86)]),STONE_DARK)
	slab(15,29,35,49,86,STONE_LIGHT)
	for h in range(58,85,6):
		draw_line(p(16,36,h),p(28,36,h),STONE_DARK,1)
		draw_line(p(21 if h%12 else 25,36,h),p(21 if h%12 else 25,36,h+5),STONE_DARK,1)
	slab(18,26,38,46,87,Color("2b292a"))

	# Blacksmith pitched slate roof (u=144..224, v=0..64, peak v=32 at h=74)
	draw_colored_polygon(PackedVector2Array([p(144,-3,48),p(227,-3,48),p(227,32,74),p(144,32,74)]),SLATE_LIGHT)
	draw_colored_polygon(PackedVector2Array([p(144,32,74),p(227,32,74),p(227,66,48),p(144,66,48)]),SLATE)
	draw_line(p(144,32,74),p(227,32,74),Color("69778a"),3)
	shingles(144,227,-3,32,48,74,true)
	shingles(144,227,32,66,74,48,true)
	draw_line(p(144,-3,47),p(227,-3,47),Color("252733"),3)
	# Blacksmith stone forge chimney stack with faint ember glow
	draw_colored_polygon(PackedVector2Array([p(176,34,58),p(194,34,58),p(194,34,92),p(176,34,92)]),STONE_DARK)
	draw_colored_polygon(PackedVector2Array([p(176,34,58),p(176,52,58),p(176,52,92),p(176,34,92)]),Color("3b3632"))
	slab(175,195,33,53,92,STONE_MID)
	slab(179,191,37,49,93,Color("d9682b"))
	for h in range(60,92,6):
		draw_line(p(176,34,h),p(194,34,h),Color("29292c"),1)
		draw_line(p(185,34,h),p(185,34,h+5),STONE_MID,1)

	# Central Bell Tower (u=80..144, v=0..64, rises to h=116 + spire to 142)
	draw_colored_polygon(PackedVector2Array([p(80,0,50),p(80,64,50),p(80,64,116),p(80,0,116)]),STONE_DARK)
	for h in range(50,116,7):
		for v in range(0,64,12):
			var end: int = mini(v+11,64)
			draw_colored_polygon(PackedVector2Array([p(80,v,h),p(80,end,h),p(80,end,h+6),p(80,v,h+6)]),Color("655f59") if (v+h)%3 else Color("756e61"))
			draw_line(p(80,v,h+6),p(80,end,h+6),Color("7c7568"),1)
	slab(80,144,0,64,116,STONE_MID)
	# Spire / pyramidal slate roof over Bell Tower
	var apex := p(112,32,146)
	draw_colored_polygon(PackedVector2Array([p(78,-2,115),p(146,-2,115),apex]),SLATE_LIGHT)
	draw_colored_polygon(PackedVector2Array([p(78,66,115),p(78,-2,115),apex]),SLATE)
	draw_colored_polygon(PackedVector2Array([p(146,-2,115),p(146,66,115),apex]),Color("2e3542"))
	draw_line(p(78,-2,115),apex,Color("7a8799"),2)
	draw_line(p(146,-2,115),apex,Color("5c6878"),2)
	spire_tiles(p(78,-2,115),p(146,-2,115),apex,false)
	spire_tiles(p(78,66,115),p(78,-2,115),apex,true)
	# Brass finial cross / weathervane spire
	draw_line(apex,apex+Vector2(0,-14),GOLD,2)
	draw_line(apex+Vector2(-4,-9),apex+Vector2(4,-9),GOLD,2)
	draw_rect(Rect2(apex.x-1,apex.y-15,3,3),Color("ffe299"))

func draw_bay() -> void:
	var u: int = bay * 16
	if bay <= 4:
		# COTTAGE BAYS (u=0..80)
		plane(u,u+16,0,0,48,PLASTER if bay % 2 == 0 else Color("d6c7ad"))
		plane(u,u+16,0,0,8,STONE_MID)
		masonry(u,u+16,8,false)
		plane(u,u+16,-1,45,49,TIMBER)
		plane(u,u+16,-1,24,27,TIMBER)
		draw_line(p(u,0,8),p(u,0,48),TIMBER,2)
		# Diagonal braces, pegs, plaster wear and carved lintels.
		if bay in [0,4]:
			draw_line(p(u+2,-1,9),p(u+14,-1,23),TIMBER,2)
			draw_line(p(u+2,-1,29),p(u+14,-1,43),TIMBER,2)
		for h in [9,25,45]:
			draw_rect(Rect2(p(u,-2,h),Vector2(2,2)),Color("c39864"))
		plane(u+3,u+8,-1,10,12,PLASTER_SHADE)
		if bay == 2:
			# Wooden cottage plank door
			plane(u+3,u+13,-1,0,25,Color("4f311c"))
			plane(u+4,u+12,-2,1,23,Color("664126"))
			draw_rect(Rect2(p(u+10,-2,11),Vector2(2,2)),GOLD)
			for du in [5,8,11]: draw_line(p(u+du,-3,1),p(u+du,-3,22),TIMBER,1)
			for h in [5,18]: draw_line(p(u+3,-3,h),p(u+7,-3,h),Color("252d34"),2)
			slab(u+1,u+15,-6,-1,0,STONE_LIGHT)
		elif bay in [1,3]:
			# Warm candlelit diamond-pane cottage windows
			plane(u+3,u+13,-1,28,39,TIMBER)
			plane(u+4,u+12,-2,29,38,Color("f2b34e"))
			draw_line(p(u+8,-2,29),p(u+8,-2,38),TIMBER,1)
			draw_line(p(u+4,-2,33),p(u+12,-2,33),TIMBER,1)
			plane(u+1,u+3,-3,28,39,Color("5b6958"))
			plane(u+13,u+15,-3,28,39,Color("73816a"))
			draw_line(p(u+3,-3,27),p(u+13,-3,27),Color("ac8356"),2)
			plane(u+5,u+7,-3,34,37,Color("ffe2a0"))
	elif bay <= 8:
		# BELL TOWER BAYS (u=80..144)
		plane(u,u+16,0,0,116,STONE_MID if bay in [6,7] else STONE_LIGHT)
		masonry(u,u+16,116,true)
		plane(u,u+16,0,0,8,STONE_DARK)
		# Stone quoins / buttress framing on outer tower edges
		if bay in [5,8]:
			for q in range(0,112,12):
				plane(u if bay == 5 else u+11,u+5 if bay == 5 else u+16,-1,q,q+8,STONE_DARK if bay == 8 else Color("9c9488"))
		# Lower belfry arched oak doors (bays 6..7)
		if bay in [6,7]:
			plane(u+1 if bay == 6 else u,u+16 if bay == 6 else u+15,-1,0,34,STONE_DARK)
			plane(u+3 if bay == 6 else u,u+16 if bay == 6 else u+13,-2,0,30,Color("3b2516"))
			draw_line(p(u+3 if bay == 6 else u,-3,10),p(u+15 if bay == 6 else u+12,-3,10),Color("282b30"),2)
			draw_line(p(u+3 if bay == 6 else u,-3,21),p(u+15 if bay == 6 else u+12,-3,21),Color("282b30"),2)
		# Small tower arrow-slit / lancet window at mid-height
		if bay in [6,7]:
			plane(u+5,u+11,-1,44,58,Color("242933"))
			plane(u+6,u+10,-2,46,56,Color("d99843"))
		# Open stone Belfry Archway (height 70..100) housing the hanging bronze bell
		if bay in [6,7]:
			plane(u+1 if bay == 6 else u,u+16 if bay == 6 else u+15,-1,70,98,Color("1c1d24"))
			# Draw the Great Village Bell suspended across bays 6 and 7
			if bay == 6:
				var bx: float = u + 16
				draw_line(p(bx-4,-2,98),p(bx+4,-2,98),TIMBER,3)
				draw_line(p(bx,-2,98),p(bx,-2,91),Color("2a2d34"),2)
				draw_colored_polygon(PackedVector2Array([
					p(bx-5,-3,90),p(bx+5,-3,90),p(bx+8,-3,77),p(bx-8,-3,77)
				]),Color("d49b4b"))
				draw_colored_polygon(PackedVector2Array([
					p(bx-4,-3,89),p(bx-1,-3,89),p(bx-2,-3,78),p(bx-6,-3,78)
				]),Color("f2cb72"))
				draw_line(p(bx-9,-3,77),p(bx+9,-3,77),Color("8c5f23"),2)
				draw_rect(Rect2(p(bx-1,-3,74),Vector2(3,3)),Color("a37534"))
		# Stone cornice & name plaque shelf
		plane(u,u+16,-1,103,116,STONE_DARK)
		plane(u,u+16,-1,113,117,STONE_LIGHT)
		if bay in [5,8]:
			lantern(u+8,38)
	else:
		# BLACKSMITH WORKSHOP BAYS (u=144..224)
		plane(u,u+16,0,0,50,STONE_DARK if bay % 2 == 0 else STONE_MID)
		masonry(u,u+16,46,false)
		plane(u,u+16,0,0,6,Color("3b3632"))
		plane(u,u+16,-1,46,50,TIMBER)
		draw_line(p(u,0,6),p(u,0,48),TIMBER,2)
		if bay in [10,11]:
			# Open brick/stone forge hearth glowing with hot embers
			plane(u+1 if bay == 10 else u,u+16 if bay == 10 else u+15,-1,0,26,Color("2e2824"))
			plane(u+3 if bay == 10 else u,u+16 if bay == 10 else u+13,-2,2,20,Color("c94418"))
			plane(u+5 if bay == 10 else u,u+16 if bay == 10 else u+11,-3,2,14,Color("ff9436"))
			plane(u+8 if bay == 10 else u,u+16 if bay == 10 else u+8,-3,3,8,Color("ffe07d"))
		elif bay == 12:
			# Smithy timber doorway
			plane(u+3,u+13,-1,0,28,TIMBER)
			plane(u+4,u+12,-2,1,26,TIMBER_LIGHT)
		elif bay == 13:
			# Glowing workshop shuttered window & hanging iron tools
			plane(u+3,u+13,-1,22,34,TIMBER)
			plane(u+4,u+12,-2,23,33,Color("ffae42"))
			draw_line(p(u+5,-2,14),p(u+5,-2,20),Color("949ca6"),2)
			draw_line(p(u+9,-2,15),p(u+9,-2,20),Color("949ca6"),2)
	if bay == 6:
		bell_detail()
	if bay == 0:
		lantern(u+9,31)

func draw_canopy() -> void:
	# Medieval oak shingle porch canopy over Bellhaven Belfry entrance
	slab(72,152,-48,0,26,SHINGLE)
	for v in range(-48,0,6):
		for u in range(72,152,10):
			slab(u+1,u+9,v+1,v+5,27,Color("8e603e") if (u+v)%3 else Color("a4754a"))
	for v in range(-44,-2,8):
		draw_line(p(74,v,27),p(150,v,27),SHINGLE_DARK,2)
	plane(72,152,-48,22,27,TIMBER)
	draw_colored_polygon(PackedVector2Array([p(72,-48,22),p(72,0,22),p(72,0,27),p(72,-48,27)]),TIMBER_LIGHT)
	draw_line(p(72,-48,27),p(152,-48,27),Color("8f6142"),2)
	# Small warm lanterns suspended from porch eaves
	for lx in [84,140]:
		draw_rect(Rect2(p(lx,-46,19),Vector2(3,4)),Color("ffca57"))

func masonry(start: int, end: int, height: int, tower: bool) -> void:
	var palette: Array = [Color("8b8170"),Color("766f64"),Color("968a76"),Color("80786c")] if tower else [Color("655e54"),Color("776c5c"),Color("81725f"),Color("6c665b")]
	for row in range(0,height,7):
		var split: int = start+5 if (row/7)%2 else start+11
		plane(start+1,split-1,-0.2,row+1,mini(row+6,height),palette[posmod(row+start,4)])
		plane(split,end-1,-0.2,row+1,mini(row+6,height),palette[posmod(row+start+1,4)])
		draw_line(p(start+1,-0.3,row+6),p(split-1,-0.3,row+6),palette[posmod(row+start,4)].lightened(0.13),1)
		if row%21 == 0:
			draw_line(p(split+2,-0.5,row+2),p(split+4,-0.5,row+4),Color("524e45"),1)

func shingles(u0: int, u1: int, v0: int, v1: int, h0: int, h1: int, slate: bool) -> void:
	var palette: Array = [Color("586774"),Color("485765"),Color("65737e"),Color("52616f")] if slate else [Color("9a6140"),Color("855334"),Color("ae7549"),Color("956b45")]
	for v in range(v0,v1,5):
		var h: float = lerpf(h0,h1,float(v-v0)/(v1-v0))
		var vn: int = mini(v+4,v1)
		var hn: float = lerpf(h0,h1,float(vn-v0)/(v1-v0))
		for u in range(u0,u1,10):
			var un: int = mini(u+9,u1)
			draw_colored_polygon(PackedVector2Array([p(u,v,h+1),p(un,v,h+1),p(un,vn,hn+1),p(u,vn,hn+1)]),palette[posmod(u+v*3,4)])
			draw_line(p(u,v,h+1),p(un,v,h+1),palette[posmod(u+v*3,4)].lightened(0.15),1)

func spire_tiles(a: Vector2, b: Vector2, tip: Vector2, shaded: bool) -> void:
	for row in range(8):
		var t0: float = row/8.0
		var t1: float = (row+0.85)/8.0
		var left: Vector2 = a.lerp(tip,t0)
		var right: Vector2 = b.lerp(tip,t0)
		var count: int = maxi(1,8-row)
		for tile in range(count):
			var f0: float = tile/float(count)
			var f1: float = (tile+0.88)/count
			var points := PackedVector2Array([left.lerp(right,f0).round(),left.lerp(right,f1).round(),a.lerp(tip,t1).lerp(b.lerp(tip,t1),f1).round(),a.lerp(tip,t1).lerp(b.lerp(tip,t1),f0).round()])
			var color := Color("455362") if shaded else Color("627588")
			draw_colored_polygon(points,color.lightened(posmod(tile+row,3)*0.05))

func lantern(u: float, h: float) -> void:
	var c := p(u,-4,h)
	draw_rect(Rect2(c-Vector2(4,6),Vector2(8,12)),Color("292b30"))
	draw_rect(Rect2(c-Vector2(2,4),Vector2(4,7)),Color("ffcf75"))
	draw_rect(Rect2(c-Vector2(1,3),Vector2(2,5)),Color("fff0ba"))
	draw_line(c+Vector2(-5,-7),c+Vector2(5,-7),GOLD,1)

func bell_detail() -> void:
	# Full arch and bell are owned by one bay so adjacent slices cannot cut the bell.
	var arch := PackedVector2Array([p(97,-4,70),p(97,-4,90),p(101,-4,98),p(108,-4,102),p(116,-4,102),p(123,-4,98),p(127,-4,90),p(127,-4,70)])
	draw_colored_polygon(arch,Color("20262e"))
	draw_polyline(arch,Color("afa084"),2)
	draw_line(p(98,-5,96),p(126,-5,96),TIMBER_LIGHT,3)
	draw_line(p(112,-5,96),p(112,-5,89),GOLD,2)
	draw_colored_polygon(PackedVector2Array([p(107,-6,90),p(117,-6,90),p(119,-6,81),p(123,-6,76),p(101,-6,76),p(105,-6,81)]),Color("b48038"))
	plane(107,111,-7,80,88,Color("f3c568"))
	draw_line(p(101,-7,76),p(123,-7,76),Color("ffe0a0"),2)
	draw_line(p(103,-7,74),p(121,-7,74),Color("76522c"),2)
	draw_rect(Rect2(p(111,-7,72),Vector2(3,3)),GOLD)
