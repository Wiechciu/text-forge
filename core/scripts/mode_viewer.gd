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
	var modes := PopupMenu.new()
	var extensions := PopupMenu.new()
	for m in Global.get_editor_api().mode_list:
		modes.add_item("{0} ({1})".format([m["name"], m["id"]]))
		for e in m["extensions"]:
			extensions.add_item(e)
	get_popup().add_submenu_node_item("Modes ({0})".format([Global.get_editor_api().mode_list.size()]), modes)
	get_popup().add_submenu_node_item("Available extensions", extensions)
