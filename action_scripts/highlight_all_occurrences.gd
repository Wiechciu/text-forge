extends ActionScript

func _initialize() -> void:
	Settings.define_preset("editor_ui", "highlight_all_occurrences", true)
	Signals.settings_changed.connect(_load_config)
	_load_config()

func _run_action() -> void:
	Settings.set_setting("editor_ui", "highlight_all_occurrences", not Global.get_editor().highlight_all_occurrences)
	Global.get_editor().highlight_all_occurrences = not Global.get_editor().highlight_all_occurrences

func _load_config() -> void:
	Global.get_editor().highlight_all_occurrences = Settings.get_setting("editor_ui", "highlight_all_occurrences", true)
	menu.set_item_checked(menu.get_item_index(id), Global.get_editor().highlight_all_occurrences)
