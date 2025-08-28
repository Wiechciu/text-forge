extends Label

func _ready() -> void:
	Global.get_editor().caret_changed.connect(_update_caret_pos)


func _update_caret_pos() -> void:
	text = "{0} : {1}".format([Global.get_editor().get_caret_line(), Global.get_editor().get_caret_column()])
