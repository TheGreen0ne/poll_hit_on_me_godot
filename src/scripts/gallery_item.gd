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
		# Workaround for Godot #69282; calling static function from within a class generates a warning
		# https://github.com/godotengine/godot/issues/69282
		@warning_ignore("static_called_on_instance")
		tex = await ImageUtils.load_image_texture_from_url(image_path)
	else:
		# Workaround for Godot #69282; calling static function from within a class generates a warning
		# https://github.com/godotengine/godot/issues/69282
		@warning_ignore("static_called_on_instance")
		image_path = FileUtils.expand_home(image_path)
		# Workaround for Godot #69282; calling static function from within a class generates a warning
		# https://github.com/godotengine/godot/issues/69282
		@warning_ignore("static_called_on_instance")
		tex = ImageUtils.load_image_texture_from_path(image_path)
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
