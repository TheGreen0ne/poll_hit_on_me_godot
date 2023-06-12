extends Node

@export var config_save_path := "user://config.json"

var background_file := ""
var poll_command := PackedStringArray([])
var details_command := PackedStringArray([])

func _enter_tree() -> void:
	load_config()


## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass # Replace with function body.


func load_config() -> void:
	var save_file := _open_config_file()
	if save_file == null:
		return
	var save_data := JSON.parse_string(save_file.get_as_text()) as Dictionary
	save_file = null # close and destuct
	if save_data == null:
		print_debug("config file is invalid")
		breakpoint
		return

	if "poll_command" in save_data:
		var mb_poll_command := _sanitize_command(save_data["poll_command"])

		if mb_poll_command.is_empty():
			print("malformed config \"poll_command\"")
			breakpoint
		else:
			poll_command = PackedStringArray(mb_poll_command)
	if "details_command" in save_data:
		var mb_details_command := _sanitize_command(save_data["details_command"])

		if mb_details_command.is_empty():
			print("malformed config \"details_command\"")
			breakpoint
		else:
			details_command = PackedStringArray(mb_details_command)
	if "window_pos" in save_data:
		var mb_window_pos = save_data["window_pos"]
		if (mb_window_pos is Array
				and len(mb_window_pos) == 2
				and mb_window_pos[0] is float
				and mb_window_pos[1] is float
		):
			var pos = Vector2i(mb_window_pos[0], mb_window_pos[1])
			DisplayServer.window_set_position(pos)
		else:
			print_debug('config window_pos "', mb_window_pos, '" is invalid')
	if "background_file" in save_data:
		var mb_bg_file = save_data["background_file"]
		if mb_bg_file is String and FileAccess.file_exists(mb_bg_file):
			background_file = mb_bg_file
		else:
			print_debug('could not find background at "{0}"'.format(
				[mb_bg_file]
			))


func _create_default_config_file() -> void:
	print("creating default config file...")
	var save_data := {
		"window_pos":[0,0],
		"poll_command": poll_command,
		"details_command": details_command,
		"background_file": background_file,
	}
	var save_file := FileAccess.open(config_save_path, FileAccess.WRITE)
	if save_file == null:
		print_debug(
				"could not create default config file, ERR=", 
				FileAccess.get_open_error()
		)
		return
	var save_str := JSON.stringify(save_data)
	save_file.store_line(save_str)
	print("default config file created.")
	print("please configure in file \"{0}\"".format(
			[ProjectSettings.globalize_path(config_save_path)]
	))


func _open_config_file() -> FileAccess:
	var save_file := FileAccess.open(config_save_path, FileAccess.READ)
	if save_file == null:
		var err := FileAccess.get_open_error()
		if err == ERR_FILE_NOT_FOUND:
			print("config file not found")
			_create_default_config_file()
		else:
			print_debug(err)
	return save_file


func _sanitize_command(command) -> Array:
	if command is Array:
		for s in command:
			if not s is String:
				command = []
				break
			# filter quote injection
			if '"' in s:
				command = []
				break
			# filter subshell injection
			if "$" in s:
				command = []
				break
	else:
		command = []
	return command
