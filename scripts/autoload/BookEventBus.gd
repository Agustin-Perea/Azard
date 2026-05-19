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
signal turn_log_reset
signal turn_log_entry(text: String, color: Color)
signal turn_log_close_requested
signal bet_chip_activated(chip_id: int)

signal unit_death(unit : Unit)
@warning_ignore("unused_signal")
signal reroll(RouletteController)

signal battle_init

signal player_turn

signal enemy_turn

signal defeat

signal victory

signal reload
