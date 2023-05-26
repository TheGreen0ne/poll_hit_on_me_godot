class_name DownscalingTextureRect
extends TextureRect

@onready
var scroll_container: ScrollContainer = find_parent("ScrollContainer")


# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().size_changed.connect(_on_resized)
#	scroll_container.ready.connect(_on_resized, CONNECT_ONE_SHOT)
#	print(get_node(^"../..").get_path())
#	self.resized.connect(_on_resized)
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
#	var parent_width := find_parent("ScrollContainer").get_parent_area_size().x
	var parent_width := scroll_container.get_rect().size.x
#	assert(get_parent_control().get_rect().size.x == parent_width)
#	print("%s texture width: %s container width: %s" % [get_parent().name, tex_width, parent_width])
	if parent_width > tex_width:
		expand_mode = TextureRect.EXPAND_KEEP_SIZE
	else:
		expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
#		expand_mode = TextureRect.EXPAND_KEEP_SIZE
#		scale = Vector2(parent_width/tex_width, parent_width/tex_width)

func _on_resized() -> void:
	update_expand()
