extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name RedBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	if _is_red(roulette_controller):
		_add_mult(roulette_controller, _scale_float(0.5, 0.75, 1.0))
