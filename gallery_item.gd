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
	image_path = expand_home(image_path)
	var tex := load_image_texture_from_path(image_path)
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

## load a PNG file from the filesystem and create an ImageTexture from it
static func load_image_texture_from_path(path: String) -> ImageTexture:
	if not FileAccess.file_exists(path):
		print("image not found")
		return
	var buffer := FileAccess.get_file_as_bytes(path)
	var err = FileAccess.get_open_error()
	if err:
		print_debug(err)
#	print("file size: ", buffer.size())
	var img := Image.new()
	
	# TODO support other than PNG
	img.load_png_from_buffer(buffer)
	
	
#	print("img size: ", img.get_size())
	var tex := ImageTexture.create_from_image(img)
	if tex == null:
		breakpoint
	return tex
