extends Window

@export var container: TabContainer

func _on_close_requested() -> void:
	queue_free()

func _ready() -> void:
	var config := ConfigFile.new()
	config.load(Settings.SETTINGS_FILE)
	for section in config.get_sections():
		var tab := VBoxContainer.new()
		for item in config.get_section_keys(section):
			var option = load("res://scripts/script_scenes/setting_option.tscn").instantiate()
			option.section = section
			option.key = item
			tab.add_child(option)
		tab.name = section.capitalize()
		container.add_child(tab)
		if tab.get_child_count() == 0: tab.queue_free()
