extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name DuballCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	roulette_controller.multiply_mult_score(_scale_float(2.0, 2.25, 2.5))
