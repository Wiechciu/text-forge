extends Node
## Keeps useful and helper functions for global access.

func wait(time: float = 0) -> void:
	if time != 0:
		await get_tree().create_timer(time).timeout
	else:
		await get_tree().process_frame


## Loads a resource with globalizing [param path].
func load_resource(path: String) -> Resource:
	if path.is_empty():
		return null
	return ResourceLoader.load(S.globalize_path(path))


## Creates a new [GlobalAccess.ThreadedLoader] node and pass arguments to it. Calls [method GlobalAccess.ThreadedLoader.initialize]
## and [method GlobalAccess.ThreadedLoader.start] after add loader to tree.
func load_resources_threaded(paths: PackedStringArray, for_each: Callable, after_all := Callable()) -> void:
	var loader := ThreadedLoader.new()
	add_child(loader)
	loader.initialize(paths, for_each, after_all)
	loader.start()


## Threaded resource loader for multiple resources.
##
## This class will request threaded loading for all given resources and handle loaded resources in
## loading order, so resource that was loaded faster will handle before others.
class ThreadedLoader extends Node:
	var _pending: Dictionary[String, bool]= {}
	var _for_each: Callable
	var _after_all: Callable

	## Initializes threaded loader for given [param paths], you can do this multiple times to add
	## all files you need, but each time will overwrite [param for_each] and [param after_all] values.[br]
	## [param for_each]: a [Callable] wich will be called for each loader with [code]resource_path, loaded_resource[/code]
	## parameters as [String] and [Resource]. Use this to use loaded resource.
	## [param
	func initialize(paths: PackedStringArray, for_each: Callable, after_all := Callable()) -> void:
		for p in paths:
			_pending[p] = false
		_for_each = for_each
		_after_all = after_all

	func start() -> void:
		for p in _pending:
			ResourceLoader.load_threaded_request(p, "", true)
		_monitor_loading()

	func _monitor_loading() -> void:
		while _pending.values().any(func(s): return not s):
			for path in _pending:
				if _pending[path]:
					continue
				var status := ResourceLoader.load_threaded_get_status(path)
				match status:
					ResourceLoader.THREAD_LOAD_LOADED:
						var res := ResourceLoader.load_threaded_get(path)
						_pending[path] = true
						_for_each.call(path, res)
					ResourceLoader.THREAD_LOAD_IN_PROGRESS:
						pass
					_:
						push_error("Threaded load failed for {0} (status: {1})".format([path, str(status)]))
						_pending[path] = true
						_for_each.call(path, null)
			await get_tree().process_frame
		if _after_all:
			_after_all.call()
		queue_free()
