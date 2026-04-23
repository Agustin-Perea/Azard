extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name FireBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	GameState.set_meta(Constants.BALL_EFFECT_FLAG.FIRE_SPLASH_PCT, _scale_float(0.5, 0.75, 1.0))
