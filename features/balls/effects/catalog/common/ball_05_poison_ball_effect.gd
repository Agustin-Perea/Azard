extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name PoisonBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	GameState.set_meta(Constants.BALL_EFFECT_FLAG.POISON_DAMAGE, _scale_int(3, 4, 5))
	GameState.set_meta(Constants.BALL_EFFECT_FLAG.POISON_TURNS, _scale_int(2, 2, 3))
