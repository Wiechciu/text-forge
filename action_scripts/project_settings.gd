extends WindowActionScript

func _check_option_extra() -> bool:
	if Project.current_project:
		return Project.current_project.has_section_key("project", "name")
	return false


func _initialize() -> void:
	window_scene = "res://action_scripts/scenes/project_settings.tscn"
