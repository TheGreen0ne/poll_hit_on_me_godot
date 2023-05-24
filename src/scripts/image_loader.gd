extends Node

@export_file("*.png")
var texture_file: String = "~/workspace/ui_fph/graphic/1280x720/fph_bon_enter.png"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if texture_file.begins_with("~/"):
		var home_path := OS.get_environment("HOME")
		if home_path == "":
			home_path = OS.get_environment("USERPROFILE")
		if home_path == "":
			home_path = "/".join(ProjectSettings.globalize_path("user://a").split("/").slice(0,3))
		texture_file = home_path.path_join(texture_file.trim_prefix("~"))
	if not FileAccess.file_exists(texture_file):
		print("background not found")
		return
	var buffer := FileAccess.get_file_as_bytes(texture_file)
	if buffer.is_empty():
		print("background is an empty file")
		return
#	print("file size: ", buffer.size())
	var img := Image.new()
	img.load_png_from_buffer(buffer)
#	print("img size: ", img.get_size())
	var tex := ImageTexture.create_from_image(img)
	if tex == null:
		breakpoint
		return
	get_parent().texture = tex
