extends ActionScript

func _initialize() -> void:
	requires_file = true


func _run_action() -> void:
	var last_caret_count = Global.get_editor().get_caret_count()
	while true:
		Global.get_editor().add_selection_for_next_occurrence()
		if Global.get_editor().get_caret_count() == last_caret_count:
			break
		last_caret_count = Global.get_editor().get_caret_count()
