extends ActionScript

func _check_option_extra() -> bool:
	if FileAccess.file_exists(SLib.globalize_path(FileDatabase.BACKUP_DATABASE)) \
		and DirAccess.dir_exists_absolute(SLib.globalize_path(FileDatabase.TEMPLATE_BACKUP_FILE.get_base_dir())):
			var config := ConfigFile.new()
			config.load(SLib.globalize_path(FileDatabase.BACKUP_DATABASE))
			if config.has_section("backups"):
				return true
			if DirAccess.get_files_at(SLib.globalize_path(FileDatabase.TEMPLATE_BACKUP_FILE.get_base_dir())).size():
				return true
	return false


func _run_action() -> void:
	add_child(Global.gload("res://action_scripts/scenes/backups.tscn").instantiate())
