extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name GraveBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	_set_flag("grave_ball_execute_threshold", _scale_float(0.15, 0.20, 0.25))
