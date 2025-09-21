extends Window

const PACKAGE_ITEM_PATH = "res://action_scripts/scenes/package_item.tscn"
const MP_HOST = "https://raw.githubusercontent.com/text-forge/mp/refs"
const PACKAGES_INFORMATION = "packages.json"
const PACK_INFORMATION = "pack.json"
const THEME_LOADER_ID = "1"
const EDITOR_API_ID = "2"
const EXTENSION_SYSTEM_ID = "1"

@export var request: HTTPRequest
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

var PackageItem := load(SLib.globalize_path(PACKAGE_ITEM_PATH))
var info: Array
var version: String

func _ready() -> void:
	version = version_edit.text
	if request.request_completed.is_connected(_on_packages_info_request_completed):
		request.request_completed.disconnect(_on_packages_info_request_completed)
	request.request_completed.connect(_on_packages_info_request_completed, ConnectFlags.CONNECT_ONE_SHOT)
	var err := request.request(MP_HOST.path_join(version).path_join(PACKAGES_INFORMATION))
	if err:
		Global.send_notification(Global.Notification.ERROR, "Failed to request marketplace infromation!", "Error code: " + str(err))
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

	if request.request_completed.is_connected(_complete_package_information):
		request.request_completed.disconnect(_complete_package_information)
	request.request_completed.connect(_complete_package_information.bind(pack_info), ConnectFlags.CONNECT_ONE_SHOT)
	var err := request.request(MP_HOST.path_join(version).path_join("packages").path_join(pack_info["id"]).path_join(PACK_INFORMATION))
	if err:
		Global.send_notification(Global.Notification.ERROR, "Failed to request package information file!", "Error code: " + str(err))

	SLib.free_all_children(i_tags)
	install_button.disabled = true

	i_name.text = pack_info["name"]
	i_author.text = pack_info["author"]
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
	if response_code != 200:
		Global.send_notification(Global.Notification.ERROR, "Failed to connect to marketplace!", "Package information request failed. Response code: " + str(response_code))
		return
	var _info = JSON.parse_string(body.get_string_from_utf8())
	match pack_info["category"]:
		"themes":
			install_button.text = "Install" + (" (!)" if _info["theme_loader_id"] != THEME_LOADER_ID else "")
			install_button.tooltip_text = "Install"  if _info["theme_loader_id"] == THEME_LOADER_ID else "Theme "
			install_button.disabled = true
		"modes":
			pass
		"extensions":
			pass
		_:
			Global.send_notification(Global.Notification.ERROR, "Invalid package category!")
