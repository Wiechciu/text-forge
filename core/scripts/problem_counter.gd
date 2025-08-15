extends HBoxContainer

@export var error_count: Label
@export var warning_count: Label

func _ready() -> void:
	Signals.problems_updated.connect(_update_count)

func _update_count(problems: Array) -> void:
	error_count.text = str(problems.filter(func(p): return p["error"] == true).size())
	warning_count.text = str(problems.filter(func(p): return p["error"] == false).size())

	if error_count.text == "0":
		error_count.get_parent().get_parent().hide()
	else:
		error_count.get_parent().get_parent().show()
	if warning_count.text == "0":
		warning_count.get_parent().get_parent().hide()
	else:
		warning_count.get_parent().get_parent().show()
