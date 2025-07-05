extends ActionScript

var window: Window

func _run_action() -> void:
	window = load("res://scripts/script_scenes/preferences.tscn").instantiate()
	add_child(window)
