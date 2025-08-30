class_name ProjectAPI
extends Node

signal project_opened
signal project_closed
signal load_files(include: Array, exclude: Array)

var current_project: ConfigFile
var recent_menu: PopupMenu

func _ready() -> void:
	Settings.define_preset("files", "save_files_in_move_between_project_files", false)


func close_project() -> void:
	project_closed.emit()


func load_project(file_path: String) -> void:
	current_project = ConfigFile.new()
	var err := current_project.load(file_path)
	if err:
		Global.send_notification(Global.Notification.ERROR, "Failed to load project: {0}".format([err]))
		project_closed.emit()
		return
	Global.get_core().append_to_recent_files(file_path)
	append_to_recent_projects(file_path)
	project_opened.emit()
	load_files.emit(current_project.get_value("files", "include"), current_project.get_value("files", "exclude"))
	Signals.check_options.emit()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_IN:
			if current_project:
				if current_project.has_section_key("project", "name"):
					load_files.emit(current_project.get_value("files", "include"), current_project.get_value("files", "exclude"))


func _on_recent_id_pressed(id: int) -> void:
	load_project(recent_menu.get_item_text(recent_menu.get_item_index(id)))


func load_recent_projects() -> void:
	# Clear submenu
	recent_menu.clear()

	# Load recent projects
	if FileAccess.file_exists(SLib.globalize_path(FileDatabase.RECENT_PROJECTS_DATA)):
		var recent_projects_list = FileAccess.get_file_as_string(FileDatabase.RECENT_PROJECTS_DATA).split("\n", false)

		recent_projects_list = SLib.merge_unique(recent_projects_list, []) # Remove duplicate items

		for recent in recent_projects_list:
			if recent_menu.item_count == 15: # Limit list to 15 items
				break
			if not FileAccess.file_exists(SLib.globalize_path(recent)): # Remove non-existent items
				continue

			recent_menu.add_item(recent.replace("\\", "/"))

	# Save recent projects again (to remove repeated and non-existent items)
	var recent_projects := PackedStringArray()
	for recent in recent_menu.item_count:
		recent_projects.append(recent_menu.get_item_text(recent))
	if "\n".join(recent_projects) != FileAccess.get_file_as_string(FileDatabase.RECENT_PROJECTS_DATA):
		var file = FileAccess.open(FileDatabase.RECENT_PROJECTS_DATA, FileAccess.WRITE)
		file.store_string("\n".join(recent_projects))
		file.close()


func append_to_recent_projects(file_path: String) -> void:
	var file: FileAccess
	var files: String
	files = FileAccess.get_file_as_string(FileDatabase.RECENT_PROJECTS_DATA)

	file = FileAccess.open(FileDatabase.RECENT_PROJECTS_DATA, FileAccess.WRITE)
	file.store_string(file_path + "\n" + files)
	file.close()

	load_recent_projects()
