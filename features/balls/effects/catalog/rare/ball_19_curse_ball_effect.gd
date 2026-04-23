extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name CurseBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	GameState.set_meta(Constants.BALL_EFFECT_FLAG.CURSE_VULNERABLE_PCT, _scale_float(0.25, 0.35, 0.50))
	GameState.set_meta(Constants.BALL_EFFECT_FLAG.CURSE_VULNERABLE_TURNS, _scale_int(2, 2, 3))
