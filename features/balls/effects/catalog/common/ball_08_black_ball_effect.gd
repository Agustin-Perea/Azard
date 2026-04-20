extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name BlackBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	if _is_black(roulette_controller):
		_shield(_scale_int(6, 8, 10))
