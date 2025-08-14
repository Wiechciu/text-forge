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
## [Array] of string delimiters, with same structure as [member comment_delimiters].
var string_delimiters: Array[Dictionary] = []
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
## [b]Note:[/b] See [method _enable_auto_format_feature] before override.[br]
func _auto_format(text: String) -> String:
	return text


## Override this method to add auto format feature if your mode supports it. Auto indent just
## includes automatic indention, not other formattings! To add other formatting features use
## [method _auto_format] function.[br][br]
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
func _update_code_completion_options(text: String) -> void:
	pass


## Override this method to handle preview feature, [param text] is the full editor text and this
## method should return preview as string. (you can use BBCode for formatting)
func _generate_preview(text: String) -> String:
	return String()


## Override this method to handle outline feature, [param text] is the full editor text and this
## method should return a nested array as table of content / symbols in this strcuture:
## [codeblock]
## [ # Highest array is root of file, don't add text and line number here
##     [
##         "Heading 1", # text of current section
##         0, # line of section from 0
##         [ # define optional sub-sections as arrays after text and line number
##             "Heading 2 (1)",
##             10,
##         ],
##         [ # another sub-section
##             "Heading 2 (2)",
##             14,
##             [ # each section can have zero or more sub-sections
##                 "Heading 3",
##                 16,
##             ],
##         ],
##     ],
## ]
## [/codeblock]
## Above structure is for a file like this (markdown example):
## [codeblock lang=text]
## # Heading 1
## ...
## ## Heading 2 (1)
## ...
## ## Heading 2 (2)
## ...
## ### Heading 3
## ...
## [/codeblock]
## And will be shown as:
## [codeblock lang=text]
## Heading 1/
##     Heading 2 (1)
##     Heading 2 (2)/
##         Heading 3
## [/codeblock]
## [b]Note:[/b] Highest array is root of file, this array allows you to have more than one first-class section.
func _generate_outline(text: String) -> Array:
	return Array()


## Override this method to handle linting, [param text] is the full editor text and this method
## should return an array of problems in this strcuture:
## [codeblock]
## {
##     "line": int, # from 0
##     "column": int, # from 0, -1 for all of line
##     "error": bool, # false for warnings, true for errors
##     "title": String,
##     "details": String,
## }
## [/codebloc]
func _lint_file(text: String) -> Array[Dictionary]:
	return Array([], TYPE_DICTIONARY, "", null)


## Returns [member syntax_highlighter]. Setup syntax highlighter in [method _initialize_mode] and
## DON'T override this function.
func get_syntax_highlighter() -> SyntaxHighlighter:
	return syntax_highlighter


## Shows [member panel] in editor if has panel. DON'T override this function.
func show_panel() -> void:
	if panel:
		Global.get_panel_manager().show_panel(PanelManager.Panels.LEFT, panel.index)
