extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name StormBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	GameState.set_meta(Constants.BALL_EFFECT_FLAG.STORM_CHAIN_TARGETS, _scale_int(4, 5, 99))
