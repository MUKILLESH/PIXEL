extends SceneTree
## Six original 64x32 tiles; deterministic texture, no downloaded art.
func _initialize() -> void:
	var image := Image.create(384,32,false,Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var colors: Array[Color] = [Color("344f47"),Color("38554a"),Color("314d46"),Color("788088"),Color("727b84"),Color("7d858a")]
	for tile in range(6):
		for y in range(32):
			for x in range(64):
				var distance: float = absf((x+0.5-32)/32.0)+absf((y+0.5-16)/16.0)
				if distance > 1.0:
					continue
				var color: Color = colors[tile]
				var grain: int = posmod((x*374761393+y*668265263+tile*1274126177) ^ ((x+3)*(y+7)*127),997)
				if tile < 3:
					if grain < 18:
						color = Color("4a6552")
					elif grain > 981:
						color = Color("29453f")
				else:
					if distance > 0.96:
						color = Color("56666e")
					elif distance > 0.91 and y < 16:
						color = color.lightened(0.09)
					elif grain < 4:
						color = color.lightened(0.035)
					# Occasional inset stone seams without a heavy grid on grass.
					if tile == 4 and absf(x-32.0) < 0.7:
						color = Color("64727a")
				image.set_pixel(tile*64+x,y,color)
	image.save_png("res://assets/tiles/courtyard.png")
	var tiles := TileSet.new()
	tiles.tile_size = Vector2i(64,32)
	tiles.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	tiles.tile_layout = TileSet.TILE_LAYOUT_DIAMOND_DOWN
	var atlas := TileSetAtlasSource.new()
	atlas.texture = ImageTexture.create_from_image(image)
	atlas.texture_region_size = Vector2i(64,32)
	tiles.add_source(atlas,0)
	for i in range(6):
		atlas.create_tile(Vector2i(i,0))
	quit(0 if ResourceSaver.save(tiles,"res://assets/tiles/courtyard.tres") == OK else 1)
