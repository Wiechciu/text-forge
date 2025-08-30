extends Window

@export var path_button: Button
@export var name_edit: LineEdit
@export var details_edit: LineEdit
@export var icon_button: Button
@export var tags_edit: LineEdit
@export var file_node: HBoxContainer
@export var include_files: VBoxContainer
@export var exclude_files: VBoxContainer

func _on_path_pressed() -> void:
	add_child(Factory.file_dialog(FileDialog.FILE_MODE_SAVE_FILE, FileDialog.ACCESS_FILESYSTEM,
			["*.tfproj;Text Forge Porject File"], _path_selected, true,
			OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS), ""))


func _path_selected(path: String) -> void:
	path_button.text = path


func _on_icon_pressed() -> void:
	add_child(Factory.file_dialog(FileDialog.FILE_MODE_OPEN_FILE, FileDialog.ACCESS_FILESYSTEM,
			["*.bmp,*.dds,*.ktx,*.exr,*.hdr,*.jpg,*.jpeg,*.png,*.tga,*.svg,*.webp;Image Files;image/bmp,image/vnd.ms-dds,image/ktx,image/exr,image/vnd.radiance,image/jpeg,image/jpeg,image/png,image/x-tga,image/svg+xml,image/webp"],
			_icon_selected, true, OS.get_system_dir(OS.SYSTEM_DIR_PICTURES), ""))


func _icon_selected(path: String) -> void:
	icon_button.text = path


func _add_include(path) -> void:
	if path is PackedStringArray:
		for p in path:
			if p in include_files.get_children().map(func(file): return file.get_child(0).text):
				continue
			var n := file_node.duplicate()
			n.get_child(0).text = p
			n.get_child(1).pressed.connect(_remove_include.bind(p))
			n.show()
			include_files.add_child(n)
	else:
		if path in include_files.get_children().map(func(file): return file.get_child(0).text):
			return
		var n := file_node.duplicate()
		n.get_child(0).text = path
		n.get_child(1).pressed.connect(_remove_include.bind(path))
		n.show()
		include_files.add_child(n)


func _on_include_dir_pressed() -> void:
	add_child(Factory.file_dialog(FileDialog.FILE_MODE_OPEN_DIR, FileDialog.ACCESS_FILESYSTEM, [],
	_add_include, true, OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS), ""))


func _on_include_file_pressed() -> void:
	add_child(Factory.file_dialog(FileDialog.FILE_MODE_OPEN_FILES, FileDialog.ACCESS_FILESYSTEM, [],
	_add_include, true, OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS), ""))


func _remove_include(path: String) -> void:
	for file in include_files.get_children():
		if file.get_child(0).text == path:
			file.queue_free()
			break


func _add_exclude(path) -> void:
	if path is PackedStringArray:
		for p in path:
			if p in exclude_files.get_children().map(func(file): return file.get_child(0).text):
				continue
			var n := file_node.duplicate()
			n.get_child(0).text = p
			n.get_child(1).pressed.connect(_remove_exclude.bind(p))
			n.show()
			exclude_files.add_child(n)
	else:
		if path in exclude_files.get_children().map(func(file): return file.get_child(0).text):
			return
		var n := file_node.duplicate()
		n.get_child(0).text = path
		n.get_child(1).pressed.connect(_remove_exclude.bind(path))
		n.show()
		exclude_files.add_child(n)

func _on_exclude_dir_pressed() -> void:
	add_child(Factory.file_dialog(FileDialog.FILE_MODE_OPEN_DIR, FileDialog.ACCESS_FILESYSTEM, [],
	_add_exclude, true, OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS), ""))


func _on_exclude_file_pressed() -> void:
	add_child(Factory.file_dialog(FileDialog.FILE_MODE_OPEN_FILES, FileDialog.ACCESS_FILESYSTEM, [],
	_add_exclude, true, OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS), ""))


func _remove_exclude(path: String) -> void:
	for file in exclude_files.get_children():
		if file.get_child(0).text == path:
			file.queue_free()
			break


func _on_create_pressed() -> void:
	if not path_button.text.ends_with(".tfproj"):
		add_child(Factory.accept_dialog("Please select valid file path to save your project file.",
				"Alert!", Callable(), Vector2(500, 50), true, true))
		return
	if name_edit.text == "":
		add_child(Factory.accept_dialog("Please select a name for your project.", "Alert!",
				Callable(), Vector2(500, 50), true, true))
		return
	if include_files.get_child_count() == 0:
		add_child(Factory.accept_dialog("Your project should have one or more file / folder.",
				"Alert!", Callable(), Vector2(500, 50), true, true))
		return

	var config := ConfigFile.new()
	config.set_value("project", "name", name_edit.text)
	config.set_value("project", "details", details_edit.text)
	if icon_button.text.get_extension() in ["bmp", "dds", "ktx", "exr", "hdr", "jpg", "jpeg", "png", "tga", "svg", "webp"]:
		config.set_value("project", "icon", icon_button.text)
	config.set_value("project", "tags", tags_edit.text)
	config.set_value("files", "include", include_files.get_children().map(func(file):
		return file.get_child(0).text))
	config.set_value("files", "exclude", exclude_files.get_children().map(func(file):
		return file.get_child(0).text))
	var err := config.save(path_button.text)
	if err == OK:
		Global.send_notification(Global.Notification.INFO, "New project created at {0}.".format([path_button.text]))
	else:
		Global.send_notification(Global.Notification.ERROR, "Failed to save project at {0}!".format([path_button.text]), "Error code: {0}".format([err]))
	queue_free()
