extends TextForgePanel

@export var tab: TabContainer
@export var tree: Tree

func _ready() -> void:
	Project.project_opened.connect(func(): tab.current_tab = 1)
	Project.project_closed.connect(func(): tab.current_tab = 0)
	tab.current_tab = 0
	Project.load_files.connect(_load_files_tree)


func _load_files_tree(include: Array, exclude: Array) -> void:
	tree.clear()
	var root := tree.create_item()
	for item: String in include:
		_add_branch(root, item, exclude)


func _add_branch(root: TreeItem, path: String, exclude_list: Array) -> void:
	if path in exclude_list:
		return
	if DirAccess.dir_exists_absolute(path):
		var dir := tree.create_item(root)
		dir.set_text(0, path.get_file() if root != tree.get_root() else path)
		dir.set_tooltip_text(0, "Directory")
		for item in DirAccess.get_directories_at(path):
			_add_branch(dir, path.path_join(item), exclude_list)
		for file in DirAccess.get_files_at(path):
			_add_branch(dir, path.path_join(file), exclude_list)
	elif FileAccess.file_exists(path):
		var file := tree.create_item(root)
		file.set_text(0, path.get_file() if root != tree.get_root() else path)
		file.set_tooltip_text(0, path)


func _on_tree_item_selected() -> void:
	var path := tree.get_selected().get_tooltip_text(0)
	if path != "Directory":
		if Global.get_file_name().ends_with("*"):
			if Settings.get_setting("files", "save_files_in_move_between_project_files"):
				Signals.run_script.emit(Global.get_scripts_node().get_node("save").id)
				await get_tree().process_frame
			else:
				add_child(Factory.accept_dialog("You have unsaved changes in this file, please save / discard them before open another file. You can enable autosave in \"Files > Save Files In Move Between Project Files\" in Preferences.",
						"Alert!", Callable(), Vector2(600, 50), true, true))
				return
		Signals.open_file.emit(path)
