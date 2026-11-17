extends StaticBody2D
## Procedural isometric pixel-art architecture for Ironwatch Keep (Chapter 3):
## GatehouseBastion, RuinedBarracks, CutawayArchives (with Gothic lancets),
## HallOfCrests, ShadowColonnade, and BeaconVaultSanctum.

@export var kind: String = "gatehouse_bastion"

class CutawayArchiveVisual extends Node2D:
	var owner_building: Node2D
	func _draw() -> void:
		if owner_building != null:
			owner_building.draw_cutaway_archive_interior(self)

var interior_visual: Node2D
var third_beacon_lit: bool = false

func _ready() -> void:
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	match kind:
		"gatehouse_bastion":
			rect.size = Vector2(96, 36)
			col.position = Vector2(0, -14)
		"ruined_barracks":
			rect.size = Vector2(104, 34)
			col.position = Vector2(0, -16)
		"cutaway_archives":
			# Back wall collision only so Aren walks cleanly onto the cutaway library floor
			rect.size = Vector2(120, 18)
			col.position = Vector2(0, -28)
			z_index = -1
			interior_visual = CutawayArchiveVisual.new()
			interior_visual.owner_building = self
			interior_visual.z_index = 1
			add_child(interior_visual)
		"hall_of_crests":
			rect.size = Vector2(88, 16)
			col.position = Vector2(0, -24)
		"shadow_colonnade":
			rect.size = Vector2(26, 150)
			col.position = Vector2(0, 0)
		"beacon_vault_sanctum":
			rect.size = Vector2(168, 22)
			col.position = Vector2(0, -24)
	col.shape = rect
	add_child(col)

const Art = preload("res://scripts/world/ironwatch_art.gd")
func _draw() -> void:
	if "--bake-ironwatch" in OS.get_cmdline_user_args():
		Art.building(self,kind,third_beacon_lit)
	else:
		var state: int = 1 if kind == "beacon_vault_sanctum" and third_beacon_lit else 0
		draw_texture(Art.texture("res://assets/ironwatch/"+kind+"_"+str(state)+".png"),Vector2(-128,-224))

func draw_cutaway_archive_interior(canvas: Node2D) -> void:
	if "--bake-ironwatch" in OS.get_cmdline_user_args():
		Art.archive(canvas)
	else:
		canvas.draw_texture(Art.texture("res://assets/ironwatch/archives_interior.png"),Vector2(-128,-224))
