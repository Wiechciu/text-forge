extends TextForgeMode


func _initialize_mode() -> Error:
	syntax_highlighter = CodeHighlighter.new()
	syntax_highlighter.add_color_region(";", "", Color.WEB_GRAY, true)
	syntax_highlighter.function_color = Color.WHITE
	syntax_highlighter.number_color = Color.WHITE
	syntax_highlighter.symbol_color = Color.WHITE
	syntax_highlighter.member_variable_color = Color.WHITE
	comment_delimiters.append({
		"start_key": ";",
		"end_key": "",
		"line_only": true,
	})
	string_delimiters.append({
		"start_key": "\"",
		"end_key": "\"",
		"line_only": false,
	})
	string_delimiters.append({
		"start_key": "\'",
		"end_key": "\'",
		"line_only": false,
	})
	panel = TextForgePanel.new()
	panel.custom_minimum_size = Vector2(200, 0)
	panel.add_child(Label.new())
	panel.get_child(0).text = "Test INI Mode"
	has_panel = true
	_enable_auto_format_feature()
	return OK


func _auto_format(text: String) -> String:
	var config := ConfigFile.new()
	config.parse(text)
	var formatted := config.encode_to_text()
	return formatted


func _string_to_buffer(string: String) -> PackedByteArray:
	return string.to_utf8_buffer()


func _buffer_to_string(buffer: PackedByteArray) -> String:
	return buffer.get_string_from_utf8()


func _update_code_completion_options(text: String) -> void:
	Global.get_editor().update_code_completion_options(false)
