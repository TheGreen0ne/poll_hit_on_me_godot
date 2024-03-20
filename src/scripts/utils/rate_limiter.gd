class_name RateLimiter
extends Node

const LIMITERS_NAME_FMT = "rate_limiter_{0}"
const LIMITERS_PATH_FMT = "/root/" + LIMITERS_NAME_FMT

var _queue: Array[Waitee] = []
var _timer: Timer 


static func get_limiter(rate: float) -> RateLimiter:
	var period_usec := int(1_000_000.0 / rate)
	var root := (Engine.get_main_loop() as SceneTree).root
	var limiter := root.get_node_or_null(LIMITERS_PATH_FMT.format([period_usec])) as RateLimiter
	if limiter == null:
		limiter = RateLimiter.new()
		limiter.name = LIMITERS_NAME_FMT.format([period_usec])
		root.add_child(limiter)
		var timer := Timer.new()
		timer.name = "timer"
		limiter.add_child(timer)
		limiter._timer = timer
		timer.wait_time = 1.0 / rate
	return limiter


func wait(bindee: Node) -> Signal:
	var waitee := Waitee.new().bind_node(bindee)
	_queue.push_back(waitee)

	_start_dequeueing()

	return waitee.finished


func _start_dequeueing() -> void:
	if not _timer.is_stopped():
		return
	_timer.start()
	# return the signal so it can be connected before it is emitted
	await get_tree().process_frame
	while len(_queue) > 0:
		var waitee := _queue.pop_front() as Waitee
		if not waitee.is_valid():
			continue
		waitee.finished.emit()
		await _timer.timeout
	_timer.stop()


class Waitee extends RefCounted:
	signal finished
	var bound_node: Node
	
	func bind_node(n: Node) -> Waitee:
		bound_node = n
		return self
	
	func is_valid() -> bool:
		return (is_instance_valid(bound_node) 
				and not bound_node.is_queued_for_deletion())
