extends Node
## Helper for network tasks.

## Default value for [param auto_free_on] in [method http_request].
const DEFAULT_HTTP_AUTO_FREE: Array[HTTPClient.Status] = [
	HTTPClient.STATUS_CANT_CONNECT,
	HTTPClient.STATUS_CANT_RESOLVE,
	HTTPClient.STATUS_CONNECTION_ERROR,
	HTTPClient.STATUS_DISCONNECTED,
	HTTPClient.STATUS_TLS_HANDSHAKE_ERROR
]

## Child [HTTPRequest]s with their [param auto_free_on] values, use [method http_request] to make new items.
var http_requests: Dictionary[HTTPRequest, Array] = {}

func _process(delta: float) -> void:
	if http_requests.is_empty():
		return
	for hr in http_requests:
		if hr.get_http_client_status() in http_requests[hr]:
			hr.cancel_request()
			http_requests.erase(hr)
			remove_child(hr)
			hr.queue_free()


## Creates a new [HTTPRequest] and intiailizes it with these optioanl parameters:[br]
## َ    - [param callback]: [Callable] to connect to [signal HTTPRequest.request_completed].[br]
## َ    - [param request]: Optional request with keys:[br]
## َ        - [code]"url"[/code]: URL to request.[br]
## َ        - [code]"raw"[/code] (Optional, default [code]false[/code]): Uses [method HTTPRequest.request_raw] insted of [method HTTPRequest.request] when [code]true[/code].[br]
## َ        - [code]"custom_headers"[/code] (Optional, default is empty [PackedStringArray]): Custom headers to send request.[br]
## َ        - [code]"method"[/code] (Optional, default [constant HTTPClient.METHOD_GET]): Request method.[br]
## َ        - [code]"request_data_raw"[/code] (Optional, default empty [PackedByteArray]): Binary body when [code]"url"[/code] is [code]true[/code].[br]
## َ        - [code]"request_data"[/code] (Optional, default empty [String]): String body when [code]"url"[/code] is [code]false[/code] (default).[br]
## َ    - [param downloadfile]: The file to download into.[br]
## َ    - [param auto_free_on]: An [Array] of [enum HTTPClient.Status]es that will free this request.[br][br]
## [b]Note:[/b] All parameters are optional, but if you need to send a request in this function you should set a value for [param request] [code]"url"[/code] key.[br][br]
## [b]Note:[/b] [param auto_free_on] only works when you pass a valid [param request]. Otherwise, you should keep returned [HTTPRequest] yourself.[br][br]
## [b]See also:[/b] [HTTPRequest], [HTTPClient]
func http_request(callback := Callable(), request := {}, downloadfile := "", auto_free_on := DEFAULT_HTTP_AUTO_FREE) -> HTTPRequest:
	var hr := HTTPRequest.new()
	hr.download_file = downloadfile
	if callback.is_valid():
		hr.request_completed.connect(callback)
	if request.has("url"):
		add_child(hr)
		if request.get("raw", false):
			hr.request_raw(
				request.get("url"),
				request.get("custom_headers", PackedStringArray()),
				request.get("method", HTTPClient.METHOD_GET),
				request.get("request_data_raw", PackedByteArray())
			)
		else:
			hr.request(
				request.get("url"),
				request.get("custom_headers", PackedStringArray()),
				request.get("method", HTTPClient.METHOD_GET),
				request.get("request_data", String())
			)
		http_requests[hr] = auto_free_on
	return hr
