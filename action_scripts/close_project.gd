extends ActionScript

func _check_option_extra() -> bool:
	return Project.current_project.has_section("project")

func _run_action() -> void:
	Project.close_project()
