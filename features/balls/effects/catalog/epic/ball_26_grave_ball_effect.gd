extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name GraveBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	GameState.set_meta(Constants.BALL_EFFECT_FLAG.GRAVE_EXECUTE_THRESHOLD, _scale_float(0.15, 0.20, 0.25))
