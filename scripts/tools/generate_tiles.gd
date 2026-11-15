extends SceneTree
## Six original 64x32 medieval isometric tiles (night meadow grass and weathered cobblestones).
func _initialize() -> void:
	var image := Image.create(384,32,false,Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var colors: Array[Color] = [
		Color("283d32"),Color("2c4336"),Color("25392e"),
		Color("5e5852"),Color("665f58"),Color("57514b")
	]
	for tile in range(6):
		for y in range(32):
			for x in range(64):
				var distance: float = absf((x+0.5-32)/32.0)+absf((y+0.5-16)/16.0)
				if distance > 1.0:
					continue
				var color: Color = colors[tile]
				var grain: int = posmod((x*374761393+y*668265263+tile*1274126177) ^ ((x+3)*(y+7)*127),997)
				if tile < 3:
					# Night-lit meadow grass with moss & clover speckles
					if grain < 24:
						color = Color("3d5a45")
					elif grain < 38 and (x + y) % 3 == 0:
						color = Color("4a684e")
					elif grain > 970:
						color = Color("1d2e25")
				else:
					# Weathered cobblestone paving with subtle mortar seams & highlights
					var iso_u: int = int((x + y * 2) / 14)
					var iso_v: int = int((x - y * 2 + 64) / 14)
					var seam_u: bool = posmod(x + y * 2, 14) == 0
					var seam_v: bool = posmod(x - y * 2 + 64, 14) == 0
					if distance > 0.96:
						color = Color("433e39")
					elif seam_u or seam_v:
						color = Color("433e39")
					elif posmod(x + y * 2, 14) == 1 and posmod(iso_u + iso_v + tile, 2) == 0:
						color = Color("786f65")
					elif grain < 18:
						color = Color("786f65")
					elif grain > 978:
						color = Color("4b453f")
					elif tile == 4 and absf(x-32.0) < 0.7:
						color = Color("433e39")
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
