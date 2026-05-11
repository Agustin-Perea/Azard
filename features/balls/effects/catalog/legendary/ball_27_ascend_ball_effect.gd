extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name AscendBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	var used_types: Array = GameState.get_meta(Constants.BALL_EFFECT_FLAG.COMBAT_USED_BALL_TYPES, [])
	var count := used_types.size()
	var scale := _scale_float(0.20, 0.25, 0.30)
	roulette_controller.add_multiplier(float(count) * scale)
