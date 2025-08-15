extends TextForgePanel

enum ProblemChildren {
	ICON,
	TITLE,
	DETAILS,
	BUTTON,
}

@export var instance: PanelContainer
@export var problem_list: VBoxContainer
@export var message: Label

func _ready() -> void:
	Signals.problems_updated.connect(_update_problems)


func _update_problems(problems: Array[Dictionary]) -> void:
	if problems.any(func(p): return p["error"] == true):
		Global.get_panel_manager().change_panel_icon(PanelManager.Panels.BOTTOM, index, load("res://data/panels/problems/error.png"))
	elif problems.size():
		Global.get_panel_manager().change_panel_icon(PanelManager.Panels.BOTTOM, index, load("res://data/panels/problems/warning.png"))
	else:
		Global.get_panel_manager().change_panel_icon(PanelManager.Panels.BOTTOM, index, load("res://data/panels/problems/icon.png"))

	SLib.free_all_children(problem_list)

	for p in problems:
		var item: PanelContainer = instance.duplicate()
		var icon: Texture2D = load("res://data/panels/problems/error.png") if p["error"] else load("res://data/panels/problems/warning.png")
		var color: Color = Color("e50000") if p["error"] else Color("e8bc03")
		var line_column: String
		if p["column"] == -1:
			line_column = "Line {0}".format([p["line"] + 1])
		else:
			line_column = "Line {0} (column {1})".format([p["line"] + 1, p["column"]])
		_get_problem_children(ProblemChildren.ICON, item).texture = icon
		_get_problem_children(ProblemChildren.TITLE, item).text = "{0}: {1}".format([line_column, p["title"]])
		_get_problem_children(ProblemChildren.TITLE, item).add_theme_color_override(&"font_color", color)
		_get_problem_children(ProblemChildren.DETAILS, item).text = p["details"]
		if p["details"] == "":
			_get_problem_children(ProblemChildren.DETAILS, item).hide()
		_get_problem_children(ProblemChildren.BUTTON, item).pressed.connect(_move_to_problem.bind(p["line"], p["column"]))
		item.show()
		problem_list.add_child(item)

	message.visible = problem_list.get_child_count() == 0


func _move_to_problem(line: int, column: int) -> void:
	Global.get_editor().set_caret_line(line)
	if column <= -1:
		column = Global.get_editor().get_line(line).length()
	Global.get_editor().set_caret_column(column)
	Global.get_editor().merge_overlapping_carets()
	Global.get_editor().grab_focus()


func _get_problem_children(children: ProblemChildren, problem: PanelContainer) -> Control:
	match children:
		ProblemChildren.ICON:
			return problem.get_child(0).get_child(0).get_child(0)
		ProblemChildren.TITLE:
			return problem.get_child(0).get_child(0).get_child(1)
		ProblemChildren.DETAILS:
			return problem.get_child(0).get_child(1)
		ProblemChildren.BUTTON:
			return problem.get_child(1)
	return problem


func _on_button_pressed() -> void:
	Global.get_editor_api()._lint_content()
