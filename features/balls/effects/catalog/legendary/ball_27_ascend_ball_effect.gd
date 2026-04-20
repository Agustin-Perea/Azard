extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name AscendBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	var used_types: Array = _get_flag("combat_used_ball_types", [])
	var count := used_types.size()
	var scale := _scale_float(0.20, 0.25, 0.30)
	_add_mult(roulette_controller, float(count) * scale)
