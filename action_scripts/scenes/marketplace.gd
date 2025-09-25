extends Window

enum CompatibilityStatus {
	COMPATIBLE,
	INCOMPATIBLE,
	UNVERIFIED
}

const PACKAGE_ITEM_PATH = "res://action_scripts/scenes/package_item.tscn"
const MP_HOST = "https://raw.githubusercontent.com/text-forge/mp/refs"
const PACKAGES_INFORMATION = "packages.json"
const PACK_INFORMATION = "pack.json"

@export var packages: VBoxContainer
@export var version_edit: LineEdit
@export var i_name: Label
@export var i_author: Label
@export var i_category: Label
@export var i_version: Label
@export var i_min_editor_version: Label
@export var i_dates: Label
@export var i_tags: HFlowContainer
@export var i_description: Label
@export var i_images: HBoxContainer
@export var infomration_popup: Window
@export var install_button: Button
@export var search: LineEdit
@export var filter: OptionButton

var PackageItem := load(SLib.globalize_path(PACKAGE_ITEM_PATH))
var info: Array
var version: String

func _ready() -> void:
	version = version_edit.text
	if NetSuite.http_request(
		_on_packages_info_request_completed,
		{ "url": MP_HOST.path_join(version).path_join(PACKAGES_INFORMATION) }
	) == null:
		SLib.free_all_children(packages)


func _on_packages_info_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	SLib.free_all_children(packages)
	if response_code != 200:
		Global.send_notification(Global.Notification.ERROR, "Failed to connect to marketplace!", "Response code: " + str(response_code))
		return
	info = JSON.parse_string(body.get_string_from_utf8())
	for p in info:
		var n: PanelContainer = PackageItem.instantiate()
		n.setup(p["id"], p["name"], p["version"], p["category"], p["author"], p["tags"], p["description"], p["updated"], p["created"], p["editor_version_min"], _on_package_information_requested)
		packages.add_child(n)


func _on_package_information_requested(id: String) -> void:
	var pack_info: Dictionary = info.filter(func(p): return p["id"] == id)[0]

	i_description.text = "Loading..."
	SLib.free_all_children(i_images)
	NetSuite.http_request(
		_complete_package_information.bind(pack_info),
		{ "url": MP_HOST.path_join(version).path_join("packages").path_join(pack_info["id"]).path_join(PACK_INFORMATION) }
	)

	SLib.free_all_children(i_tags)
	install_button.disabled = true

	i_name.text = pack_info["name"]
	i_author.text = "by " + pack_info["author"]
	i_category.text = pack_info["category"]
	i_version.text = pack_info["version"]
	i_min_editor_version.text = "Text Forge {0}+".format([pack_info["editor_version_min"]])
	i_dates.text = pack_info["updated"] + " | " + pack_info["created"]
	for t in pack_info["tags"]:
		var tag := Label.new()
		tag.text = t
		tag.set_theme_type_variation("PackageBadgeLabel")
		i_tags.add_child(tag)
	infomration_popup.show()


func _complete_package_information(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, pack_info: Dictionary) -> void:
	if install_button.pressed.is_connected(_install_package):
		install_button.pressed.disconnect(_install_package)
	if response_code != HTTPClient.RESPONSE_OK:
		Global.send_notification(Global.Notification.ERROR, "Failed to connect to marketplace!", "Package information request failed. Response code: " + str(response_code))
		return
	var _info = JSON.parse_string(body.get_string_from_utf8())
	match get_compatibility_status(_info["compatible_versions"]):
		CompatibilityStatus.INCOMPATIBLE:
			install_button.text = "Install"
			install_button.tooltip_text = "This package isn't compatible with your editor version!"
			install_button.disabled = true
		CompatibilityStatus.UNVERIFIED:
			install_button.text = "Install (!)"
			install_button.tooltip_text = "This package isn't tested with your editor version! Use with caution."
			install_button.disabled = false
		CompatibilityStatus.COMPATIBLE:
			install_button.text = "Install"
			install_button.tooltip_text = ""
			install_button.disabled = false
	i_description.text = _info["description"]
	if _info.has("images"):
		for i in _info["images"]:
			NetSuite.http_request(
				_add_image,
				{ "url": MP_HOST.path_join(version).path_join("packages").path_join(pack_info["id"]).path_join(i) }
			)
	install_button.pressed.connect(_install_package.bind(pack_info, _info))


