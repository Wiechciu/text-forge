extends Window

@export var tree: Tree
@export var tabs: TabContainer
@export var item: PanelContainer
@export var extensions_list: HFlowContainer

func _ready() -> void:
	Extensions.extensions_loaded.connect(_reopen_request)
	# setup tree based on tabs

	# add root
	tree.create_item()

	for child in tabs.get_children():
		var page := tree.create_item()
		page.set_text(0, child.name.capitalize())

	if tree.get_root().get_child_count():
		tree.set_selected(tree.get_root().get_first_child(),0)


	load_extensions()


func load_extensions() -> void:
	for xtn: String in Extensions.extensions:
		extensions_list.add_child(item.duplicate().setup(xtn, Extensions.extensions[xtn]["name"], xtn in Extensions.enabled_extensions))

	if not extensions_list.get_child_count():
		var label := Label.new()
		label.text = "There is no extension!"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		extensions_list.add_child(label)


func _on_close_requested() -> void:
	queue_free()


func _on_tree_item_selected() -> void:
	tabs.current_tab = tree.get_selected().get_index()


func _on_install_pressed() -> void:
	add_child(Factory.file_dialog(FileDialog.FILE_MODE_OPEN_FILE, FileDialog.ACCESS_FILESYSTEM, ["*.tfx,*.zip;Text Forge Extensions;application/zip"], _install_extension, true, OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)))


func _install_extension(path: String) -> void:
	Extensions.install_extension(path)

func _reopen_request() -> void:
	Global.send_notification(Global.Notification.INFO, "Please reopen extensions window!", "Extensions was (re)loaded, reopen extensions window to see changes.")
