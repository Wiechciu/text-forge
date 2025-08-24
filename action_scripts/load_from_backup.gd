extends ActionScript

func _check_option_extra() -> bool:
	if DirAccess.dir_exists_absolute(SLib.globalize_path(FileDatabase.FOLDER_BACKUPS)):
		return DirAccess.get_files_at(SLib.globalize_path(FileDatabase.FOLDER_BACKUPS)).size() > 0
	return false


func _run_action() -> void:
	add_child(Global.load_resource("res://action_scripts/scenes/backups.tscn").instantiate())
