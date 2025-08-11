extends ActionScript

func _initialize() -> void:
	requires_file = true
	requires_saved_file = true


func _check_option_extra() -> bool:
	return Global.get_editor_api().is_auto_indent_available()


func _run_action() -> void:
	Global.get_editor_api().auto_indent()
	Global.get_editor().text_changed.emit()
