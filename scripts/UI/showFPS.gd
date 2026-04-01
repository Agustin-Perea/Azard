extends Control

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	$FPS.text = str(Engine.get_frames_per_second())
