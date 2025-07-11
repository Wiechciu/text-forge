extends ActionScript

func _run_action() -> void:
	var popup: Window = load("res://action_scripts/scenes/about.tscn").instantiate()
	add_child(popup)
	popup.close_requested.connect(func(): popup.queue_free())
