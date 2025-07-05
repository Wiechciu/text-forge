extends ActionScript

func _ready() -> void:
	_load_shortcut()
	if Settings.get_setting("window", "fullscreen", false):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	menu.set_item_checked(menu.get_item_index(id), Settings.get_setting("window", "fullscreen", false))

func _run_action() -> void:
	Settings.set_setting("window", "fullscreen", menu.is_item_checked(menu.get_item_index(id)))
	if Settings.get_setting("window", "fullscreen", false):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
