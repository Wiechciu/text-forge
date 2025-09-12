extends Window

@export var project_item: Button
@export var project_list: VBoxContainer

func _ready() -> void:
	for i in Project.recent_menu.get_item_count():
		var item: Button = project_item.duplicate()
		var config := ConfigFile.new()
		config.load(Project.recent_menu.get_item_text(i))
		item.get_node(^"Panel/HBox/Icon").texture = ImageTexture.create_from_image(Image.load_from_file(config.get_value("project", "icon", "")))
		item.get_node(^"Panel/HBox/Labels/Name").text = config.get_value("project", "name")
		item.get_node(^"Panel/HBox/Labels/Modified").text = config.get_value("project", "modified")
		item.pressed.connect(_open_project.bind(Project.recent_menu.get_item_text(i)))
		item.show()
		project_list.add_child(item)


func _open_project(path: String) -> void:
	Project.load_project(path)
	queue_free()
