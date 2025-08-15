class_name TFP_Preview
extends TextForgePanel
## A standard panel that receive preview and show it.
##
## This panel is connected to SignalBus.preview_updated and refresh problem list with this signal.

## Message label.
@export var message: Label
## Preview [RichTextLabel] with BBCode support.
@export var preview: RichTextLabel

func _ready() -> void:
	Signals.preview_updated.connect(_update_preview)


func _update_preview(text: String) -> void:
	if text == "":
		_set_preview_enabled(false)
		return
	_set_preview_enabled(true)
	preview.text = text


func _set_preview_enabled(enabled: bool) -> void:
	if enabled:
		message.hide()
	else:
		message.show()
		preview.text = ""
