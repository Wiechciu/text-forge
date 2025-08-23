extends TextureRect

@export var hide_timer: Timer

func _ready() -> void:
	BackupCore.backup_saved.connect(_on_backup_saved)
	BackupCore.backup_failed.connect(_on_backup_failed)
	hide_timer.timeout.connect(SLib.play_animation.bind(SLib.Animations.FADE_OUT, self))


func _on_backup_saved(was_auto: bool) -> void:
	show()
	texture = load("res://assets/backup.png")
	var tooltip := "Backup Status"
	if was_auto:
		tooltip += "\nAuto backup saved: " + Time.get_datetime_string_from_system(false, true)
	else:
		tooltip += "\nManual backup saved: " + Time.get_datetime_string_from_system(false, true)
	tooltip_text = tooltip
	show()
	hide_timer.start()


func _on_backup_failed(was_auto: bool) -> void:
	texture = load("res://assets/backup_fail.png")
	var tooltip := "Backup Status"
	if was_auto:
		tooltip += "\nAuto backup failed: " + Time.get_datetime_string_from_system(false, true)
	else:
		tooltip += "\nManual backup failed: " + Time.get_datetime_string_from_system(false, true)
	tooltip_text = tooltip
	show()
	hide_timer.start()
