extends ActionScript

func _run_action() -> void:
	add_child(load("res://scripts/script_scenes/mode_manager.tscn").instantiate())
