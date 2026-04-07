extends Node


@warning_ignore("unused_signal")
signal spin_started
@warning_ignore("unused_signal")
signal spin_finished

@warning_ignore("unused_signal")
signal start_spin(ball : BallRuntimeState)

signal popuptext(spot_global_postion :Vector3, text : String)
