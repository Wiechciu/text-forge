extends ActionScript

func _ready() -> void:
	Signals.settings_changed.connect(_load_config)
	_load_shortcut()
	_load_config()

func _run_action() -> void:
	Settings.set_setting("window", "fullscreen", menu.is_item_checked(menu.get_item_index(id)))
	_load_config()

func _load_config() -> void:
	if Settings.get_setting("window", "fullscreen", false):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	menu.set_item_checked(menu.get_item_index(id), Settings.get_setting("window", "fullscreen", false))
