extends ActionScript

func _run_action() -> void:
	add_child(Global.gload("res://action_scripts/scenes/mode_manager.tscn").instantiate())
