extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name JackpotBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	if _is_zero_family(roulette_controller):
		_set_flag("jackpot_ball_aoe_damage", _scale_int(60, 90, 130))
		_multiply_mult(roulette_controller, 2.0)
		if _level() >= 2:
			_gold(_scale_int(0, 10, 15))
		if _level() >= 3:
			_heal(15)
