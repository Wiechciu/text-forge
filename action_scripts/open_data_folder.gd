extends ActionScript

func _run_action() -> void:
	OS.shell_open(S.globalize_path("user://"))
