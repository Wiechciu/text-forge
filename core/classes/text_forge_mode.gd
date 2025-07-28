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
## [Array] of comment delimiters, each item must be in this pattern:
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
## Reperesents features of this mode, to set, call [method _set_features] in [method _initialize_mode].
var features: Dictionary[String, bool] = {
	"auto_format": false,
	"auto_indent": false,
}


## Override this method to initialize mode and set properties. If this function return an error code
## instead of [constant OK], [EditorAPI] will show that error and will try to use another mode.[br]
## Call [method _set_feature] with features of your mode here.
func _initialize_mode() -> Error:
	return OK


## Call this function to set [member features] values, DON'T override this!
func _set_features(auto_format: bool = false, auto_indent: bool = false) -> void:
	features["auto_format"] = auto_format
	features["auto_indent"] = auto_indent


## Override this method to add auto format feature.
func _auto_format() -> void:
	pass


## Override this method to add auto indent feature.
func _auto_indent() -> void:
	pass


## Override this method to handle convert [String] (in editor) to [PackedByteArray] (for files),
## this is file saving section of your mode.
func _string_to_buffer(string: String) -> PackedByteArray:
	return PackedByteArray()


## Override this method to load a [PackedByteArray] (stored in a file) to [String] (for editor),
## this is file loading section of your mode.
func _buffer_to_string(buffer: PackedByteArray) -> String:
	return String()


## Returns [member syntax_highlighter]. Setup this member in [method _initialize_mode].
func get_syntax_highlighter() -> SyntaxHighlighter:
	return syntax_highlighter
