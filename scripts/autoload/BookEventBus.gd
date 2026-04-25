extends Node


@warning_ignore("unused_signal")
signal spin_started
@warning_ignore("unused_signal")
signal spin_finished

@warning_ignore("unused_signal")
signal start_spin(ball : BallRuntimeState)

@warning_ignore("unused_signal")
signal player_turn_started
@warning_ignore("unused_signal")
signal roulette_resolution_completed(roulette_controller: RouletteController, score: int, ball: BallRuntimeState)
@warning_ignore("unused_signal")
signal combat_started
@warning_ignore("unused_signal")
signal combat_ended(victory: bool)
@warning_ignore("unused_signal")
signal combat_kill(unit: Unit)
@warning_ignore("unused_signal")
signal enemy_killed(unit: Unit)

signal bet_pre_resolve(RouletteController)
signal bet_resolved(RouletteController)
signal bet_post_resolved(RouletteController)
signal reroll_used(RouletteController)

signal popuptext(spot_global_postion :Vector3, text : String)


signal unit_death(unit : Unit)
@warning_ignore("unused_signal")
signal reroll(RouletteController)
