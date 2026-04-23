extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name VoidBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	GameState.set_meta(Constants.BALL_EFFECT_FLAG.VOID_IGNORE_SHIELD, true)
	if bool(GameState.get_meta(Constants.BALL_EFFECT_FLAG.COMBAT_ANY_TARGET_DEBUFFED, false)) and _level() >= 3:
		roulette_controller.add_multiplier(0.35)
