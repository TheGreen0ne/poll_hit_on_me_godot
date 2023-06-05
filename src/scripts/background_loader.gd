extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Config.background_file:
		var tex := ImageUtils.load_image_texture_from_path(Config.background_file)
		if tex == null:
			breakpoint
			return
		get_parent().texture = tex
