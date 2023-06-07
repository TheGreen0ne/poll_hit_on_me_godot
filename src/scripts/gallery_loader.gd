extends Node

const GALLERY_ITEM_SCN = preload("res://src/scenes/gallery_item.tscn")
const GALLERY_ITEM_LBL_SCN = preload("res://src/scenes/gallery_item_label.tscn")
const GalleryItem = preload("res://src/scripts/gallery_item.gd")

@export_node_path var gallery_item_parent_path := ^"../ScrollContainer/gallery"
@export_node_path var loading_animation_path := ^"../loading_container"

@onready var _gallery_item_parent := get_node(gallery_item_parent_path) as Node
@onready var _loading_animation := get_node(loading_animation_path) as CanvasItem


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Config.poll_command.is_empty():
		return
	load_gallery()


func create_gallery_item_details(gal_item:GalleryItem) -> void:
	var vbox := VBoxContainer.new()
	vbox.name = gal_item.data_dict["text"] # not text
	_gallery_item_parent.get_parent().add_child(vbox, true)
	# TODO


static func get_process_output_lines(
		args: PackedStringArray, 
		read_stderr: bool = false
) -> PackedStringArray:
	var output: Array[String] = []
	var ret_code := OS.execute(
			args[0],
			args.slice(1),
			output,
			read_stderr
	)
#	print(output)
	if ret_code:
		print_debug(output[0])
		print_debug("program executed with return code {0}".format([ret_code]))
		breakpoint
		return []
	return output[0].strip_edges().split("\n")


func load_gallery() -> void:
	_loading_animation.show()
	var _loader_thread := Thread.new()
	var fun = get_process_output_lines.bind(Config.poll_command)
	_loader_thread.start(fun)
	while _loader_thread.is_alive():
		await get_tree().create_timer(0.1).timeout
	var lines = _loader_thread.wait_to_finish()
	_loading_animation.hide()

#	print(lines)
	for line in lines:
		var gallery_data: Dictionary
		if line.begins_with("{"):
			gallery_data = JSON.parse_string(line) as Dictionary
		else:
#			print('"{0}" is no valid JSON object'.format([line]))
			gallery_data = {"text": line}
		_create_gallery_item(gallery_data)


func _create_gallery_item(gallery_dict: Dictionary) -> void:
	if "text" in gallery_dict:
		gallery_dict["text"] = StringUtils.apply_cr(gallery_dict["text"])
	if "image" in gallery_dict:
		var gal_item := GALLERY_ITEM_SCN.instantiate()
		gal_item.image_path = gallery_dict["image"]
		gal_item.label_text = gallery_dict["text"]
		gal_item.data_dict = gallery_dict
		_gallery_item_parent.add_child(gal_item)
		gal_item.gui_input.connect(Callable(_gallery_gui_input).bind(gal_item))
	else:
		var lbl := GALLERY_ITEM_LBL_SCN.instantiate()
		lbl.text = gallery_dict["text"]
		_gallery_item_parent.add_child(lbl)


func _gallery_gui_input(event:InputEvent, gal_item: GalleryItem) -> void:
	if not event is InputEventMouseButton:
		return
	if event.is_pressed():
		return

	var button_event := event as InputEventMouseButton
	if button_event.button_index != MOUSE_BUTTON_LEFT:
		return
	if (
			button_event.position.x < 0.0
			or button_event.position.y < 0.0
			or button_event.position.x > gal_item.size.x
			or button_event.position.y > gal_item.size.y
	):
		return

	create_gallery_item_details(gal_item)
