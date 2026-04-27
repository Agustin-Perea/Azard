extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name FateBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	_set_flag("fate_ball_rolls", _scale_int(3, 4, 5))
