extends Node


const TIME_SCALE = 1.0

signal change_collision_detection


@warning_ignore("unused_signal")
signal changeCamera(desired_camera :Camera3D, time : float)

@warning_ignore("unused_signal")
signal changeToState(arg : String)

signal frame_freeze(timescale: float, duration: float)
signal apply_camera_shake(strength: float, duration: float, frequency: float)

signal selection_button_visible(value : bool)
signal book_button_visible(value : bool)
signal book_inputs_enabled(value : bool)


signal change_target(target : Unit)

func disableClickableAreas()->void:
	#ClickableArea.global_input_enabled = false
	#PlayerUiEvents.disable_camera_buttons.emit()
	pass
func enableClickableAreas()->void:
	#ClickableArea.global_input_enabled = true
	#PlayerUiEvents.enable_camera_buttons.emit()
	pass
