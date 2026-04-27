class_name WaitEvent
extends GameEvent

var time_left: float

func _init(seconds: float):
	time_left = seconds

func handle() -> bool:
	time_left -= get_physics_process_delta_time()
	return time_left <= 0.0
