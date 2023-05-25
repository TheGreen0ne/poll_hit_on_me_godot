extends Node

const GALLERY_ITEM_SCENE = preload("res://src/scenes/gallery_item.tscn")

@export_node_path var gallery_item_parent_path := ^"../ScrollContainer/gallery"

@onready var _gallery_item_parent := get_node(gallery_item_parent_path) as Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Config.poll_command.is_empty():
		return
	var output: Array[String] = []
	var ret_code := OS.execute(
			Config.poll_command[0],
			Config.poll_command.slice(1),
			output,
			true
	)
	if ret_code:
		print_debug(output[0])
		print_debug("program executed with return code {0}".format([ret_code]))
		breakpoint
		return
#	print(output)
	var lines = output[0].strip_edges().split("\n")
#	print(lines)
	for line in lines:
		var gallery_data: Dictionary
		if line.begins_with("{"):
			gallery_data = JSON.parse_string(line) as Dictionary
		else:
#			print('"{0}" is no valid JSON object'.format([line]))
			gallery_data = {"text": line}
		_create_gallery(gallery_data)


func _create_gallery(gallery_dict: Dictionary) -> void:
	if "image" in gallery_dict:
		var gal_item := GALLERY_ITEM_SCENE.instantiate()
		gal_item.image_path = gallery_dict["image"]
		gal_item.label_text = gallery_dict["text"]
		_gallery_item_parent.add_child(gal_item)
	else:
		var lbl := Label.new()
		lbl.text = gallery_dict["text"]
		_gallery_item_parent.add_child(lbl)
