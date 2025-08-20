@tool
extends EditorContextMenuPlugin


const ICON = preload("res://addons/csv_to_gettext_converter/icon.png")
const HEADER: String = '#, fuzzy
msgid ""
msgstr ""
"Project-Id-Version: \\n"
"POT-Creation-Date: \\n"
"PO-Revision-Date: \\n"
"Last-Translator: \\n"
"Language-Team: \\n"
"Language: \\n"
"MIME-Version: 1.0\\n"
"Content-Type: text/plain; charset=UTF-8\\n"
"Content-Transfer-Encoding: 8bit\\n"
"X-Generator: Poedit 3.4.2\\n"\n\n'

var created_files: PackedStringArray
var created_files_string: String:
	get:
		var text: String = ""
		for file: String in created_files:
			text += file.get_file()
			text += "\n"
		return text.rstrip("\n")


func _popup_menu(paths: PackedStringArray) -> void:
	if not _validate_path(paths):
		return
	
	add_context_menu_item("Convert CSV to gettext", _convert_csv_to_pot, ICON)


func _convert_csv_to_pot(paths: Array) -> void:
	if not _validate_path(paths):
		return
	
	created_files.clear()
	var path: String = paths[0]
	var base_dir: String = path.get_base_dir()
	var dict: Dictionary[String, Array] = _read_csv_file(path)
	if dict.is_empty():
		return
	
	for language in dict.keys():
		var file_content: String = _create_file_content(dict, language)
		var file_name: String = "translation.pot" if language == "key" else "%s.po" % language
		var full_path: String = "%s/%s" % [base_dir, file_name]
		
		if FileAccess.file_exists(full_path):
			await _create_overwrite_confirmation_dialog(full_path, file_content)
		else:
			_create_file(full_path, file_content)
	
	EditorInterface.get_resource_filesystem().scan()
	_create_finished_dialog("Success", "Successfully finished CSV to gettext conversion:\n%s" % created_files_string)


func _validate_path(paths: Array) -> bool:
	if paths.size() != 1:
		return false
	
	var path: String = paths[0]
	if path.get_extension() != "csv":
		return false
	
	if not FileAccess.file_exists(path):
		return false
	
	return true


func _validate_column_names(column_names: PackedStringArray) -> bool:
	var has_key: bool = false
	
	for column_name: String in column_names:
		if column_name == "key":
			has_key = true
			continue
		
		if column_name == TranslationServer.get_locale_name(column_name):
			_create_finished_dialog("Failed", "Unknown language in CSV file: %s." % column_name)
			return false
	
	if not has_key:
		_create_finished_dialog("Failed", "No 'key' column found in CSV file.")
		return false
	
	return true


func _read_csv_file(path: String) -> Dictionary[String, Array]:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var dict: Dictionary[String, Array] = {}
	var column_names: PackedStringArray = file.get_csv_line()
	if not _validate_column_names(column_names):
		return dict
	
	while file.get_position() < file.get_length():
		var line: PackedStringArray = file.get_csv_line()
		if line.size() != column_names.size():
			continue
		
		for index: int in line.size():
			if not dict.has(column_names[index]) or dict[column_names[index]] == null:
				dict[column_names[index]] = []
			dict[column_names[index]].append(line[index])
	
	file.close()
	
	return dict


func _create_file(full_path: String, text: String) -> void:
	var new_file = FileAccess.open(full_path, FileAccess.WRITE)
	new_file.store_string(text)
	new_file.close()
	created_files.append(full_path.get_file())


func _create_overwrite_confirmation_dialog(full_path: String, text: String) -> void:
	var confirmation_dialog = preload("res://addons/csv_to_gettext_converter/confirmation_dialog.gd").new()
	confirmation_dialog.title = "Overwrite file?"
	confirmation_dialog.dialog_text = "File already exists.\n'%s'\n\nOverwrite it?" % full_path
	confirmation_dialog.confirmed.connect(_create_file.bind(full_path, text))
	EditorInterface.popup_dialog_centered(confirmation_dialog)
	
	await confirmation_dialog.closed
	# Needs to await 2x process_frame, otherwise new confirmation_dialog is rendered incorrectly.
	await EditorInterface.get_base_control().get_tree().process_frame
	await EditorInterface.get_base_control().get_tree().process_frame
	confirmation_dialog.queue_free()


func _create_file_content(dict: Dictionary, language: String) -> String:
	var file_content: String = HEADER.replace("Language: ", "Language: %s" % language)
	for index in dict["key"].size():
		file_content += 'msgid "%s"\n' % [dict["key"][index]]
		if language == "key":
			file_content += 'msgstr ""\n\n'
		else:
			file_content += 'msgstr "%s"\n\n' % [dict[language][index]]
	
	return file_content


func _create_finished_dialog(title: String, text: String) -> void:
	var dialog = AcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = text
	EditorInterface.popup_dialog_centered(dialog)
