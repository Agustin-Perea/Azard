extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name MirrorBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	GameState.set_meta(Constants.BALL_EFFECT_FLAG.MIRROR_COPY_POWER, _scale_float(0.70, 1.0, 1.30))
