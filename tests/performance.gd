extends Node

var start_time: int
var end_time: int

func _ready() -> void:
	start_time = Time.get_ticks_msec()

	get_tree().process_frame.connect(_on_first_frame, CONNECT_ONE_SHOT)
	Tests.open_started.connect(_monitor_open)
	Tests.search_started.connect(_monitor_search)

	await Global.get_panel_manager().load_completed

	print("Panels loading (msec): " + str(Time.get_ticks_msec() - end_time))

	await Signals.check_options

	print("Action scripts loading (msec): " + str(Time.get_ticks_msec() - end_time))
	print("Total startup (msec): " + str(Time.get_ticks_msec() - start_time))


func _on_first_frame():
	end_time = Time.get_ticks_msec()
	var duration := end_time - start_time
	print("Startup time (msec): ", duration)


func _monitor_search() -> void:
	var start := Time.get_ticks_msec()

	await Global.get_editor().caret_changed

	var end := Time.get_ticks_msec()
	var duration = end - start
	print("Search Delay (msec): ", duration)


func _monitor_open() -> void:
	var start := Time.get_ticks_msec()

	await Signals.check_options

	var end := Time.get_ticks_msec()
	var duration = end - start
	print("Time to Open File (msec): ", duration)
