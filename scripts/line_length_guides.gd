extends ActionScript

var popup: Window

func _ready() -> void:
	_load_shortcut()
	Global.get_editor().line_length_guidelines = Settings.get_setting("editor_ui", "line_length_guides", [100, 80])

func _run_action() -> void:
	popup = load("res://scripts/script_scenes/line_length_guides.tscn").instantiate()
	popup.close_requested.connect(_save_config)
	popup.input.text = ", ".join(Settings.get_setting("editor_ui", "line_length_guides", [100, 80]).map(func(line): return str(line)))
	add_child(popup)

func _save_config() -> void:
	Settings.set_setting("editor_ui", "line_length_guides", Array(popup.input.text.split(",")).map(func(line): return int(line)).filter(func(line): return line != 0))
	popup.queue_free()
	Global.get_editor().line_length_guidelines = Settings.get_setting("editor_ui", "line_length_guides", [100, 80])
