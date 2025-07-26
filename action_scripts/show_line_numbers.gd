extends CheckableActionScript

func _setup() -> void:
	settings_section = "editor_ui"
	settings_key = "show_line_numbers"
	default = true

func _set_value(to: bool) -> void:
	Global.get_editor().gutters_draw_line_numbers = to

func _get_value() -> bool:
	return Global.get_editor().gutters_draw_line_numbers
