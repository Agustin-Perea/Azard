extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name CrystalBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	_set_flag("crystal_ball_correction_range", _scale_int(1, 2, 2))
