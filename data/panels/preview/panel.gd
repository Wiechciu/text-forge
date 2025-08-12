extends TextForgePanel

@export var message: Label
@export var preview: RichTextLabel

func _ready() -> void:
	Signals.preview_unavailable.connect(_set_preview_enabled.bind(false))
	Signals.preview_updated.connect(_set_preview_enabled.bind(true).unbind(1))
	Signals.preview_updated.connect(_update_preview)


func _update_preview(text: String) -> void:
	if text == "":
		Signals.preview_unavailable.emit()
		return
	_set_preview_enabled(true)
	preview.text = text


func _set_preview_enabled(enabled: bool) -> void:
	if enabled:
		if message.visible:
			message.hide()
	else:
		if not message.visible:
			message.show()
			preview.text = ""
