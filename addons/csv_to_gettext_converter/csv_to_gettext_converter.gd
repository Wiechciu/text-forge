@tool
extends EditorPlugin


var context_menu_plugin_instance: EditorContextMenuPlugin


func _enter_tree() -> void:
	context_menu_plugin_instance = preload("res://addons/csv_to_gettext_converter/context_menu.gd").new()
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM, context_menu_plugin_instance)
	print("CSV to gettext converter loaded.")

func _exit_tree() -> void:
	remove_context_menu_plugin(context_menu_plugin_instance)
	print("CSV to gettext converter unloaded.")
