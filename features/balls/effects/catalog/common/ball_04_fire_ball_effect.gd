extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name FireBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	_set_flag("fire_ball_splash_pct", _scale_float(0.5, 0.75, 1.0))
