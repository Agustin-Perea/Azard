extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name ZeroBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	if _is_zero_family(roulette_controller):
		_multiply_mult(roulette_controller, _scale_float(6.0, 8.0, 10.0))
		if _level() >= 3:
			_gold(10)
