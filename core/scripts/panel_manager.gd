class_name PanelManager
extends HBoxContainer
## Panel manager node in scene.
##
## This is panel manager for panel support feature, this is structure of panel related nodes:
## [codeblock lang=text]
## ┠╴PanelManager
## ┃  ┠╴LeftTab
## ┃  ┠╴LeftSpliter
## ┃  ┃  ┠╴LeftPanel
## ┃  ┃  ┖╴RightSpliter
## ┃  ┃     ┠╴BottomSpliter
## ┃  ┃     ┃  ┠╴Editor
## ┃  ┃     ┃  ┃  ┖╴API
## ┃  ┃     ┃  ┖╴BottomPanel
## ┃  ┃     ┖╴RightPanel
## ┃  ┖╴RightTab
## ┖╴BottomTab
## [/codeblock]
## Nodes with [code]Tab[/code] suffix are [ItemList]s with a item for each panel for handle panel chanfing.[br]
## Nodes with [code]Spliter[/code] suffix are [SplitContainer]s for handle panel sizes and open/close.[br]
## Nodes with [code]Panel[/code] suffix are [TabContainer]s with panels as children for show panels.

## Panel IDs.
enum Panels {
	## Left panel.
	LEFT,
	## Right panel.
	RIGHT,
	## Bottom panel.
	BOTTOM,
}

## LeftTab node, see class description for more information.
@export var tab_left: ItemList
## RightTab node, see class description for more information.
@export var tab_right: ItemList
## BottomTab node, see class description for more information.
@export var tab_bottom: ItemList
## LeftSpliter node, see class description for more information.
@export var spliter_left: HSplitContainer
## RightSpliter node, see class description for more information.
@export var spliter_right: HSplitContainer
## BottomSpliter node, see class description for more information.
@export var spliter_bottom: VSplitContainer
## LeftPanel node, see class description for more information.
@export var panel_left: TabContainer
## RightPanel node, see class description for more information.
@export var panel_right: TabContainer
## BottomPanel node, see class description for more information.
@export var panel_bottom: TabContainer
## Panels data
var panels := {
	Panels.LEFT: {"size": 200, "closed": true, "panels": {}, "last_tab": 0},
	Panels.RIGHT: {"size": 200, "closed": true, "panels": {}, "last_tab": 0},
	Panels.BOTTOM: {"size": 200, "closed": true, "panels": {}, "last_tab": 0},
}

func _ready() -> void:
	_load_layout()

	# handle window size changing
	spliter_left.item_rect_changed.connect(_apply_split)
	spliter_right.item_rect_changed.connect(_apply_split)
	spliter_bottom.item_rect_changed.connect(_apply_split)

	# handle spliter draging
	spliter_left.dragged.connect(func(offset):
		panels[Panels.LEFT].size = offset
		panels[Panels.LEFT].closed = offset == 0
		_apply_split()
	)
	spliter_right.dragged.connect(func(offset):
		panels[Panels.RIGHT].size = spliter_right.size.x - offset
		panels[Panels.RIGHT].closed = offset + 10 >= spliter_right.size.x
		_apply_split()
	)
	spliter_bottom.dragged.connect(func(offset):
		panels[Panels.BOTTOM].size = spliter_bottom.size.y - offset
		panels[Panels.BOTTOM].closed = offset + 10 >= spliter_bottom.size.y
		_apply_split()
	)

	# handle panel changing
	tab_left.item_selected.connect(_handle_panel.bind(Panels.LEFT))
	tab_right.item_selected.connect(_handle_panel.bind(Panels.RIGHT))
	tab_bottom.item_selected.connect(_handle_panel.bind(Panels.BOTTOM))

	# save last tabs for reopen panels
	panel_left.tab_selected.connect(func(tab): if tab != -1: panels[Panels.LEFT]["last_tab"] = tab)
	panel_right.tab_selected.connect(func(tab): if tab != -1: panels[Panels.RIGHT]["last_tab"] = tab)
	panel_bottom.tab_selected.connect(func(tab): if tab != -1: panels[Panels.BOTTOM]["last_tab"] = tab)

	get_window().close_requested.connect(_save_layout)

	_load_panels()


