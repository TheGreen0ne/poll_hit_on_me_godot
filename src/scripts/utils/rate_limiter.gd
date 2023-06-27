class_name RateLimiter
extends Node

const LIMITERS_NAME_FMT = "rate_limiter_{0}"
const LIMITERS_PATH_FMT = "/root/" + LIMITERS_NAME_FMT

var _period_usec := 500_000
var _queue_size := 0
var _start_time := 0 


static func get_limiter(rate: float) -> RateLimiter:
	var period_usec := int(1_000_000.0 / rate)
	var limiter := Config.get_node_or_null(LIMITERS_PATH_FMT.format([period_usec])) as RateLimiter
	if limiter == null:
		limiter = RateLimiter.new()
		limiter._period_usec = period_usec
		limiter.name = LIMITERS_NAME_FMT.format([period_usec])
		Config.get_parent().add_child(limiter)
	return limiter


func wait() -> void:
	var cur_time := Time.get_ticks_usec()
	_reset_if_idle(cur_time)
	if _start_time == 0:
		_start_time = Time.get_ticks_usec()
		_queue_size = 1
		return

	var sleep_time := (_get_next_time() - cur_time) / 1_000_000.0
	_queue_size += 1
	await get_tree().create_timer(sleep_time).timeout


func _get_next_time() -> int:
	return _queue_size * _period_usec + _start_time


func _reset_if_idle(cur_time: int) -> void:
	if _get_next_time() <= cur_time:
		_start_time = 0
		_queue_size = 0
