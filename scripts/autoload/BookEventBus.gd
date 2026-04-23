extends Node


@warning_ignore("unused_signal")
signal spin_started
@warning_ignore("unused_signal")
signal spin_finished

@warning_ignore("unused_signal")
signal start_spin(ball : BallRuntimeState)

signal bet_pre_resolve(RouletteController)
signal bet_resolved(RouletteController)
signal bet_post_resolved(RouletteController)
signal reroll_used(RouletteController)

signal popuptext(spot_global_postion :Vector3, text : String)
