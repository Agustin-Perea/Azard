extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name PrimeBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	if _is_prime(roulette_controller):
		roulette_controller.multiply_mult_score(_scale_float(1.75, 2.0, 2.5))
