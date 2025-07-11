extends Node
class_name SettingsAPI

const SETTINGS_FILE := "user://data.cfg"
const OPTIONS_FILE := "user://options.cfg"

func get_setting(section: String, key: String, default: Variant = null) -> Variant:
	if default == null:
		default = get_default(section, key)
	if not FileAccess.file_exists(SETTINGS_FILE):
		return default
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_FILE)
	if err:
		Global.send_notification(2, "Can't load settings file!", "Error code: " + str(err))
		return default
	return config.get_value(section, key, default)


func restore_default(section: String, key: String) -> void:
	set_setting(section, key, get_default(section, key))


func set_setting(section: String, key: String, value: Variant = null) -> void:
	var config = ConfigFile.new()
	if FileAccess.file_exists(SETTINGS_FILE):
		config.load(SETTINGS_FILE)
	config.set_value(section, key, value)
	var err = config.save(SETTINGS_FILE)
	if err:
		Global.send_notification(2, "Can't save settings file!", "Error code: " + str(err))


func define_option(section: String, key: String, default: Variant = null) -> void:
	var config = ConfigFile.new()
	if FileAccess.file_exists(OPTIONS_FILE):
		config.load(OPTIONS_FILE)
	config.set_value(section, key, default)
	var err = config.save(OPTIONS_FILE)
	if err:
		Global.send_notification(2, "Can't save options source!", "Error code: " + str(err))


func get_default(section: String, key: String) -> Variant:
	if not FileAccess.file_exists(OPTIONS_FILE):
		return null
	var config := ConfigFile.new()
	var err := config.load(OPTIONS_FILE)
	if err:
		Global.send_notification(2, "Can't load options file!", "Error code: " + str(err))
		return null
	if config.has_section_key(section, key):
		return config.get_value(section, key)
	else:
		return null
