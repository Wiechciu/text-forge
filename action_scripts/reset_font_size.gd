extends ActionScript

func _ready() -> void:
	Signals.settings_changed.connect(_load_config)
	_load_shortcut()
	_load_config()

func _run_action() -> void:
	Global.get_editor().add_theme_font_size_override("font_size", 16)
	Settings.set_setting("editor_ui", "font_size", 16)

func _load_config() -> void:
	Global.get_editor().add_theme_font_size_override("font_size", Settings.get_setting("editor_ui", "font_size", 16))
