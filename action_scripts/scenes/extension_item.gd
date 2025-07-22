extends PanelContainer

@export var text: Label
@export var enable: CheckBox
@export var uninstall: Button
var id: String

func setup(item_id: String, label: String, enabled: bool = false) -> PanelContainer:
	id = item_id
	text.text = label
	enable.button_pressed = enabled
	if enabled:
		enable.text = "Enabled"
	show()
	return self


func _on_check_box_toggled(toggled_on: bool) -> void:
	Extensions.set_extension_enabled(id, toggled_on)
	if toggled_on:
		enable.text = "Enabled"
	else:
		enable.text = "Disabled"


func _on_button_pressed() -> void:
	add_child(Factory.confirmation_dialog("Are you sure about uninstall this extension?", "Yes", "Cancel", "Please Confirm", Callable(), _uninstall))


func _uninstall() -> void:
	Extensions.uninstall_extension(id)
	await get_tree().process_frame
	queue_free()
