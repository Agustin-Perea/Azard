extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name JackpotBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	if not _is_zero_family(roulette_controller):
		return
	roulette_controller.set_attack_modifier(&"jackpot_attack_all", true)
	_multiply_mult(roulette_controller, 2.0)
	BookEventBus.turn_log_entry.emit("JackpotBall: x2 mult y ataque a todos", Color(1.0, 0.84, 0.12, 1.0))
