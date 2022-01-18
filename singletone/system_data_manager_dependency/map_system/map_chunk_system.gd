extends Node

var threads:Array = []
var mutex:Mutex   = Mutex.new()


var counter:int     = 0
var tile_made:int   = 0


# load the image
func load_image(image_path:String)->Image:
	var new_image:Image = Image.new()
	var _error:int = new_image.load(image_path)

	return new_image

# === Depricated === 

# get the number of chunk
func get_chunk_count(image_size:Vector2, chunk_size:Vector2)->int:
	var image_rect:int = Rect2(Vector2(0,0), image_size).get_area()
	var chunk_rect:int = Rect2(Vector2(0,0), chunk_size).get_area()
	
	var chunk_count:int = round(image_rect/chunk_rect)
	
	return chunk_count


# slice the texture into tile set
func slice_texture(texture_path:String, chunk_size:Vector2 = Vector2(512, 288))->TileSet:
	var image:Image           = load_image(texture_path)
	
	var chunk_count:float     = get_chunk_count(image.get_size(), chunk_size)
	var image_dimension:float = sqrt(chunk_count)
	var tile_set              = TileSet.new()

	counter                   = 0
	for current_layer in range(image_dimension):
		for x in range(image_dimension):
			var t = Thread.new()
			threads.append(t)
			t.start(
				self,
				"generate_tile",
				[
					image.duplicate(),
					chunk_size,
					x,
					current_layer,
					image_dimension,
					tile_set
				]
			)

	while true:
		if (tile_made == chunk_count):
			break

	return tile_set


func generate_tile(arg):
	mutex.lock()
	var image_slice:ImageTexture = generate_texture(arg[0], arg[1], arg[2], arg[3])
	make_tile(arg[5], ((arg[4] * arg[3]) + arg[2]), image_slice)
	tile_made += 1
	mutex.unlock()


# genereate and save map fragments
func generate_texture(image:Image, chunk_size:Vector2, index_x:int, index_y:int)->ImageTexture:

	# genrate position
	var position:Vector2 = Vector2(
				chunk_size.x * index_x,
				chunk_size.y * index_y
			)

	# create new image form slice
	var new_image:Image = Image.new()
	new_image.create(round(chunk_size.x), round(chunk_size.y), false, image.get_format())
	new_image.blit_rect(
			image,
			Rect2(
				position,
				chunk_size
			),
			Vector2(0,0)
	)
	var _i = new_image.generate_mipmaps()

	# generate image texture for tiles
	var image_fragment:ImageTexture = ImageTexture.new()
	image_fragment.create_from_image(new_image, 1)

	return image_fragment


func make_tile(tile_:TileSet, tile_counter:int, image_texture:ImageTexture)->void:
	tile_.create_tile(tile_counter)
	tile_.tile_set_name(tile_counter, "map_tile_" + str(tile_counter))
	tile_.tile_set_texture(tile_counter, image_texture)


func _exit_tree():
	for x in threads:
		x.wait_to_finish()
