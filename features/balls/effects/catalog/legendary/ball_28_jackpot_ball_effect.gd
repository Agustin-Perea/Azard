extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name JackpotBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	if _is_zero_family(roulette_controller):
		GameState.set_meta(Constants.BALL_EFFECT_FLAG.JACKPOT_AOE_DAMAGE, _scale_int(60, 90, 130))
		roulette_controller.multiply_mult_score(2.0)
		if _level() >= 2:
			GameState.add_run_gold(_scale_int(0, 10, 15))
		if _level() >= 3:
			GameState.heal_player(15)