func _save_layout() -> void:
	var config := ConfigFile.new()
	config.load(FileDatabase.DATA_FILE)
	config.set_value("panels", "layout_data", panels)
	config.save(FileDatabase.DATA_FILE)


func _load_layout() -> void:
	var config := ConfigFile.new()
	config.load(FileDatabase.DATA_FILE)
	panels = config.get_value("panels", "layout_data", panels)


func _load_panels() -> void:
	for panel in DirAccess.get_directories_at("res://data/panels"):
		var config = ConfigFile.new()
		config.load("res://data/panels/{0}/panel.cfg".format([panel]))
		var place = config.get_value("panel", "place")
		var converted: int
		if place == "R":
			converted = Panels.RIGHT
		elif place == "B":
			converted = Panels.BOTTOM
		else: # Also panels with invalid place
			converted = Panels.LEFT
		add_panel(converted, ResourceLoader.load("res://data/panels/{0}/panel.tscn".format([panel])).instantiate(), ResourceLoader.load("res://data/panels/{0}/icon.png".format([panel])))


func _handle_panel(selected: int, panel_id: int) -> void:
	var current_panel
	match panel_id:
		Panels.LEFT:
			current_panel = Panels.LEFT
		Panels.RIGHT:
			current_panel = panel_right
		Panels.BOTTOM:
			current_panel = panel_bottom
	if current_panel.current_tab == selected and panels[panel_id].closed == false:
		panels[panel_id].closed = true
		_apply_split()
		return
	current_panel.current_tab = selected
	if panels[panel_id].closed == true:
		panels[panel_id].closed = false
		if panels[panel_id].size <= 10: panels[panel_id].size = 200
		_apply_split()


func _apply_split() -> void:
	spliter_left.split_offset = max(panels[Panels.LEFT].size, panel_left.get_child(panel_left.current_tab).custom_minimum_size.x if panel_left.get_child_count() else 0)
	if panels[Panels.LEFT].closed or panel_left.get_child_count() == 0:
		spliter_left.split_offset = 0
		panel_left.current_tab = -1
	else:
		panel_left.current_tab = panels[Panels.LEFT]["last_tab"]
	spliter_right.split_offset = max(spliter_right.size.x - panels[Panels.RIGHT].size, panel_right.get_child(panel_right.current_tab).custom_minimum_size.x if panel_right.get_child_count() else 0)
	if panels[Panels.RIGHT].closed or panel_right.get_child_count() == 0:
		spliter_right.split_offset = spliter_right.size.x
		panel_right.current_tab = -1
	else:
		panel_right.current_tab = panels[Panels.RIGHT]["last_tab"]
	spliter_bottom.split_offset = max(spliter_bottom.size.y - panels[Panels.BOTTOM].size, panel_bottom.get_child(panel_bottom.current_tab).custom_minimum_size.y if panel_bottom.get_child_count() else 0)
	if panels[Panels.BOTTOM].closed or panel_bottom.get_child_count() == 0:
		spliter_bottom.split_offset = spliter_bottom.size.y
		panel_bottom.current_tab = -1
	else:
		panel_bottom.current_tab = panels[Panels.BOTTOM]["last_tab"]


func add_panel(location: int, panel: Control, icon: Texture2D) -> void:
	var current_tab
	var current_panel
	match location:
		Panels.LEFT:
			current_tab = tab_left
			current_panel = Panels.LEFT
		Panels.RIGHT:
			current_tab = tab_right
			current_panel = panel_right
		Panels.BOTTOM:
			current_tab = tab_bottom
			current_panel = panel_bottom
	var index
	index = current_tab.add_icon_item(icon)
	panel.index = index
	if index != current_panel.get_child_count():
		current_tab.remove_item(index)
		Signals.editor_notification.emit(2, "There is a bug in left panel", "")
		return
	current_panel.add_child(panel)
	panels[location].panels[index] = panel


func change_panel_icon(location: int, index: int, icon: Texture2D) -> void:
	var current_tab: ItemList
	match location:
		Panels.LEFT:
			current_tab = tab_left
		Panels.RIGHT:
			current_tab = tab_right
		Panels.BOTTOM:
			current_tab = tab_bottom
	current_tab.set_item_icon(index, icon)


func show_panel(location: int, index: int) -> void:
	if panels[location]["closed"] or panels[location]["last_tab"] != index:
		_handle_panel(index, location)
