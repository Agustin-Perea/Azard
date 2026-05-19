extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name GoldBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	if _is_green(roulette_controller):
		_multiply_mult(roulette_controller, _scale_float(3.0, 3.5, 4.0))
