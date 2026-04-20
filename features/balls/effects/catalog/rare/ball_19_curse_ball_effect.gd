extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name CurseBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	_set_flag("curse_ball_vulnerable_pct", _scale_float(0.25, 0.35, 0.50))
	_set_flag("curse_ball_vulnerable_turns", _scale_int(2, 2, 3))
