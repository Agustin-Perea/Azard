extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name EclipseBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	var winner := _winner(roulette_controller)
	if winner != null:
		winner.set_meta(Constants.BOARD_TAG.BOTH_COLORS, true)
	var is_golden := winner != null and bool(winner.get_meta(Constants.BOARD_TAG.GOLDEN, false))
	if _level() >= 2 and (_is_prime(roulette_controller) or is_golden):
		roulette_controller.add_multiplier(_scale_float(0.0, 1.0, 2.0))
	if _level() >= 3:
		roulette_controller.add_multiplier(1.0)
