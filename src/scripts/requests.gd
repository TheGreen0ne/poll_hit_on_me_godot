class_name Requests
extends RefCounted


static func get_req(url: String, custom_headers: PackedStringArray = []) -> HTTPResponse:
	
	var request := HTTPRequest.new()
	Config.add_child(request)
	var err = request.request(url, custom_headers)
	if err:
		breakpoint
	
	var resp := HTTPResponse.from_signal(await request.request_completed)
	
	request.queue_free()
	return resp


class HTTPResponse:
	var err: int
	var code: int
	var headers: PackedStringArray
	var body: PackedByteArray
	var text: String:
		get: return body.get_string_from_utf8()
	
	static func from_signal(signal_request_completed: Array) -> HTTPResponse:
		var ret := HTTPResponse.new()
		ret.err = signal_request_completed[0]
		ret.code = signal_request_completed[1]
		ret.headers = signal_request_completed[2]
		ret.body = signal_request_completed[3]
		if ret.err or ret.code != 200:
#			breakpoint
			ret.err = -1
		return ret

	func json():
		return JSON.parse_string(text)
