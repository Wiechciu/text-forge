extends Window

@export var container: TabContainer
@export var tree: Tree

func _on_close_requested() -> void:
	Signals.settings_changed.emit()
	queue_free()

func _ready() -> void:
	var config := ConfigFile.new()
	config.load(Settings.SETTINGS_FILE)
	tree.create_item()
	for section in config.get_sections():
		var tab := VBoxContainer.new()
		for item in config.get_section_keys(section):
			var option = load("res://scripts/script_scenes/setting_option.tscn").instantiate()
			option.section = section
			option.key = item
			tab.add_child(option)
		tab.name = section.capitalize().replace("Ui", "UI")
		container.add_child(tab)
		var page := tree.create_item()
		page.set_text(0, tab.name)
		if tab.get_child_count() == 0: tab.queue_free()
	tree.set_selected(tree.get_root().get_first_child(),0)


func _on_tree_item_selected() -> void:
	container.current_tab = tree.get_selected().get_index()
