extends Node
class_name GlobalAccess

## Global access way to all parts of Text Forge
##
## You can access to this class using [code]Global[/code] autoload.

var commands := {}
var window_manager := WindowManager.new()

# Inspired by: https://gist.github.com/danijmn/75f83973315dd38fc2b288cf2ff582ea
class WindowManager extends Node:

	## The path of the ConfigFile where the window settings will be saved.
	const FILE_PATH: String = "user://display.cfg"

	## The section within the ConfigFile where the window settings will be saved.
	const WINDOW_SECTION_ID: String = "Window"

	@onready var _window: Window = get_window()

	var _last_mode_except_minimized: Window.Mode
	var last_mode_except_minful: Window.Mode

	func _ready() -> void:
		if Engine.is_embedded_in_editor():
			return

		_window.close_requested.connect(_save_window_settings)

		_load_window_settings()
		if _window.mode != Window.MODE_MINIMIZED:
			_last_mode_except_minimized = _window.mode
			if _window.mode != Window.MODE_FULLSCREEN:
				last_mode_except_minful = _window.mode


	func _process(_delta: float) -> void:
		if Engine.is_embedded_in_editor():
			return

		if _window.mode != Window.MODE_MINIMIZED:
			_last_mode_except_minimized = _window.mode
			if _window.mode != Window.MODE_FULLSCREEN:
				last_mode_except_minful = _window.mode


	func _load_window_settings() -> void:
		if Engine.is_embedded_in_editor():
			return

		var config = ConfigFile.new()
		if config.load(FILE_PATH) != OK:
			return
		if !config.has_section(WINDOW_SECTION_ID):
			return

		var screen = config.get_value(WINDOW_SECTION_ID, "screen", "N/A")
		if screen is int && screen >= 0 && screen < DisplayServer.get_screen_count():
			_window.current_screen = screen

		var mode = config.get_value(WINDOW_SECTION_ID, "mode", "N/A")
		if mode is Window.Mode:
			match mode:
				Window.MODE_MAXIMIZED, Window.MODE_FULLSCREEN, Window.MODE_EXCLUSIVE_FULLSCREEN:
					_window.mode = mode
				Window.MODE_WINDOWED:
					var usable_rect: Rect2i = DisplayServer.screen_get_usable_rect(_window.current_screen)
					var size = config.get_value(WINDOW_SECTION_ID, "size", "N/A")
					if size is not Vector2i || size.x < _window.min_size.x || size.y < _window.min_size.y:
						_window.mode = Window.MODE_WINDOWED
					elif size.x > usable_rect.size.x && size.y > usable_rect.size.y:
						_window.mode = Window.MODE_MAXIMIZED
					else:
						_window.mode = Window.MODE_WINDOWED
						var position = config.get_value(WINDOW_SECTION_ID, "position", "N/A")
						if position is Vector2i:
							var safe_end: Vector2i = usable_rect.end.min(position + size)
							var safe_position: Vector2i = usable_rect.position.max(safe_end - size)
							var safe_size: Vector2i = _window.min_size.max(safe_end - safe_position)
							_window.position = safe_position
							_window.size = safe_size


	func _save_window_settings() -> void:
		if Engine.is_embedded_in_editor():
			return

		var config = ConfigFile.new()
		config.set_value(WINDOW_SECTION_ID, "screen", _window.current_screen)
		if _window.mode != Window.MODE_MINIMIZED:
			config.set_value(WINDOW_SECTION_ID, "mode", _window.mode)
		else:
			config.set_value(WINDOW_SECTION_ID, "mode", _last_mode_except_minimized)
		config.set_value(WINDOW_SECTION_ID, "size", _window.size)
		config.set_value(WINDOW_SECTION_ID, "position", _window.position)
		config.save(FILE_PATH)


func _ready() -> void:
	add_child(window_manager)


func get_window_mode_before_fullscreen() -> Window.Mode:
	return window_manager.last_mode_except_minful

## Returns currently opened file path
func get_file_path() -> String:
	return get_core().file_label.tooltip_text

## Returns currently opened file name
func get_file_name() -> String:
	return get_core().file_label.text

## Sets [param path] as opened file path
## [br][b]Note:[/b] This action isn't loading!
func set_file_path(path: String) -> void:
	get_core().file_label.tooltip_text = path

## Sets [param file_name] as opened file name
func set_file_name(file_name: String) -> void:
	get_core().file_label.text = file_name

## Returns [Editor] node
## [br][b][color=red]Caution:[/color] Some actions on this node can make crash![/b]
func get_editor() -> Editor:
	return get_core().editor

## Returns current text in editor
func get_editor_text() -> String:
	return get_editor().text

## Sets [param text] to editor
## [br][b]Note:[/b] This action will move caret to start of editor, so set caret pos after this is recommended
func set_editor_text(text: String) -> void:
	get_editor().text = text

## Will disable the editor
func set_editor_disabled(disabled: bool) -> void:
	get_editor().editable = not disabled

## Returns [code]true[/code] if editor is disabled
func is_editor_disabled() -> bool:
	return not get_editor().editable

## Returns [Core] node
func get_core() -> Core:
	return get_node("/root/Main")

## Returs node in [Core] that keep action scripts
func get_scripts_node() -> Node:
	return get_core().scripts

## Returns [EditorAPI] node
func get_editor_api() -> EditorAPI:
	return get_editor().get_child(0)

## Return [PanelManager] note
func get_panel_manager() -> PanelManager:
	return get_core().panel_manager

func send_notification(type: int = 0, title: String = "", text: String = "") -> void:
	Signals.editor_notification.emit(type, title, text)

func define_command(command_name: String, key_string: String, callable: Callable) -> void:
	commands[command_name] = [key_string, callable]

func get_command_list() -> Dictionary:
	return commands

func has_change() -> bool:
	return Global.get_file_name().ends_with("*")
