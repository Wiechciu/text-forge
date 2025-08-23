extends Node

func _ready() -> void:
	var start_time := Time.get_ticks_msec()

	await get_tree().process_frame

	var end_time := Time.get_ticks_msec()
	var duration = end_time - start_time
	print("Startup time (msec): ", duration)
	Tests.open_started.connect(_monitor_open)
	Tests.search_started.connect(_monitor_search)


func _monitor_search() -> void:
	var start_time := Time.get_ticks_msec()

	await Global.get_editor().caret_changed

	var end_time := Time.get_ticks_msec()
	var duration = end_time - start_time
	print("Search Delay (msec): ", duration)


func _monitor_open() -> void:
	var start_time := Time.get_ticks_msec()

	await Signals.check_options

	var end_time := Time.get_ticks_msec()
	var duration = end_time - start_time
	print("Time to Open File (msec): ", duration)


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	if not Global.get_editor().has_focus():
		return
	event = event as InputEventKey
	if not event.pressed:
		return
	if not OS.is_keycode_unicode(event.keycode):
		return

	var start_time := Time.get_ticks_usec()

	await Global.get_editor().text_changed

	var end_time := Time.get_ticks_usec()
	var duration = end_time - start_time
	if duration > 10000:
		return
	print("Type delay (usec): ", duration)
