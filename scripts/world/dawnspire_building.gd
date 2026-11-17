extends StaticBody2D
## Procedural 2.5D pixel-art alpine architecture for Dawnspire Mountain (Chapter 4):
## FoothillsArch, CliffShelter, SkybridgeAnchors, PilgrimChapel (cutaway murals),
## ObservatoryDome, DawnspireSanctum, and GreatBellPortal.

@export var kind: String = "foothills_arch"

class CutawayChapelInterior extends Node2D:
	var owner_building: Node2D
	func _draw() -> void:
		if owner_building != null:
			owner_building.draw_pilgrim_chapel_interior(self)

var interior_visual: Node2D
var beacons_synchronized: bool = false
var great_bell_unlocked: bool = false

func _ready() -> void:
	match kind:
		"foothills_arch":
			_add_box(Vector2(0, -10), Vector2(84, 22))
		"cliff_shelter":
			_add_box(Vector2(0, -12), Vector2(44, 16))
		"skybridge_anchors":
			# Twin flanking masonry winches; keep central bridge lane x=-24..24 open!
			_add_box(Vector2(-46, -6), Vector2(26, 22))
			_add_box(Vector2(46, -6), Vector2(26, 22))
		"pilgrim_chapel":
			# Back wall only so Aren walks freely inside Pilgrim's Refuge courtyard
			_add_box(Vector2(0, -20), Vector2(118, 16))
			z_index = -1
			interior_visual = CutawayChapelInterior.new()
			interior_visual.owner_building = self
			interior_visual.z_index = 1
			add_child(interior_visual)
		"observatory_dome":
			_add_box(Vector2(0, -12), Vector2(76, 18))
		"dawnspire_sanctum":
			_add_box(Vector2(0, -12), Vector2(106, 18))
		"great_bell_portal":
			_add_box(Vector2(0, -12), Vector2(90, 20))

func _add_box(pos: Vector2, sz: Vector2) -> void:
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = sz
	col.shape = rect
	col.position = pos
	add_child(col)

const Art = preload("res://scripts/world/dawnspire_art.gd")
func _draw() -> void:
	var active: bool = beacons_synchronized if kind == "dawnspire_sanctum" else great_bell_unlocked
	draw_texture(Art.texture(kind+"_"+str(int(active))),Vector2(-128,-224))
func draw_pilgrim_chapel_interior(c: Node2D) -> void:
	c.draw_texture(Art.texture("chapel_interior"),Vector2(-128,-224))
