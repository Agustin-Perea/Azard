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

signal popuptext(spot_global_postion :Vector3, text : String)

signal unit_death(unit : Unit)
@warning_ignore("unused_signal")
signal reroll(RouletteController)

signal battle_init

signal change_target(unit : Unit)

signal player_turn

signal enemy_turn

signal defeat

signal victory

signal reload
