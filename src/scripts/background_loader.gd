extends Node


const GalleryItem = preload("res://src/scripts/gallery_item.gd")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Config.background_file:
		var tex := GalleryItem.load_image_texture_from_path(Config.background_file)
		if tex == null:
			breakpoint
			return
		get_parent().texture = tex
