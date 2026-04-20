extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name RigBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	_set_flag("rig_ball_correction_range", _scale_int(1, 2, 3))
