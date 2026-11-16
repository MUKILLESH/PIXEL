extends RefCounted
## Imported nearest-filtered original forest sprites. No frame-time image generation.
static var textures: Dictionary = {}
static func paint(canvas: Node2D, kind: int) -> void:
	var variant: int = posmod(absi(int(canvas.position.x)*13+int(canvas.position.y)*7),3) if kind < 2 else 0
	var path := "res://assets/forest/prop_%d_%d.png" % [kind,variant]
	if not textures.has(path): textures[path] = load(path)
	canvas.draw_texture(textures[path],Vector2(-64,-128))
