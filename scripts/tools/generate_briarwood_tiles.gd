extends SceneTree
## Original region-local clustered forest tiles. Run once, never during gameplay.
func _initialize() -> void:
	var image := Image.create(384,32,false,Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var base: Array[Color] = [Color("263e33"),Color("263e33"),Color("263e33"),Color("263e33"),Color("263e33"),Color("263e33")]
	for tile in range(6):
		for y in range(32):
			for x in range(64):
				if absf((x+0.5-32)/32.0)+absf((y+0.5-16)/16.0) <= 1:
					image.set_pixel(tile*64+x,y,base[tile])
		for cluster in range(12):
			var cx: int = posmod(cluster*17+tile*11,54)+5
			var cy: int = posmod(cluster*7+tile*3,24)+4
			for dy in range(2):
				for dx in range(3+cluster%3):
					var x: int = cx+dx
					var y: int = cy+dy
					if x < 64 and absf((x+0.5-32)/32.0)+absf((y+0.5-16)/16.0) < 0.92:
						image.set_pixel(tile*64+x,y,Color("304a3a") if cluster%3 else Color("22392f"))
	DirAccess.make_dir_recursive_absolute("res://assets/tiles/briarwood")
	image.save_png("res://assets/tiles/briarwood/forest.png")
	var tiles := TileSet.new()
	tiles.tile_size = Vector2i(64,32)
	tiles.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	tiles.tile_layout = TileSet.TILE_LAYOUT_DIAMOND_DOWN
	var atlas := TileSetAtlasSource.new()
	atlas.texture = ImageTexture.create_from_image(image)
	atlas.texture_region_size = Vector2i(64,32)
	tiles.add_source(atlas,0)
	for i in range(6): atlas.create_tile(Vector2i(i,0))
	quit(0 if ResourceSaver.save(tiles,"res://assets/tiles/briarwood/forest.tres") == OK else 1)