func _install_package(pack_info: Dictionary, _info: Dictionary) -> void:
	var path_to_download := "user://_temp_mode.tfmode"
	if pack_info["category"] == "themes":
		path_to_download = FileDatabase.FOLDER_THEMES.path_join(_info["file"])
	if pack_info["category"] == "extension":
		path_to_download = "user://_temp_extension.tfx"
	var data_to_pass := {
		"name": pack_info["name"],
		"category": pack_info["category"],
		"file": path_to_download,
	}
	NetSuite.http_request(
		_complete_installation.bind(data_to_pass),
		{
			"url": MP_HOST.path_join(version).path_join("packages").path_join(pack_info["id"]).path_join(_info["file"]),
			"downloadfile": path_to_download
		}
	)
	Global.send_notification(Global.Notification.INFO, "Please don't close marketplace window!", "Downloading and installing package is in progress...")
	infomration_popup.hide()


func _complete_installation(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, data: Dictionary) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != HTTPClient.RESPONSE_OK:
		Global.send_notification(Global.Notification.ERROR, "Failed to download package!", "Result code: {0}\nResponse code: {1}".format([result, response_code]))
		return
	var path: String = data["file"]
	var downloaded := FileAccess.open(path, FileAccess.WRITE)
	downloaded.store_buffer(body)
	downloaded.close()
	match data["category"]:
		"extensions":
			var reader = ZIPReader.new()
			var err := reader.open(path)
			if err:
				Global.send_notification(Global.Notification.ERROR, "Can't load this extension file!", "Load {0} for install extension failed. Error code: {1}".format([path, str(err)]))
				return

			if not DirAccess.dir_exists_absolute(SLib.globalize_path(FileDatabase.FOLDER_EXTENSIONS)):
				DirAccess.make_dir_recursive_absolute(SLib.globalize_path(FileDatabase.FOLDER_EXTENSIONS))

			var root_dir = DirAccess.open(FileDatabase.FOLDER_EXTENSIONS)

			var files = reader.get_files()
			for file_path in files:
				if file_path.ends_with("/"):
					root_dir.make_dir_recursive(file_path)
					continue

				root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
				var file = FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
				var buffer = reader.read_file(file_path)
				file.store_buffer(buffer)

			Global.get_editor_api().reload_modes()
			Global.send_notification(Global.Notification.INFO, "Install extension completed.")
			add_child(Factory.confirmation_dialog("Unpack extension completed, Do you want to reload extensions to use it?", "Yes, Reload", "No, Later", "Do you want reload extensions?", Callable(), Extensions.setup_extensions))
		"modes":
			var reader = ZIPReader.new()
			var err := reader.open(path)
			if err:
				Global.send_notification(Global.Notification.ERROR, "Can't load this file!", "Load {0} for import mode or mode kit failed. Error code: {1}".format([path, str(err)]))
				return

			if not DirAccess.dir_exists_absolute(SLib.globalize_path("user://modes")):
				DirAccess.make_dir_absolute(SLib.globalize_path("user://modes"))
			var root_dir = DirAccess.open("user://")

			var files = reader.get_files()
			for file_path in files:
				if file_path.ends_with("/"):
					root_dir.make_dir_recursive(file_path)
					continue

				root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
				var file = FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
				var buffer = reader.read_file(file_path)
				file.store_buffer(buffer)

			Global.get_editor_api().reload_modes()
			Global.send_notification(Global.Notification.INFO, "Load mode / mode kit completed.")
		"themes":
			add_child(Factory.confirmation_dialog("Installing theme completed, Do you want to use it now?", "Yes", "No, Later", "Do you want use new theme?", Callable(), _change_theme.bind(path.get_file().get_basename())))
	Global.send_notification(Global.Notification.INFO, "Package installed!", "You can close marketplace window now.")


