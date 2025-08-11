class_name TextForgeMode
extends Node
## Based class for Text Forge modes.
##
## This is base class for create modes, each mode must extends this class. Mode will be child of
## [EditorAPI] when is enabled (in use).[br][br]
## [b]Note:[/b] Use [method _initialize_mode] to set properties values, see [method _initialize_mode]
## for more information.

## [SyntaxHighlighter] to load to [Editor]. You can have a highlighter script and load it to this
## property, this method is advanced way. Otherwise, you can use [CodeHighlighter] and its functions
## to create simple highlighters.
var syntax_highlighter: SyntaxHighlighter = SyntaxHighlighter.new()
## [Array] of comment delimiters, each item must be in this pattern (and this order):
## [codeblock]
## {
##     "start_key": String,
##     "end_key": String,
##     "line_only": bool
## }
## [/codeblock]
var comment_delimiters: Array[Dictionary] = []
## Optional panel to load in left side of editor.
var panel: TextForgePanel
## Specifies whether this mode has a panel or not.
var has_panel: bool = false
## Reperesents features of this mode, to set, call [code]_enable_..._feature()[/code] methods in
## [method _initialize_mode].
var features: Dictionary[String, bool] = {
	"auto_format": false,
	"auto_indent": false,
}


## Override this method to initialize mode and set properties. If this function return an error code
## instead of [constant OK], [EditorAPI] will show that error and will try to use another mode.[br]
## Call [code]_enable_..._feature()[/code] methods (e.g. [method _enable_auto_format_feature]) here for your mode features.
func _initialize_mode() -> Error:
	return OK


## Call this function in [method _initialize_mode] to enable auto format feature, DON'T override this!
func _enable_auto_format_feature() -> void:
	features["auto_format"] = true


## Call this function in [method _initialize_mode] to enable auto indent feature, DON'T override this!
func _enable_auto_indent_feature() -> void:
	features["auto_indent"] = true


## Override this method to add auto format feature if your mode supports it.[br][br]
## [b]Important:[/b] Your mode should only format the selected lines and return the rest of the
## lines as they are! Use [method Editor.is_selection_in_line] for each line to handle this.[br]
## [b]Note:[/b] See [method _enable_auto_format_feature] before override.[br]
func _auto_format(text: String) -> String:
	return text


## Override this method to add auto format feature if your mode supports it. Auto indent just
## includes automatic indention, not other formattings! To add other formatting features use
## [method _auto_format] function.[br][br]
## [b]Important:[/b] Your mode should only change indention of the selected lines and return the
## rest of the lines as they are! Use [method Editor.is_selection_in_line] for each line to handle
## this.[br]
## [b]Note:[/b] See [method _enable_auto_indent_feature] before override.[br]
func _auto_indent(text: String) -> String:
	return text


## Override this method to handle convert [String] (in editor) to [PackedByteArray] (for files),
## this is file saving section of your mode.
func _string_to_buffer(string: String) -> PackedByteArray:
	return PackedByteArray()


## Override this method to load a [PackedByteArray] (stored in a file) to [String] (for editor),
## this is file loading section of your mode.
func _buffer_to_string(buffer: PackedByteArray) -> String:
	return String()


## Override this method to handle code completion feature, [param text] is the full editor text with
## char [code]0xFFFF[/code] at the caret location. Use [method CodeEdit.add_code_completion_option]
## and [method CodeEdit.update_code_completion_options] for this task.
## [/codeblock]
func _update_code_completion_options(text: String) -> void:
	return Array()


## Returns [member syntax_highlighter]. Setup syntax highlighter in [method _initialize_mode] and
## DON'T override this function.
func get_syntax_highlighter() -> SyntaxHighlighter:
	return syntax_highlighter


## Shows [member panel] in editor if has panel. DON'T override this function.
func show_panel() -> void:
	if panel:
		Global.get_panel_manager().show_panel(PanelManager.Panels.LEFT, panel.index)
