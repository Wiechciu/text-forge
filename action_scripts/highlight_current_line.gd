extends ActionScript

func _initialize() -> void:
	Settings.define_preset("editor_ui", "highlight_current_line", true)
	Signals.settings_changed.connect(_load_config)
	_load_config()

func _run_action() -> void:
	Settings.set_setting("editor_ui", "highlight_current_line", not Global.get_editor().highlight_current_line)
	Global.get_editor().highlight_current_line = not Global.get_editor().highlight_current_line

func _load_config() -> void:
	Global.get_editor().highlight_current_line = Settings.get_setting("editor_ui", "highlight_current_line", true)
	menu.set_item_checked(menu.get_item_index(id), Global.get_editor().highlight_current_line)