func _change_theme(t_name: String) -> void:
	Settings.set_setting("editor_ui", "theme_name", t_name)
	Signals.settings_changed.emit()


func _add_image(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != HTTPClient.RESPONSE_OK:
		Global.send_notification(Global.Notification.ERROR, "Failed to load package image!", "Result code: {0}\nResponse code: {1}".format([result, response_code]))
		return
	var image := Image.new()
	var err := image.load_png_from_buffer(body)
	if err:
		Global.send_notification(Global.Notification.ERROR, "Failed to load png image from buffer!", "Error code: " + str(err))
		return
	var texture = ImageTexture.create_from_image(image)
	var texture_rect = TextureRect.new()
	texture_rect.texture = texture
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	i_images.add_child(texture_rect)


func get_compatibility_status(compatible_versions: String) -> CompatibilityStatus:
	var editor_version: Array[int] = Static.map_array_to_int(Static.EDITOR_VERSION.split(".", false, 2))
	var regex := RegEx.new()
	regex.compile(r">(?<min_e>=?)(?<min>\d+\.\d+\.\d+)(?: <(?<max_e>=?)(?<max>\d+\.\d+\.\d+))? \|\| \?(?<unv>\d+\.\d+\.\d+)")
	var result := regex.search(compatible_versions)
	if regex.search(compatible_versions) == null:
		Global.send_notification(Global.Notification.ERROR, "Invalid package version information!", compatible_versions + " doesn't match with package version information pattern.")
		return CompatibilityStatus.INCOMPATIBLE
	if true: # Unverified versions check
		var unv := Static.map_array_to_int(result.get_string("unv").split(".", false, 2))
		if editor_version[0] > unv[0]:
			return CompatibilityStatus.UNVERIFIED
		elif editor_version[0] == unv[0]:
			if editor_version[1] > unv[1]:
				return CompatibilityStatus.UNVERIFIED
			elif editor_version[1] == unv[1]:
				if editor_version[2] >= unv[2]:
					return CompatibilityStatus.UNVERIFIED
	if true: # Minimum version check
		var minimum := Static.map_array_to_int(result.get_string("min").split(".", false, 2))
		var minimum_e := result.get_string("min_e") != ""
		if editor_version[0] < minimum[0]:
			return CompatibilityStatus.INCOMPATIBLE
		elif editor_version[0] == minimum[0]:
			if editor_version[1] < minimum[1]:
				return CompatibilityStatus.INCOMPATIBLE
			elif editor_version[1] == minimum[1]:
				if editor_version[2] < minimum[2]:
					return CompatibilityStatus.INCOMPATIBLE
				elif editor_version[2] == minimum[2] and not minimum_e:
					return CompatibilityStatus.INCOMPATIBLE
	if result.get_string("max") != "": # Maximum version check
		var maximum := Static.map_array_to_int(result.get_string("max").split(".", false, 2))
		var maximum_e := result.get_string("max_e") != ""
		if editor_version[0] > maximum[0]:
			return CompatibilityStatus.INCOMPATIBLE
		elif editor_version[0] == maximum[0]:
			if editor_version[1] > maximum[1]:
				return CompatibilityStatus.INCOMPATIBLE
			elif editor_version[1] == maximum[1]:
				if editor_version[2] > maximum[2]:
					return CompatibilityStatus.INCOMPATIBLE
				if editor_version[2] == maximum[2] and not maximum_e:
					return CompatibilityStatus.INCOMPATIBLE
	return CompatibilityStatus.COMPATIBLE


func _on_search_text_changed(new_text: String) -> void:
	for n: PanelContainer in packages.get_children():
		if ((n.n_category.text == filter.get_item_text(filter.get_item_index(filter.get_selected_id())).to_lower() or filter.get_selected_id() == 0)
			and (n.n_name.text.containsn(new_text) or new_text.is_empty())):
			n.visible = true
		else:
			n.visible = false


func _on_filter_item_selected() -> void:
	_on_search_text_changed(search.text)
