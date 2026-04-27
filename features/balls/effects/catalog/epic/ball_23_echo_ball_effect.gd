extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name EchoBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	_set_flag("echo_ball_repeat_power", _scale_float(0.50, 0.75, 1.0))
