extends Node

var start_time := 0

func _ready() -> void:
	start_time = Time.get_ticks_msec()

	await get_tree().process_frame

	var end_time = Time.get_ticks_msec()
	var duration = end_time - start_time
	print("Startup time (msec): ", duration)
