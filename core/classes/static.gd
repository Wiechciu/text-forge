class_name Static
extends Object

const EDITOR_VERSION = "0.1.0"

static func map_array_to_int(array: Array) -> Array[int]:
	return Array(array.map(func(e): return int(e)), TYPE_INT, "", null)
