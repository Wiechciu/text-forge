extends ActionScript

func _initialize() -> void:
	need_file = true

func _run_action() -> void:
	DisplayServer.clipboard_set(Global.get_file_path())
