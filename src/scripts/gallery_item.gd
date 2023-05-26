extends VBoxContainer
## a Gallery Item
## needs to be unter a ScrollContainer named ScrollContainer

## path to the image file on the user's filesystem
@export_file("*.png")
var image_path := ""
## text to be shown in the label
@export
var label_text := ""


func _enter_tree() -> void:
	var tex: ImageTexture
	if image_path.begins_with("http"):
		tex = await load_image_texture_from_url(image_path)
	else:
		image_path = expand_home(image_path)
		tex = load_image_texture_from_path(image_path)
	if tex == null:
		print_debug('could not load texture from "{0}"'.format([image_path]))
		$gallery_image.queue_free()
		remove_child($gallery_image)
	else:
		$gallery_image.texture = tex
	
	$label.text = label_text


## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


## expand home path
## e.g. ~/.local -> /home/user/.local
##   or ~/Appdata -> C:/Users/User/Appdata
static func expand_home(path: String) -> String:
	if path.begins_with("~/"):
		var home_path := ""
		match OS.get_name():
			"Linux":
				home_path = OS.get_environment("HOME")
			"Windows":
				home_path = OS.get_environment("USERPROFILE")
			_:
				home_path = OS.get_environment("HOME")
				if home_path == "":
					home_path = OS.get_environment("USERPROFILE")
		if home_path == "":
			home_path = "/".join(ProjectSettings.globalize_path("user://a").split("/").slice(0,3))
		path = home_path.path_join(path.trim_prefix("~"))
	return path


static func load_image_texture_from_bytes(buffer: PackedByteArray) -> ImageTexture:
	var img := Image.new()
	
	# TODO support other than PNG
	img.load_png_from_buffer(buffer)
	
	
#	print("img size: ", img.get_size())
	var tex := ImageTexture.create_from_image(img)
	if tex == null:
		breakpoint
	return tex


## load a PNG file from the filesystem and create an ImageTexture from it
static func load_image_texture_from_path(path: String) -> ImageTexture:
	if not FileAccess.file_exists(path):
		print("image not found")
		return
	var buffer := FileAccess.get_file_as_bytes(path)
	if buffer.is_empty():
		print("image is an empty file")
		return
#	print("file size: ", buffer.size())
	return load_image_texture_from_bytes(buffer)


## load a PNG file from an url and create an ImageTexture from it
static func load_image_texture_from_url(url: String) -> ImageTexture:
	var headers = [
		"User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/113.0"
	]
	var resp := await Requests.get_req(url, headers)
	return load_image_texture_from_bytes(resp.body)
