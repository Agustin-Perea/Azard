extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name ChronoBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	GameState.set_meta(Constants.BALL_EFFECT_FLAG.CHRONO_REPEAT_COUNT, _scale_int(2, 2, 3))
	GameState.set_meta(Constants.BALL_EFFECT_FLAG.CHRONO_REPEAT_POWER, _scale_float(0.60, 0.80, 1.0))
