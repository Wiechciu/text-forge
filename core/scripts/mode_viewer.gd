extends MenuButton

func _ready() -> void:
	Signals.mode_changed.connect(_update_mode.unbind(1))
	_update_mode()


func _update_mode() -> void:
	var current_mode := Global.get_editor_api().current_mode
	get_popup().clear(true)
	if current_mode == {}:
		text = "Current Mode: None"
	else:
		text = "Current Mode: " + current_mode["name"]
	get_popup().add_item("Modes count:" + str(Global.get_editor_api().mode_list.size()))
	var submenu := PopupMenu.new()
	for m in Global.get_editor_api().mode_list:
		for e in m["extensions"]:
			submenu.add_item(e)
	get_popup().add_submenu_node_item("Available extensions", submenu)
