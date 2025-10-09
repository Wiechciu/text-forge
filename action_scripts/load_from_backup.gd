extends WindowActionScript

func _initialize() -> void:
	window_scene = "res://action_scripts/scenes/backups.tscn"


func _check_option_extra() -> bool:
	if DirAccess.dir_exists_absolute(S.globalize_path(S.FOLDER_BACKUPS)):
		return DirAccess.get_files_at(S.globalize_path(S.FOLDER_BACKUPS)).size() > 0
	return false
