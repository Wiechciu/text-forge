extends ActionScript

func _run_action() -> void:
	add_child(load("res://scripts/script_scenes/command_pallete.tscn").instantiate())
