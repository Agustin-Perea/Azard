extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name ChronoBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	_set_flag("chrono_ball_repeat_count", _scale_int(2, 2, 3))
	_set_flag("chrono_ball_repeat_power", _scale_float(0.60, 0.80, 1.0))
