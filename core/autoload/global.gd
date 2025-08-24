class_name GlobalAccess
extends Node
## Global access way to all parts of Text Forge.
##
## You can access to this class using [code]Global[/code] autoload.

## Type of [b]Editor Notification[/b]s, see also [method send_notification] and
## [signal SignalBus.editor_notification].
enum Notification {
	INFO, ## Regular notification with "Information" type.
	WARNING, ## Warning notification, for exceptions without silent handling (but with handling).
	ERROR, ## Error notification, for unhandled exceptions.
}

## Main window manager with restore window state. See [WindowManager] for more information.
static var window_manager := WindowManager.new()
## Keeps list of damaged mode IDs and reasons.
var damaged_modes: Dictionary[String, String] = {}
## Keeps map to shortcuts for action scripts.
var shortcut_map: ShortcutMap
## Dictionary of all commands. example item:
## [codeblock]
## # Command Name (String): [Shortcut as Text (String), Command Action (Callable)]
## "Close": ["Ctrl+W", close_action_script._run_action]
## [/codeblock]
## See [method define_command] for more information.
var commands: Dictionary[String, Array] = {}:
	get = get_command_list

## Keeps temprory nodes for catch or transfer.
var temprory_children: Dictionary[String, Node] = {}

var _core: Core
var _editor: Editor
var _file_label: Label

# Initializing function
func _ready() -> void:
	shortcut_map = load_resource("res://data/shortcuts.tres")
	add_child(window_manager)
	_core = get_node("/root/Main")
	_editor = _core.editor
	_file_label = _core.file_label


## Converts given [param event] from [InputEventKey] to [enum Key].
static func convert_event_to_key(event: InputEventKey) -> int:
	var mask := (int(event.ctrl_pressed) * KEY_MASK_CTRL) | (int(event.alt_pressed) * KEY_MASK_ALT) | (int(event.shift_pressed) * KEY_MASK_SHIFT)
	return mask | event.keycode


## Returns last window mode but [constant Window.MODE_FULLSCREEN] excluded.[br][br]
## [b]Note:[/b] [WindowManager] will exclude [constant Window.MODE_MINIMIZED] itself; See
## [WindowManager] for more information.
func get_window_mode_before_fullscreen() -> Window.Mode:
	return window_manager.last_mode_except_fullscreen


## Returns currently opened file path, this is tooltip of [member Core.file_label] that user can see
## it with hover on file name in editor.
func get_file_path() -> String:
	return _file_label.tooltip_text


## Returns currently opened file name, this is text of [member Core.file_label].
func get_file_name() -> String:
	return _file_label.text


## Sets [param path] as path of opened file with set it as tooltip of [member Core.file_label].[br][br]
## [b]Note:[/b] This action isn't loading!
func set_file_path(path: String) -> void:
	_file_label.tooltip_text = path


## Sets [param file_name] as name of opened file with set it as text of [member Core.file_label].[br][br]
## [b]Note:[/b] There is no connection between this function and [method set_file_path].
func set_file_name(file_name: String) -> void:
	_file_label.text = file_name


func has_file() -> bool:
	return get_file_path().is_absolute_path()

## Returns editor node, it's accessable with [member Core.editor] too.
func get_editor() -> Editor:
	return _editor


## Returns current text in editor with get [method TextEdit.get_text].
func get_editor_text() -> String:
	return _editor.get_text()


## Sets [param text] as text of [Editor] [CodeEdit]. If [param keep_carets] is [code]false[/code],
## this actiona will move caret to start of text. If [code]true[/code] all carets and selection
## origins will restore automatically. (This action is based on line and column, so if your change
## containes line/column changing (for example line merging) you can set it to [code]false[/code]
## and do caret restoring yourself.
func set_editor_text(text: String, keep_carets: bool = true) -> void:
	var carets: Array[Array] = []
	if keep_carets:
		for index in _editor.get_caret_count():
			var origin := Vector2i(_editor.get_selection_origin_line(index), _editor.get_selection_origin_column(index))
			var caret := Vector2i(_editor.get_caret_line(index), _editor.get_caret_column(index))
			carets.append([origin, caret])
	_editor.text = text
	if keep_carets:
		for idx in carets.size():
			var selection: Array = carets[idx]
			if idx >= _editor.get_caret_count():
				_editor.add_caret(0, 0)
			_editor.select(selection[0].x, selection[0].y, selection[1].x, selection[1].y, idx)


