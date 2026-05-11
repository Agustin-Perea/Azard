extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name GoldBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	var winner := _winner(roulette_controller)
	if winner != null and bool(winner.get_meta(Constants.BOARD_TAG.GOLDEN, false)):
		roulette_controller.add_multiplier(float(_scale_int(1, 2, 3)))
