extends ActionScript

func _ready() -> void:
	Signals.settings_changed.connect(_load_config)
	_load_shortcut()
	_load_shortcut()

func _run_action() -> void:
	Settings.set_setting("editor_ui", "show_bookmarks", not Global.get_editor().gutters_draw_bookmarks)
	Global.get_editor().gutters_draw_bookmarks = not Global.get_editor().gutters_draw_bookmarks

func _load_config() -> void:
	Global.get_editor().gutters_draw_bookmarks = Settings.get_setting("editor_ui", "show_bookmarks", true)
	menu.set_item_checked(menu.get_item_index(id), Global.get_editor().gutters_draw_bookmarks)
