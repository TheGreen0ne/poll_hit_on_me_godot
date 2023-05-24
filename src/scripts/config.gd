extends Node

@export var config_save_path := "user://config.json"

var poll_command := PackedStringArray([])

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
		var mb_poll_command = save_data["poll_command"]
		if mb_poll_command is Array:
			for s in mb_poll_command:
				if not s is String:
					mb_poll_command = null
					break
		else:
			mb_poll_command = null
		if mb_poll_command == null:
			print("malformed config \"poll_command\"")
			breakpoint
		else:
			poll_command = PackedStringArray(mb_poll_command)
	


func _create_default_config_file() -> void:
	print("creating default config file...")
	var save_data := {
		"poll_command": poll_command
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
