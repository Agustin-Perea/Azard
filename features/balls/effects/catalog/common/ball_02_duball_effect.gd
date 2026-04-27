extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name DuballCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	_multiply_mult(roulette_controller, _scale_float(2.0, 2.25, 2.5))
