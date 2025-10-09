extends Node

@warning_ignore_start("unused_signal")
signal open_started
signal search_started

const DISABLE_ALL := false
const PERFORMANCE_ALL := true
const PERFORMANCE_STARTUP := true
const PERFORMANCE_OPEN_FILE := true

func _ready() -> void:
	if DISABLE_ALL:
		return
	if PERFORMANCE_ALL:
		add_child(load("res://tests/performance.gd").new(PERFORMANCE_STARTUP, PERFORMANCE_OPEN_FILE))
