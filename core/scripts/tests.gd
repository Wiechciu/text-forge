extends Node

const DISABLE_ALL := false
const PERFORMANCE_TEST := true

func _ready() -> void:
	if not OS.has_feature("editor"):
		queue_free()
		return
	if DISABLE_ALL:
		queue_free()
		return
	if PERFORMANCE_TEST:
		add_child(load("res://tests/performance.gd").new())
