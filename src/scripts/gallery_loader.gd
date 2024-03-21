extends Node

const GALLERY_ITEM_SCN = preload("res://src/scenes/gallery_item.tscn")
const GALLERY_ITEM_LBL_SCN = preload("res://src/scenes/gallery_item_label.tscn")
const GALLERY_TAB_SCN = preload("res://src/scenes/gallery_tab.tscn")
const GalleryItem = preload("res://src/scripts/gallery_item.gd")

@export_node_path var gallery_item_parent_path := ^"%content_tab/gallery/%gallery_items"
@export_node_path var loading_animation_path := ^"%loading_container"

@onready var _gallery_item_parent := get_node(gallery_item_parent_path) as Container
@onready var _loading_animation := get_node(loading_animation_path) as Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Config.poll_command.is_empty():
		return
	load_gallery()


func create_gallery_item_details(gal_item: GalleryItem) -> void:
	var tab_container: TabContainer = %content_tab
	var tab_bar := tab_container.get_child(0, true) as TabBar
	if tab_bar == null:
		print_debug("something went wrong")
		breakpoint
		return

	# setup tab bar
	if tab_bar.tab_close_display_policy == TabBar.CLOSE_BUTTON_SHOW_NEVER:
		tab_bar.tab_close_display_policy = TabBar.CLOSE_BUTTON_SHOW_ACTIVE_ONLY
		tab_bar.tab_close_pressed.connect(_free_tab.bind(tab_container))

		# tested with default window width to fit exactly 3 additional tabs
		# when scroll buttons are showed
		tab_bar.max_tab_width = 148

	var tab := GALLERY_TAB_SCN.instantiate()
	var title := (
			gal_item.data_dict["name"] as String
			if "name" in gal_item.data_dict
			else "?"
	)
	tab.name = title
	var tab_idx := tab_container.get_tab_count()
	tab_container.add_child(tab, true)
	tab_bar.set_tab_title(tab_idx, title)
	tab_container.current_tab = tab_idx
	
	var items := tab.get_node("%gallery_items") as Container

	var command := Config.details_command.duplicate()
	for i in len(command):
		command[i] = command[i].format(gal_item.data_dict)
		if "{" in command[i]:
			print('could not substitute "{0}" in details_command'.format(
				[command[i]]
			))
			breakpoint
			command.clear()

			var l := Label.new()
			l.text = "error loading details"
			items.add_child(l)
			return
	
	load_gallery_tab(command, items)


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
	if ret_code:
		print_debug(output[0])
		print_debug("program executed with return code {0}".format([ret_code]))
		breakpoint
	return output[0].strip_edges().split("\n")


func load_gallery() -> void:
	load_gallery_tab(Config.poll_command, _gallery_item_parent)


func load_gallery_tab(command: PackedStringArray, tab: Container) -> void:
	#region loading animation
	var loading_anim_parent := Node2D.new()
	tab.add_child(loading_anim_parent)
	var tab_loading_animation = _loading_animation.duplicate() as Control
	loading_anim_parent.add_child(tab_loading_animation)
	tab_loading_animation.show()
	tab_loading_animation.process_mode = Node.PROCESS_MODE_INHERIT

	#region animation size
	tab_loading_animation.set_anchors_preset(Control.PRESET_TOP_LEFT)
	var first_tab := %content_tab.get_child(0) as Control
	if first_tab != null and first_tab.size > Vector2.ONE:
		tab_loading_animation.size = first_tab.size
	else:
		tab_loading_animation.size = %content_tab.size
	#endregion
	#endregion

	var _loader_thread := Thread.new()
	var fun = get_process_output_lines.bind(command, true)
	_loader_thread.start(fun)
	while _loader_thread.is_alive():
		await get_tree().create_timer(0.1).timeout
	var lines = _loader_thread.wait_to_finish()
	
	loading_anim_parent.queue_free()

#	print(lines)
	for line in lines:
		var gallery_data: Dictionary
		if line.begins_with("{"):
			gallery_data = JSON.parse_string(line) as Dictionary
		else:
#			print('"{0}" is no valid JSON object'.format([line]))
			gallery_data = {"text": line}
		_create_gallery_item(gallery_data, tab)


func _create_gallery_item(gallery_dict: Dictionary, parent: Container) -> void:
	if "text" in gallery_dict:
		gallery_dict["text"] = StringUtils.apply_cr(gallery_dict["text"])
	if "image" in gallery_dict:
		var gal_item := GALLERY_ITEM_SCN.instantiate()
		gal_item.image_path = gallery_dict["image"]
		gal_item.label_text = gallery_dict["text"]
		gal_item.data_dict = gallery_dict
		parent.add_child(gal_item)
		if parent == _gallery_item_parent:
			gal_item.gui_input.connect(_gallery_gui_input.bind(gal_item))
	else:
		var lbl := GALLERY_ITEM_LBL_SCN.instantiate()
		lbl.text = gallery_dict["text"]
		parent.add_child(lbl)


static func _free_tab(idx: int, container: TabContainer) -> void:
	container.get_tab_control(idx).queue_free()


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
