@tool
extends Node


@export_file("*.csv") var csv_file: String = FileDatabase.TRANSLATION_FILE
@export_dir() var final_dir: String
@export_tool_button("Button") var button: Callable = convert_to_pot
	#get:
		#return func() -> void: print(convert_to_pot())


func _ready() -> void:
	convert_to_pot()


func convert_to_pot() -> void:
	if not FileAccess.file_exists(csv_file):
		print("Source file doesn't exist")
		return

	var file := FileAccess.open(csv_file, FileAccess.READ)
	var column_names := file.get_csv_line()
	var dict: Dictionary[String, Array] = {}
	
	while file.get_position() < file.get_length():
		var line = file.get_csv_line()
		for index in column_names.size():
			#prints(column_names[index], line[index])
			if not dict.has(column_names[index]) or dict[column_names[index]] == null:
				dict[column_names[index]] = []
			dict[column_names[index]].append(line[index])
	file.close()
	#print(dict)
	
	var header: String = '#, fuzzy
msgid ""
msgstr ""
"Project-Id-Version: "
"POT-Creation-Date: "
"PO-Revision-Date: "
"Last-Translator: "
"Language-Team: "
"MIME-Version: 1.0"
"Content-Type: text/plain; charset=UTF-8"
"Content-Transfer-Encoding: 8bit"
"X-Generator: Poedit 3.4.2"\n\n'
	
	for language in dict.keys():
		var text: String = header
		for index in dict["key"].size():
			text += 'msgid "%s"\n' % [dict["key"][index]]
			if language == "key":
				text += 'msgstr ""\n\n'
			else:
				text += 'msgstr "%s"\n\n' % [dict[language][index]]
		#print(text)
		var file_name: String = "translation.pot"
		if language != "key":
			file_name = "%s.po" % language
		var full_path: String = "%s/%s" % [final_dir, file_name]
		var new_file = FileAccess.open(full_path, FileAccess.WRITE)
		new_file.store_string(text)
		new_file.close()
		print("Created %s" % file_name)
		
		if language != "key":
			var translation: Translation = ResourceLoader.load(full_path)
			TranslationServer.add_translation(translation)
			print("Loaded translation %s" % file_name)
			print(TranslationServer.get_loaded_locales())
