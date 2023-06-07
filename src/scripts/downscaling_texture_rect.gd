class_name DownscalingTextureRect
extends TextureRect

@onready
var scroll_container: ScrollContainer = NodeUtils.find_parent_of_class(self, ScrollContainer)


# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().size_changed.connect(_on_resized)
	update_expand()

func _set(property: StringName, value) -> bool:
	if property == "texture":
		texture = value
		update_expand()
		return true
	return false

func update_expand() -> void:
	if texture == null or not is_inside_tree():
		return
	var tex_width := texture.get_width()
	var container_width := (
			scroll_container.size.x
			if scroll_container != null
			else INF
	)
	if container_width > tex_width:
		expand_mode = TextureRect.EXPAND_KEEP_SIZE
	else:
		expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL

func _on_resized() -> void:
	update_expand()
