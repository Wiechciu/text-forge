class_name NodeFactory
extends Node
## Fast way to create standard popups, menus, windows, etc.
##
## This is node factory of Text Forge. It's designed to generate useful nodes with signle function
## call. You can access to an instance of this class with [code]Factory[/code] singleton.


## Creates new [ConfirmationDialog] based on parameters.
func confirmation_dialog(
		text: String = "", ok_text: String = "OK", cancel_text: String = "Cancel",
		title: String = "Please Confirm", canceled := Callable(), confirmed := Callable(),
		show: bool = true
) -> ConfirmationDialog:
	var dialog := ConfirmationDialog.new()
	dialog.dialog_text = text
	dialog.ok_button_text = ok_text
	dialog.cancel_button_text = cancel_text
	dialog.title = title
	dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	dialog.canceled.connect(canceled)
	dialog.confirmed.connect(confirmed)
	dialog.visibility_changed.connect(func(): if not dialog.visible: dialog.queue_free())
	if show:
		dialog.ready.connect(dialog.show)
	return dialog


## Creates new [MenuButton] based on parameters.
func menu_button(switch_on_hover: bool = false, text: String = "") -> MenuButton:
	var button := MenuButton.new()
	button.switch_on_hover = switch_on_hover
	button.text = text
	return button
