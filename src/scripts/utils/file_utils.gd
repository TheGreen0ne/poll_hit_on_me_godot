class_name FileUtils
extends RefCounted


## expand home path
## e.g. ~/.local -> /home/user/.local
##   or ~/Appdata -> C:/Users/User/Appdata
static func expand_home(path: String) -> String:
	if path.begins_with("~/"):
		var home_path := ""
		match OS.get_name():
			"Linux":
				home_path = OS.get_environment("HOME")
			"Windows":
				home_path = OS.get_environment("USERPROFILE")
			_:
				home_path = OS.get_environment("HOME")
				if home_path == "":
					home_path = OS.get_environment("USERPROFILE")
		if home_path == "":
			home_path = "/".join(ProjectSettings.globalize_path("user://a").split("/").slice(0,3))
		path = home_path.path_join(path.trim_prefix("~"))
	return path
