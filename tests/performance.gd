extends Node

var startup: bool
var open_file: bool

var start_time: int
var end_time: int

func _init(p_startup: bool, p_open_file: bool) -> void:
	startup = p_startup
	open_file = p_open_file


func _ready() -> void:
	if startup:
		start_time = Time.get_ticks_msec()
		get_tree().process_frame.connect(_on_first_frame, CONNECT_ONE_SHOT)

	if open_file:
		Tests.open_started.connect(_monitor_open)

	if startup:
		await Global.get_panel_manager().load_completed

		print("Panels loading (msec): " + str(Time.get_ticks_msec() - end_time))

		await Signals.check_options

		print("Main action scripts loading (msec): " + str(Time.get_ticks_msec() - end_time))
		print("Total startup (msec): " + str(Time.get_ticks_msec() - start_time))

		await Signals.check_options

		print("All action scripts loading (msec): " + str(Time.get_ticks_msec() - end_time))
		print("Total setup (msec): " + str(Time.get_ticks_msec() - start_time))


func _on_first_frame():
	end_time = Time.get_ticks_msec()
	var duration := end_time - start_time
	print("Startup time (msec): ", duration)


func _monitor_open() -> void:
	var start := Time.get_ticks_msec()

	await Signals.check_options

	var end := Time.get_ticks_msec()
	var duration = end - start
	print("Time to Open File (msec): ", duration)
