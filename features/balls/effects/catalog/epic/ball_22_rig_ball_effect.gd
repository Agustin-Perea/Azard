extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name RigBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	GameState.set_meta(Constants.BALL_EFFECT_FLAG.RIG_CORRECTION_RANGE, _scale_int(1, 2, 3))
