extends ActionScript

var popup: Window = load("res://scripts/script_scenes/color_picker.tscn").instantiate()

func _run_action() -> void:
	if not popup.get_parent():
		add_child(popup)
		popup.get_child(1).resized.connect(func(): popup.size = popup.get_child(1).size)
	popup.show()
