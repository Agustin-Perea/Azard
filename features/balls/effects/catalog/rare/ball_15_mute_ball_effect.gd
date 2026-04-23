extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name MuteBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	GameState.set_meta(Constants.BALL_EFFECT_FLAG.MUTE_TURNS, _scale_int(1, 1, 2))
	GameState.set_meta(Constants.BALL_EFFECT_FLAG.MUTE_ENEMY_DAMAGE_REDUCTION, _scale_float(0.0, 0.20, 0.20))