## Will disable the editor if [param disabled] is [code]true[/code].
func set_editor_disabled(disabled: bool) -> void:
	_editor.editable = not disabled


## Returns [code]true[/code] if editor is disabled.
func is_editor_disabled() -> bool:
	return not _editor.editable


## Returns [Core] node, this is root of main scene in main window. See [Core] for more information.
func get_core() -> Core:
	return _core


## Returs node in [Core] that keep action scripts, it's useful when you need find an action script
## without its [code]id[/code].
func get_scripts_node() -> Control:
	return _core.scripts


## Returns [EditorAPI] node, this is first child of [Editor] node after internal childs. See
## [EditorAPI] for more information.
func get_editor_api() -> EditorAPI:
	return _editor.get_child(0)


## Return [PanelManager] node, this is a container with all panels, tabs, and [Editor]. See
## [PanelManager] for more information.
func get_panel_manager() -> PanelManager:
	return _core.panel_manager


## Sends an [b]Editor Notification[/b] using emit [signal SignalBus.editor_notification].
func send_notification(type := Notification.INFO, title: String = "", text: String = "") -> void:
	Signals.editor_notification.emit(type, title, text)


## Defines new command and updates [member _commands]. Commands shoud have a unique
## [param command_name] (otherwise this would be an overwrite of this command), you can generate
## [param key_string] with [method InputEventKey.as_text_keycode]. Command managers (like command
## pallete) will run [param callable] if user select this command. see [meber _commands] for
## commands saving structure.
func define_command(command_name: String, key_string: String, callable: Callable) -> void:
	commands[command_name] = [key_string, callable]


## Returns all commands saved in [member _commands].
func get_command_list() -> Dictionary:
	return commands


## Returns [code]true[/code] if there is unsaved change, when opened file have unsaved change a star
## ([code]*[/code]) will append to its name. (See also [method get_file_name])
func has_unsaved_change() -> bool:
	return get_file_name().ends_with("*")


## Returns last stored file path in [constant FileDatabase.RECENT_FILES_DATA] or [code]""[/code].
func get_last_file_path() -> String:
	if not FileAccess.file_exists(SLib.globalize_path(FileDatabase.RECENT_FILES_DATA)):
		return ""
	var file_access = FileAccess.open(FileDatabase.RECENT_FILES_DATA, FileAccess.READ)
	var recent_files_list = file_access.get_as_text().split("\n", false)
	file_access.close()

	if recent_files_list:
		return recent_files_list[0]

	return ""


func load_resource(path: String) -> Resource:
	return load(SLib.globalize_path(path))


func load_resources_threaded(paths: PackedStringArray, for_each: Callable, after_all := Callable()) -> void:
	var loader := ThreadedLoader.new()
	add_child(loader)
	loader.initialize(paths, for_each, after_all)
	loader.start()


class ThreadedLoader extends Node:
	var _pending := PackedStringArray()
	var _for_each: Callable
	var _after_all: Callable
	func initialize(paths: PackedStringArray, for_each: Callable, after_all := Callable()) -> void:
		for p in paths:
			_pending.append(p)
		_for_each = for_each
		_after_all = after_all

	func start() -> void:
		for p in _pending:
			ResourceLoader.load_threaded_request(p, "", true)

		_monitor_loading()

	func _monitor_loading() -> void:
		while _pending.size():
			for path in _pending:
				var status := ResourceLoader.load_threaded_get_status(path)
				if status == ResourceLoader.THREAD_LOAD_LOADED:
					var res := ResourceLoader.load_threaded_get(path)
					_pending.remove_at(_pending.find(path))
					_for_each.call(path, res)
			await get_tree().process_frame
		if _after_all:
			_after_all.call()
		queue_free()
