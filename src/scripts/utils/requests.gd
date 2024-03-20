class_name Requests
extends RefCounted


static func get_req(
		url: String,
		custom_headers: PackedStringArray = [],
		retry_on_503 := 5,
		rate_limiter: Object = null
) -> HTTPResponse:
	if rate_limiter != null and rate_limiter.has_method("wait"):
		await rate_limiter.wait(Config)
	var request := HTTPRequest.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(request)
	var resp: HTTPResponse
	var retry := retry_on_503 + 1
	if retry < 1:
		retry = 1
	while retry:
		var err = request.request(url, custom_headers)
		if err:
			breakpoint

		resp = HTTPResponse.from_signal(await request.request_completed)
		if resp.err:
			breakpoint
		if resp.code != 200:
			resp.err = -1

		if resp.err:
			retry -= 1
		else:
			retry = 0

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
		return ret

	func json():
		return JSON.parse_string(text)
